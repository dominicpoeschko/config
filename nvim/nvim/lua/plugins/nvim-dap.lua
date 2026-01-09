return {
    {
        "leoluz/nvim-dap-go",
        config = function()
            require('dap-go').setup()
        end,
    },
    {
        "igorlfs/nvim-dap-view",
        opts = {
            auto_toggle = true,
            windows = {
                size = 0.3,
                position = "below",
            },
            winbar = {
                sections = {
                    "disassembly",
                    "scopes",
                    "breakpoints",
                    "threads",
                },
                default_section = "scopes",
                controls = {
                    enabled = true,
                    position = "right",
                },
            },
        },
    },
    {
        "Jorenar/nvim-dap-disasm",
        dependencies = { "igorlfs/nvim-dap-view" },
        opts = {
            dapview_register = true,
            dapview = {
                keymap = "D",
                label = "Disassembly [D]",
                short_label = "󰒓 [D]",
            },
        },
    },
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'igorlfs/nvim-dap-view',
            'Jorenar/nvim-dap-disasm',
            'theHamsta/nvim-dap-virtual-text',
            'nvim-neotest/nvim-nio',
            'williamboman/mason.nvim',
            'jay-babu/mason-nvim-dap.nvim',
            'julianolf/nvim-dap-lldb',
            'jedrzejboczar/nvim-dap-cortex-debug',
        },
        config = function()
            local dap = require('dap')

            require('mason').setup()

            -- Mason DAP setup
            require('mason-nvim-dap').setup({
                ensure_installed = { 'codelldb', 'cortex-debug' },
                automatic_installation = true,
            })

            -- Ensure cortex-debug is installed
            local mason_registry = require('mason-registry')
            if not mason_registry.is_installed('cortex-debug') then
                vim.notify('Installing cortex-debug...', vim.log.levels.INFO)
                local cortex_debug = mason_registry.get_package('cortex-debug')
                cortex_debug:install()
            end

            -- Setup nvim-dap-lldb
            require('dap-lldb').setup()

            -- Setup cortex-debug for embedded ARM debugging
            require('dap-cortex-debug').setup {
                debug = false,
                extension_path = nil,
                lib_extension = nil,
                node_path = 'node',
                dapui_rtt = false,
            }

            -- Helper function to find and select ELF executable using coroutines
            local function find_executable()
                return coroutine.create(function(dap_run_co)
                    -- Find build directories
                    local build_dirs = vim.fn.glob('{build,build_*,build-*}', false, true)
                    build_dirs = vim.tbl_filter(function(d)
                        return vim.fn.isdirectory(d) == 1
                    end, build_dirs)

                    local function select_build_dir(callback)
                        vim.ui.select(build_dirs, {
                            prompt = 'Select or type build directory:',
                        }, callback)
                    end

                    select_build_dir(function(build_dir)
                        if not build_dir then
                            coroutine.resume(dap_run_co, nil)
                            return
                        end

                        -- Find ELF executables
                        local all_files = vim.fn.glob(build_dir .. '/**/*', false, true)
                        local elf_executables = {}

                        for _, file in ipairs(all_files) do
                            if vim.fn.executable(file) == 1 then
                                local file_output = vim.fn.system('file "' .. file .. '"')
                                if string.match(file_output, 'ELF.*executable') then
                                    table.insert(elf_executables, file)
                                end
                            end
                        end

                        vim.ui.select(elf_executables, {
                            prompt = 'Select or type ELF executable:',
                            format_item = function(item)
                                return vim.fn.fnamemodify(item, ':t') .. ' (' .. item .. ')'
                            end,
                        }, function(selection)
                            coroutine.resume(dap_run_co, selection)
                        end)
                    end)
                end)
            end

            -- Helper function to list and select process using coroutines
            local function find_process()
                return coroutine.create(function(dap_run_co)
                    -- Get list of processes with their PIDs and names
                    local ps_output = vim.fn.system('ps -eo pid,comm --no-headers')
                    local processes = {}

                    for line in ps_output:gmatch('[^\r\n]+') do
                        local pid, name = line:match('%s*(%d+)%s+(.+)')
                        if pid and name then
                            table.insert(processes, { pid = tonumber(pid), name = name })
                        end
                    end

                    vim.ui.select(processes, {
                        prompt = 'Select or type process/PID:',
                        format_item = function(proc)
                            return proc.name .. ' (PID: ' .. proc.pid .. ')'
                        end,
                    }, function(choice)
                        coroutine.resume(dap_run_co, choice and choice.pid or nil)
                    end)
                end)
            end

            -- C++ configurations for LLDB
            dap.configurations.cpp = {
                {
                    name = 'Launch',
                    type = 'lldb',
                    request = 'launch',
                    program = find_executable,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    args = {},
                    runInTerminal = false,
                },
                {
                    name = 'Launch with args',
                    type = 'lldb',
                    request = 'launch',
                    program = find_executable,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    args = function()
                        return coroutine.create(function(dap_run_co)
                            local args_string = vim.fn.input('Arguments: ')
                            coroutine.resume(dap_run_co, vim.split(args_string, ' '))
                        end)
                    end,
                    runInTerminal = false,
                },
                {
                    name = 'Attach to process',
                    type = 'lldb',
                    request = 'attach',
                    pid = find_process,
                    cwd = '${workspaceFolder}',
                },
            }

            -- Copy for C
            dap.configurations.c = dap.configurations.cpp

            -- Cortex-M J-Link debugging configurations
            local dap_cortex_debug = require('dap-cortex-debug')

            -- Helper function to query J-Link for supported devices and select device type
            local function select_device()
                return coroutine.create(function(dap_run_co)
                    local devices = {}
                    local device_cache_file = vim.fn.stdpath('cache') .. '/jlink_devices.txt'

                    -- Try to get device list from J-Link
                    local has_jlink = vim.fn.executable('JLinkExe') == 1

                    if has_jlink then
                        -- Check if cache exists and is recent (less than 1 days old)
                        local cache_valid = false
                        local stat = vim.loop.fs_stat(device_cache_file)
                        if stat then
                            local age_seconds = os.time() - stat.mtime.sec
                            cache_valid = age_seconds < (1 * 24 * 60 * 60)
                        end

                        -- Export device list if cache is invalid
                        if not cache_valid then
                            local cmd = string.format(
                                'echo -e "ExpDevList %s\\nexit" | JLinkExe >/dev/null 2>&1',
                                device_cache_file
                            )
                            vim.fn.system(cmd)
                        end

                        -- Parse device list from cache
                        if vim.fn.filereadable(device_cache_file) == 1 then
                            local lines = vim.fn.readfile(device_cache_file)
                            for _, line in ipairs(lines) do
                                -- Parse CSV format: "Manufacturer", "Device", "Core", ...
                                local device = line:match('"[^"]+"%s*,%s*"([^"]+)"')
                                if device and not device:match('^Device$') then  -- Skip header
                                    table.insert(devices, device)
                                end
                            end
                        end
                    end

                    -- Abort if we couldn't get device list
                    if #devices == 0 then
                        vim.notify('Could not load J-Link device list. Install JLinkExe or check cache.', vim.log.levels.ERROR)
                        coroutine.resume(dap_run_co, nil)
                        return
                    end

                    -- Sort devices alphabetically
                    table.sort(devices)

                    vim.ui.select(devices, {
                        prompt = 'Select or type target MCU device (' .. #devices .. ' available):',
                        format_item = function(item)
                            -- Truncate long device names for better display
                            return item:len() > 50 and item:sub(1, 47) .. '...' or item
                        end,
                    }, function(device)
                        coroutine.resume(dap_run_co, device or 'STM32F407VG')
                    end)
                end)
            end

            -- Add Cortex-M configurations (separate from regular C/C++ configs)
            table.insert(dap.configurations.c,
                dap_cortex_debug.jlink_config {
                    name = 'J-Link: Attach',
                    request = 'attach',
                    cwd = '${workspaceFolder}',
                    executable = find_executable,
                    device = select_device,
                    servertype = 'jlink',
                    interface = 'swd',
                    showDevDebugOutput = 'none',
                    swoConfig = {
                        enabled = false,
                    },
                    rttConfig = {
                        enabled = false,
                    },
                    serverArgs = {
                        '-nosilent',
                    }
                }
            )

            -- Copy Cortex-M configs to cpp as well
            dap.configurations.cpp = dap.configurations.c

            -- Virtual text setup
            require('nvim-dap-virtual-text').setup()

            -- Keybindings
            vim.keymap.set('n', '<F5>', dap.continue, { desc = 'DAP: Continue' })
            vim.keymap.set('n', '<F6>', dap.pause, { desc = 'DAP: Pause/Halt' })
            vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'DAP: Step Over' })
            vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'DAP: Step Into' })
        end,
    },
 }
