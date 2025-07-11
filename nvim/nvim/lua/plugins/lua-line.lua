return {
    {
        "nvim-lualine/lualine.nvim",
        lazy = false,
        event = "VimEnter",
        config = function()
            local colors = {
                bg = '#292D38',
                yellow = '#DCDCAA',
                dark_yellow = '#D7BA7D',
                cyan = '#4EC9B0',
                green = '#608B4E',
                light_green = '#B5CEA8',
                string_orange = '#CE9178',
                orange = '#FF8800',
                purple = '#C586C0',
                magenta = '#D16D9E',
                grey = '#858585',
                blue = '#569CD6',
                vivid_blue = '#4FC1FF',
                light_blue = '#9CDCFE',
                red = '#D16969',
                error_red = '#F44747',
                info_yellow = '#FFCC66'
            }

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
                        { lsp_client, color = { fg = colors.grey } },
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