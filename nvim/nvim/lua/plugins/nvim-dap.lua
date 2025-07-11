return {
    {
        "leoluz/nvim-dap-go",
        config = function()
            require('dap-go').setup()
        end
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

            -- Helper function to find CMake build directory
            local function find_cmake_build_dir()
                local ok, result = pcall(function()
                    -- Find all directories matching build patterns
                    local build_patterns = {
                        'build',
                        'Build',
                        'build_*',
                        'build-*',
                    }

                    local found_dirs = {}

                    for _, pattern in ipairs(build_patterns) do
                        local matches = vim.fn.glob(pattern, false, true)
                        for _, match in ipairs(matches) do
                            if vim.fn.isdirectory(match) == 1 then
                                table.insert(found_dirs, match)
                            end
                        end
                    end
                    return found_dirs
                end)

                if not ok then
                    vim.notify("Error finding build directories: " .. tostring(result), vim.log.levels.ERROR)
                    return nil
                end

                local found_dirs = result

                -- Remove duplicates and sort
                local unique_dirs = {}
                local seen = {}
                for _, dir in ipairs(found_dirs) do
                    if not seen[dir] then
                        seen[dir] = true
                        table.insert(unique_dirs, dir)
                    end
                end
                table.sort(unique_dirs)

                if #unique_dirs == 0 then
                    -- No build directories found, ask user
                    local choice = vim.fn.input('No build directory found. (m)anual path or (a)bort? ')
                    if string.lower(choice) == 'm' or string.lower(choice) == 'manual' then
                        local path = vim.fn.input('Build directory path: ', vim.fn.getcwd() .. '/', 'dir')
                        if path == '' or vim.fn.isdirectory(path) == 0 then
                            return nil -- Invalid or empty path
                        end
                        return path
                    else
                        return nil -- Abort
                    end
                elseif #unique_dirs == 1 then
                    -- Ask for confirmation when only one build dir found
                    local build_dir = unique_dirs[1]
                    local confirm = vim.fn.input('Use build directory "' .. build_dir .. '"? (y/N/m for manual): ')

                    if string.lower(confirm) == 'y' or string.lower(confirm) == 'yes' then
                        return build_dir
                    elseif string.lower(confirm) == 'm' or string.lower(confirm) == 'manual' then
                        local path = vim.fn.input('Build directory path: ', vim.fn.getcwd() .. '/', 'dir')
                        if path == '' or vim.fn.isdirectory(path) == 0 then
                            return nil -- Invalid or empty path
                        end
                        return path
                    else
                        return nil -- Abort
                    end
                else
                    -- Multiple build directories found, let user choose
                    local choices = {'Select build directory:'}
                    for i, dir in ipairs(unique_dirs) do
                        table.insert(choices, i .. ': ' .. dir)
                    end
                    table.insert(choices, (#unique_dirs + 1) .. ': Manual path')

                    local choice = vim.fn.inputlist(choices)
                    if choice > 0 and choice <= #unique_dirs then
                        return unique_dirs[choice]
                    elseif choice == (#unique_dirs + 1) then
                        -- Manual path option
                        local path = vim.fn.input('Build directory path: ', vim.fn.getcwd() .. '/', 'dir')
                        if path == '' or vim.fn.isdirectory(path) == 0 then
                            return nil -- Invalid or empty path
                        end
                        return path
                    else
                        return nil -- Abort
                    end
                end
            end

            -- Helper function to find and select executable
            local function find_executable()
                local build_dir = find_cmake_build_dir()
                if not build_dir then
                    return nil -- Build directory selection was cancelled
                end

                local ok, result = pcall(function()
                    local executables = vim.fn.glob(build_dir .. '/**/*', false, true)
                    local filtered = {}

                    -- Filter for ELF executable files only
                    for _, file in ipairs(executables) do
                        if vim.fn.executable(file) == 1 then
                            -- Check if it's an ELF file using 'file' command
                            local file_output = vim.fn.system('file "' .. file .. '"')
                            if string.match(file_output, 'ELF.*executable') then
                                table.insert(filtered, file)
                            end
                        end
                    end
                    return filtered
                end)

                if not ok then
                    vim.notify("Error finding executables: " .. tostring(result), vim.log.levels.ERROR)
                    return nil
                end

                local filtered = result

                -- Sort by executable name only
                table.sort(filtered, function(a, b)
                    local name_a = vim.fn.fnamemodify(a, ':t')
                    local name_b = vim.fn.fnamemodify(b, ':t')
                    return name_a < name_b
                end)

                if #filtered == 0 then
                    -- Ask if user wants to specify manual path or abort
                    local choice = vim.fn.input('No executables found in ' .. build_dir .. '. (m)anual path or (a)bort? ')
                    if string.lower(choice) == 'm' or string.lower(choice) == 'manual' then
                        local path = vim.fn.input('Path to executable: ', build_dir .. '/', 'file')
                        if path == '' then
                            return nil -- Empty path = abort
                        end
                        return path
                    else
                        return nil -- Abort
                    end
                elseif #filtered == 1 then
                    -- Ask for confirmation when only one executable found
                    local exe = filtered[1]
                    local exe_name = vim.fn.fnamemodify(exe, ':t')
                    local confirm = vim.fn.input('Start ' .. exe_name .. '? (y/N/m for manual): ')

                    if string.lower(confirm) == 'y' or string.lower(confirm) == 'yes' then
                        return exe
                    elseif string.lower(confirm) == 'm' or string.lower(confirm) == 'manual' then
                        local path = vim.fn.input('Path to executable: ', build_dir .. '/', 'file')
                        if path == '' then
                            return nil -- Empty path = abort
                        end
                        return path
                    else
                        return nil -- Cancelled
                    end
                else
                    -- Use vim.fn.inputlist for selection
                    local choices = {'Select executable:'}
                    for i, exe in ipairs(filtered) do
                        table.insert(choices, i .. ': ' .. vim.fn.fnamemodify(exe, ':t') .. ' (' .. exe .. ')')
                    end
                    table.insert(choices, (#filtered + 1) .. ': Manual path')

                    local choice = vim.fn.inputlist(choices)
                    if choice > 0 and choice <= #filtered then
                        return filtered[choice]
                    elseif choice == (#filtered + 1) then
                        -- Manual path option
                        local path = vim.fn.input('Path to executable: ', build_dir .. '/', 'file')
                        if path == '' then
                            return nil -- Empty path = abort
                        end
                        return path
                    else
                        return nil -- Cancelled
                    end
                end
            end

            -- Helper function to list and select process
            local function find_process()
                local ok, result = pcall(function()
                    -- Get list of processes with their PIDs and names
                    local ps_output = vim.fn.system('ps -eo pid,comm --no-headers')
                    local processes = {}

                    for line in ps_output:gmatch('[^\r\n]+') do
                        local pid, name = line:match('%s*(%d+)%s+(.+)')
                        if pid and name then
                            table.insert(processes, {pid = tonumber(pid), name = name})
                        end
                    end
                    return processes
                end)

                if not ok then
                    vim.notify("Error finding processes: " .. tostring(result), vim.log.levels.ERROR)
                    return nil
                end

                local processes = result

                -- Sort by process name
                table.sort(processes, function(a, b)
                    return a.name < b.name
                end)

                if #processes == 0 then
                    -- Fallback to manual PID input
                    local pid = vim.fn.input('Process ID: ')
                    return tonumber(pid)
                else
                    -- Create selection list
                    local choices = {'Select process to attach:'}
                    for i, proc in ipairs(processes) do
                        table.insert(choices, i .. ': ' .. proc.name .. ' (PID: ' .. proc.pid .. ')')
                    end
                    table.insert(choices, (#processes + 1) .. ': Manual PID')

                    local choice = vim.fn.inputlist(choices)
                    if choice > 0 and choice <= #processes then
                        return processes[choice].pid
                    elseif choice == (#processes + 1) then
                        -- Manual PID option
                        local pid = vim.fn.input('Process ID: ')
                        return tonumber(pid)
                    else
                        return nil -- Cancelled
                    end
                end
            end

            -- C++ configurations for LLDB
            dap.configurations.cpp = {
                {
                    name = "Launch",
                    type = "lldb",
                    request = "launch",
                    program = find_executable,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    args = {},
                    runInTerminal = false,
                },
                {
                    name = "Launch with args",
                    type = "lldb",
                    request = "launch",
                    program = find_executable,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    args = function()
                        local args_string = vim.fn.input('Arguments: ')
                        return vim.split(args_string, " ")
                    end,
                    runInTerminal = false,
                },
                {
                    name = "Attach to process",
                    type = "lldb",
                    request = "attach",
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
    }
}
