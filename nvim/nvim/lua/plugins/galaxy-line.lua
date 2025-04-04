-- Inside your LazyVim configuration file, define the plugin

return {
  {
    "glepnir/galaxyline.nvim", -- GalaxyLine plugin
    lazy = false;
    event = "VimEnter", -- Load this plugin when Vim starts
    config = function()
      -- Import necessary modules from galaxyline
      local gl = require('galaxyline')
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

      local condition = require('galaxyline.condition')
      local gls = gl.section
      gl.short_line_list = { 'NvimTree', 'vista', 'dbui', 'packer' }

      -- Left Section
      gls.left[1] = {
        ViMode = {
          provider = function()
            local mode_color = {
              n = colors.blue,
              i = colors.green,
              v = colors.purple,
              [''] = colors.purple,
              V = colors.purple,
              c = colors.magenta,
              no = colors.blue,
              s = colors.orange,
              S = colors.orange,
              [''] = colors.orange,
              ic = colors.yellow,
              R = colors.red,
              Rv = colors.red,
              cv = colors.blue,
              ce = colors.blue,
              r = colors.cyan,
              rm = colors.cyan,
              ['r?'] = colors.cyan,
              ['!'] = colors.blue,
              t = colors.blue
            }
            vim.api.nvim_command('hi GalaxyViMode guifg=#ffffff guibg=' .. mode_color[vim.fn.mode()])
            local mode_name = {
              n = 'NORMAL',
              i = 'INSERT',
              v = 'VISUAL',
              [''] = 'VISUAL BLOCK',
              V = 'VISUAL LINE',
              c = 'COMMAND-LINE',
              no = 'OPERATOR-PENDING',
              s = 'SELECT',
              S = 'SELECT',
              [''] = 'SELECT',
              ic = 'INS-COMPLETE',
              R = 'REPLACE',
              Rv = 'VIRTUAL',
              cv = 'EX',
              ce = 'NORMAL EX',
              r = 'HIT-ENTER',
              rm = '--MORE',
              ['r?'] = ':CONFIRM',
              ['!'] = 'SHELL',
              t = 'TERMINAL'
            }

            return mode_name[vim.fn.mode()] .. ' '
          end,
          icon = '  ',
          highlight = { colors.red, colors.bg },
        }
      }

      -- Git Information Section
      gls.left[2] = {
        GitIcon = {
          provider = function()
            return ' '
          end,
          condition = condition.check_git_workspace,
          separator = ' ',
          separator_highlight = { 'NONE', colors.bg },
          highlight = { colors.orange, colors.bg }
        }
      }
      gls.left[3] = {
        GitBranch = {
          provider = 'GitBranch',
          condition = condition.check_git_workspace,
          separator = ' ',
          separator_highlight = { 'NONE', colors.bg },
          highlight = { colors.grey, colors.bg }
        }
      }
      -- Diff Section
      gls.left[4] = {
        DiffAdd = {
          provider = 'DiffAdd',
          condition = condition.hide_in_width,
          icon = '  ',
          highlight = { colors.green, colors.bg }
        }
      }
      gls.left[5] = {
        DiffModified = {
          provider = 'DiffModified',
          condition = condition.hide_in_width,
          icon = ' 柳',
          highlight = { colors.blue, colors.bg }
        }
      }
      gls.left[6] = {
        DiffRemove = {
          provider = 'DiffRemove',
          condition = condition.hide_in_width,
          icon = '  ',
          highlight = { colors.red, colors.bg }
        }
      }

      -- Right Section
      gls.right[1] = {
        DiagnosticError = {
          provider = 'DiagnosticError',
          icon = '  ',
          highlight = { colors.error_red, colors.bg }
        }
      }
      gls.right[2] = {
        DiagnosticWarn = {
          provider = 'DiagnosticWarn',
          icon = '  ',
          highlight = { colors.orange, colors.bg }
        }
      }

      gls.right[3] = {
        DiagnosticHint = {
          provider = 'DiagnosticHint',
          icon = '  ',
          highlight = { colors.vivid_blue, colors.bg }
        }
      }

      gls.right[4] = {
        DiagnosticInfo = {
          provider = 'DiagnosticInfo',
          icon = '  ',
          highlight = { colors.info_yellow, colors.bg }
        }
      }

      gls.right[5] = {
        ShowLspClient = {
          provider = 'GetLspClient',
          condition = function()
            local tbl = { ['dashboard'] = true, [' '] = true }
            if tbl[vim.bo.filetype] then return false end
            return true
          end,
          icon = '  ',
          highlight = { colors.grey, colors.bg }
        }
      }

      gls.right[6] = {
        LineInfo = {
          provider = 'LineColumn',
          separator = '  ',
          separator_highlight = { 'NONE', colors.bg },
          highlight = { colors.grey, colors.bg }
        }
      }

      gls.right[7] = {
        PerCent = {
          provider = 'LinePercent',
          separator = ' ',
          separator_highlight = { 'NONE', colors.bg },
          highlight = { colors.grey, colors.bg }
        }
      }

      gls.right[8] = {
        Tabstop = {
          provider = function()
            return "Spaces: " .. vim.api.nvim_buf_get_option(0, "shiftwidth") .. " "
          end,
          condition = condition.hide_in_width,
          separator = ' ',
          separator_highlight = { 'NONE', colors.bg },
          highlight = { colors.grey, colors.bg }
        }
      }

      gls.right[9] = {
        BufferType = {
          provider = 'FileTypeName',
          condition = condition.hide_in_width,
          separator = ' ',
          separator_highlight = { 'NONE', colors.bg },
          highlight = { colors.grey, colors.bg }
        }
      }

      gls.right[10] = {
        FileEncode = {
          provider = 'FileEncode',
          condition = condition.hide_in_width,
          separator = ' ',
          separator_highlight = { 'NONE', colors.bg },
          highlight = { colors.grey, colors.bg }
        }
      }

      gls.right[11] = {
        Space = {
          provider = function()
            return ' '
          end,
          separator = ' ',
          separator_highlight = { 'NONE', colors.bg },
          highlight = { colors.orange, colors.bg }
        }
      }

      -- Short Line Section
      gls.short_line_left[1] = {
        BufferType = {
          provider = 'FileTypeName',
          separator = ' ',
          separator_highlight = { 'NONE', colors.bg },
          highlight = { colors.grey, colors.bg }
        }
      }

      gls.short_line_left[2] = {
        SFileName = {
          provider = 'SFileName',
          condition = condition.buffer_not_empty,
          highlight = { colors.grey, colors.bg }
        }
      }

      gls.short_line_right[1] = {
        BufferIcon = {
          provider = 'BufferIcon',
          highlight = { colors.grey, colors.bg }
        }
      }
    end,
  }
}

