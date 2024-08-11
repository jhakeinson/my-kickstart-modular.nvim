-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    {
      's1n7ax/nvim-window-picker',
      version = '2.*',
      config = function()
        require('window-picker').setup {
          filter_rules = {
            include_current_win = false,
            autoselect_one = true,
            -- filter using buffer options
            bo = {
              -- if the file type is one of following, the window will be ignored
              filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
              -- if the buffer type is one of following, the window will be ignored
              buftype = { 'terminal', 'quickfix' },
            },
          },
        }
      end,
    },
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree toggle=true float<CR>', desc = 'NeoTree reveal' },
  },
  opts = {
    filesystem = {
      hijack_netrw_behavior = 'open_default',
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
  -- require neo-tree on init (no lazy) only when Netrw is opened
  init = function() -- init is called on startup. i.e. no lazy.
    vim.g.neo_tree_remove_legacy_commands = 1
    if vim.fn.argc() >= 1 then
      vim.api.nvim_create_autocmd('UIEnter', {
        once = true,
        callback = function(_)
          for i = 0, vim.fn.argc() - 1 do -- check for all command line arguments
            local stat = vim.loop.fs_stat(vim.fn.argv(i))
            if stat and stat.type == 'directory' then -- only if any of them is a dir
              require 'neo-tree' -- require neo-tree, which asks lazy to load neo-tree which calls setup with `opts` and
              -- since hijack_netrw_behavior is set there, neo-tree overwrites netrw on setup
              return
            end
          end
        end,
      })
    end
    -- if no cl args or all are files, neo-tree is not loaded here and will wait lazily
  end,
}
