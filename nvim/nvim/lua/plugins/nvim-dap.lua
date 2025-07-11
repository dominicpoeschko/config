return {
    {
        "leoluz/nvim-dap-go",
        config = function()
            require('dap-go').setup()
        end,
    },
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'rcarriga/nvim-dap-ui',
            'theHamsta/nvim-dap-virtual-text',
            'nvim-neotest/nvim-nio',
            'williamboman/mason.nvim',
            'jay-babu/mason-nvim-dap.nvim',
            'julianolf/nvim-dap-lldb',
        },
        config = function()
            local dap = require('dap')
            local dapui = require('dapui')

            require('mason').setup()

            -- Mason DAP setup
            require('mason-nvim-dap').setup({
                ensure_installed = { 'codelldb' },
                automatic_installation = true,
            })

            -- Setup nvim-dap-lldb
            require('dap-lldb').setup()

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

            -- DAP UI setup
            dapui.setup()

            -- Virtual text setup
            require('nvim-dap-virtual-text').setup()
        end,
    },
 }
