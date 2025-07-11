return {
    {
        "nvim-lualine/lualine.nvim",
        lazy = false,
        event = "VimEnter",
        config = function()
            local function lsp_client()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if next(clients) == nil then return '' end
                return '  ' .. clients[1].name
            end

            require('lualine').setup {
                options = {
                    theme = 'gruvbox',
                    component_separators = '|',
                    section_separators = '',
                    disabled_filetypes = { 'NvimTree', 'vista', 'dbui', 'packer' },
                    globalstatus = true,
                },
                sections = {
                    lualine_a = {
                        {
                            'mode',
                            icon = '',
                            separator = { left = '' },
                            right_padding = 2,
                        },
                    },
                    lualine_b = {
                        { 'branch', icon = '' },
                        {
                            'diff',
                            symbols = { added = ' ', modified = '柳', removed = ' ' },
                        },
                    },
                    lualine_c = {
                        {
                            'diagnostics',
                            sources = { 'nvim_lsp' },
                            symbols = {
                                error = ' ',
                                warn = ' ',
                                info = ' ',
                                hint = ' ',
                            },
                        },
                    },
                    lualine_x = {
                        {
                            function()
                                return "Spaces: " .. vim.bo.shiftwidth
                            end,
                        },
                        { 'encoding' },
                        { 'filetype' },
                    },
                    lualine_y = { 'progress' },
                    lualine_z = {
                        { 'location' },
                        { lsp_client, color = { fg = '#858585' } },
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { 'filename' },
                    lualine_x = { 'location' },
                    lualine_y = {},
                    lualine_z = {},
                },
                tabline = {},
                extensions = {},
            }
        end,
    }
}