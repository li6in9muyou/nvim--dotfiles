-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- do not add CRLF at eof
vim.opt.fixeol = false

-- when buffer is changed externally, automatically reload it
vim.opt.autoread = true

-- when I tab, insert spaces
vim.opt.expandtab = true

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Set my shell to pwsh 7
vim.opt.shell = 'pwsh'
vim.opt.shellcmdflag = '-NoLogo'

-- Do not append CRLF or LF when saving files! Let prettier and linters do this
vim.opt.fixendofline = false

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrap = true
vim.opt.breakat = ' ^I!@*-+;:,./?(){}[]'
vim.opt.linebreak = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '<->', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 6

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
vim.keymap.set('n', 'x', '"_x', { desc = "don't mess up my yank" })

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.diagnostic.config { source = true, virtual_text = { spacing = 1 } }
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [d]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [d]iagnostic message' })
vim.keymap.set('n', '<leader>e', function()
  vim.diagnostic.open_float()
end, { desc = 'Show diagnostic [e]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
local is_showing_diagnostics = true
vim.keymap.set('n', '<leader>te', function()
  is_showing_diagnostics = not is_showing_diagnostics
  if is_showing_diagnostics then
    vim.diagnostic.enable()
  else
    vim.diagnostic.disable()
  end
end, { desc = '[e]rror diagnostics' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local DEFAULT_CONFORM_OPT = function()
  return { timeout_ms = 4000 }
end

local RANGE_CONFORM_OPT = function(range)
  return { range = range, timeout_ms = 4000 }
end

local function count_char_offsets_for_hunks(bufnr, hunks)
  local hunks = require('gitsigns').get_hunks(bufnr)
  local last_line = 0
  for _, hunk in ipairs(hunks) do
    if hunk.added ~= nil then
      local added_last_line = hunk.added.start + hunk.added.count - 1
      if added_last_line > last_line then
        last_line = added_last_line
      end
    end
  end

  local lines_with_hunks = vim.api.nvim_buf_get_lines(0, 0, last_line - 1 + 1, false)

  local line_char_offset_table = {}
  local total_length = 0
  for i = 1, #lines_with_hunks, 1 do
    total_length = total_length + vim.fn.strchars(lines_with_hunks[i])
    line_char_offset_table[i] = total_length
  end

  line_char_offset_table[0] = 0
  line_char_offset_table[#line_char_offset_table + 1] = line_char_offset_table[#line_char_offset_table]
  return line_char_offset_table
end

local book
local function format_hunks(bufnr)
  local hunks = require('gitsigns').get_hunks(bufnr)

  if hunks == nil then
    return
  end

  local offset_table = count_char_offsets_for_hunks(bufnr, hunks)

  local format = require('conform').format
  for i = #hunks, 1, -1 do
    local hunk = hunks[i]
    book.debug('libq fmthunk/hunk', hunk)
    if hunk ~= nil and hunk.type ~= 'delete' then
      local start = hunk.added.start
      local last = start + hunk.added.count
      -- nvim_buf_get_lines uses zero-based indexing -> subtract from last
      local last_hunk_line = vim.api.nvim_buf_get_lines(0, last - 2, last - 1, true)[1]
      local range = { start = { start, 0 }, ['end'] = { last - 1, last_hunk_line:len() }, offset_table = offset_table }
      format(RANGE_CONFORM_OPT(range))
    else
      book.debug 'libq fmthunk/skip hunk.type==delete'
    end
  end
end

vim.keymap.set({ 'n', 'x' }, '<leader>vf', function()
  local current_mode = vim.fn.mode()
  if current_mode == 'v' or current_mode == '\22' then
    return
  elseif current_mode == 'V' then
    local start_pos = vim.fn.getpos "'<"
    local end_pos = vim.fn.getpos "'>"

    local start_line = start_pos[2]
    local end_line = end_pos[2]

    local range = {
      start = { start_line - 1, 0 },
      ['end'] = { end_line - 1, -1 },
    }
    require('conform').format(RANGE_CONFORM_OPT(range), function()
      vim.cmd 'w'
    end)
  else
    require('conform').format(DEFAULT_CONFORM_OPT(), function()
      vim.cmd 'w'
    end)
  end
end, { desc = '[f]ormat whole file/selection', silent = true })

vim.keymap.set('n', '<leader>vs', 'V:s/\\\\/\\//g', { desc = 'replace \\ with [s]lash in this line', noremap = true })

local DEFAULT_BUFFER_ENABLE_FORMAT_ON_SAVE = false
vim.keymap.set('n', '<leader>tf', function()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.b[bufnr].enable_format_on_save == nil then
    vim.b[bufnr].enable_format_on_save = DEFAULT_BUFFER_ENABLE_FORMAT_ON_SAVE
  end
  vim.b[bufnr].enable_format_on_save = not vim.b[bufnr].enable_format_on_save
  vim.notify('format on save: ' .. (not vim.b[bufnr].enable_format_on_save and 'off' or 'on') .. ' (this buffer)')
end, { desc = '[f]ormat on save', noremap = true })

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

vim.g.mkdp_auto_close = 0

local excluded_folders_in_leader_sf = { 'node_modules', '.git' }
local function prefix_with_bang(strings)
  local result = {}
  for _, v in ipairs(strings) do
    table.insert(result, '!' .. v)
  end
  return result
end

local function git_bcommits_telescope_mapping_handler(prompt_bufnr)
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local selection = action_state.get_selected_entry()
  local commit_hash = selection.value
  actions.close(prompt_bufnr)
  local current_buffer_path = vim.api.nvim_buf_get_name(0)
  vim.cmd('DiffviewFileHistory ' .. current_buffer_path .. ' --range=' .. commit_hash .. ' --no-merges')
end

local function find_git_root_or_cwd()
  local git_root_output = vim.fn.system { 'git', 'rev-parse', '--show-toplevel' }
  local git_root = git_root_output:gsub('%s*$', '')

  if vim.v.shell_error == 0 and git_root ~= '' then
    return git_root
  else
    return vim.fn.getcwd()
  end
end
local git_root = find_git_root_or_cwd()

local prettier_formatters = { 'prettierd' }
-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to force a plugin to be loaded.
  --
  --  This is equivalent to:
  --    require('Comment').setup({})

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`. This is equivalent to the following Lua:
  --    require('gitsigns').setup({ ... })
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '🟩' },
        change = { text = '🚧' },
        delete = { text = '🟥' },
        topdelete = { text = '🟥' },
        changedelete = { text = '📝' },
      },
      signs_staged = {
        add = { text = '📦' },
        change = { text = '📦' },
        delete = { text = '📦' },
        topdelete = { text = '📦' },
        changedelete = { text = '📦' },
      },
      signs_staged_enable = true,
      current_line_blame_formatter = '<summary> - <author>, <author_time:%Y-%m-%d>',
      current_line_blame_opts = {
        virt_text_pos = 'overlay',
        delay = 300,
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { desc = 'Next [c]hange', expr = true })

        map('n', '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { desc = 'Previous [c]hange', expr = true })

        -- Actions
        map('n', '<leader>hs', gs.stage_hunk, { desc = '[h]unk [s]tage' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = '[h]unk [r]estore' })
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = '[h]unk [s]tage' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = '[h]unk [r]estore' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = '[h]unk [s]tage all!!!' })
        -- map('n', '<leader>hu', gs.undo_stage_hunk, { desc = '[h]unk [u]ndo stage' })
        -- map('n', '<leader>hR', gs.reset_buffer, { desc = '[h]unk [R]estore all!!!' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = '[h]unk [p]review' })
        -- map('n', '<leader>hb', function()
        --   gs.blame_line { full = true }
        -- end, { desc = '[h]unk [b]lame' })
        -- map('n', '<leader>hd', gs.diffthis, { desc = '[h]unk [d]iff' })
        -- map('n', '<leader>hD', function()
        --   gs.diffthis '~'
        -- end, { desc = '[h]unk [d]iff against ~' })

        -- map('n', '<leader>td', gs.toggle_deleted, { desc = '[d]elete' })
        -- map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = '[b]lame' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
      end,
    },
  },

  -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
  --
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  --
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
  -- Then, because we use the `config` key, the configuration only runs
  -- after the plugin has been loaded:
  --  config = function() ... end

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup { win = { border = 'single' } }

      -- Document existing key chains
      require('which-key').add {
        { '<leader>c', group = '[c]ode' },
        { '<leader>d', group = '[d]ocument' },
        { '<leader>r', group = '[r]ename' },
        { '<leader>s', group = '[s]earch' },
        { '<leader>w', group = '[w]orkspace' },
        { '<leader>t', group = '[t]oggle features' },
      }

      require('which-key').add {
        { '<leader>h', group = 'git [h]unk', mode = { 'v', 'n' } },
        { '<leader>v', group = '[v]tility', mode = 'n' },
      }
    end,
  },

  -- NOTE: Plugins can specify dependencies.
  --
  -- The dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- Use the `dependencies` key to specify the dependencies of a particular plugin

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!
      local binary_crap = {
        'assets[/\\]images',
        'assets[/\\]image',
        'asset[/\\]images',
        'asset[/\\]image',
        '%.png',
        '%.jpg',
        '%.jpeg',
        '%.gif',
        '%.bmp',
        '%.tiff',
        '%.psd',
        '%.mp4',
        '%.mkv',
        '%.avi',
        '%.mov',
        '%.mpg',
        '%.vob',
        '%.mp3',
        '%.aac',
        '%.wav',
        '%.flac',
        '%.ogg',
        '%.mka',
        '%.wma',
        '%.doc',
        '%.xls',
        '%.ppt',
        '%.docx',
        '%.odt',
        '%.zip',
        '%.rar',
        '%.7z',
        '%.tar',
        '%.iso',
        '%.mdb',
        '%.frm',
        '%.sqlite',
        '%.exe',
        '%.dll',
        '%.so',
        '%.class',
      }

      local tool_chain_crap = { '%.yarn[/\\]cache', '%.idea' }

      local concat = function(...)
        local result = {} -- Initialize an empty table to store the concatenated values

        -- Iterate through each argument (table)
        for _, tbl in ipairs { ... } do
          -- Append each value from the current table to the result table
          for _, value in ipairs(tbl) do
            table.insert(result, value)
          end
        end

        return result -- Return the concatenated table
      end

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        defaults = {
          file_ignore_patterns = concat(binary_crap, tool_chain_crap),
          mappings = {
            i = {
              ['<esc>'] = require('telescope.actions').close,
              ['<C-q>'] = require('telescope.actions').select_vertical,
              ['<C-f>'] = require('telescope.actions').send_to_qflist + require('telescope.actions').open_qflist,
              ['<C-v>'] = false,
            },
          },
          path_display = { 'truncate' },
          winblend = 0,
          layout_strategy = 'vertical',
          layout_config = {
            vertical = {
              height = { padding = 1 },
              width = 0.8,
              preview_height = 0.6,
              -- when the number of lines in screen is
              -- less than ${preview_cutoff}, preview is disabled
              preview_cutoff = 24,
            },
          },
          sorting_strategy = 'ascending',
        },
        pickers = {
          git_bcommits = {
            mappings = {
              i = {
                ['<CR>'] = git_bcommits_telescope_mapping_handler,
              },
              n = {
                ['<CR>'] = git_bcommits_telescope_mapping_handler,
              },
            },
          },
          colorscheme = {
            enable_preview = true,
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local function oil_to_windows_dir(dir)
        local prefix = 'oil:///'
        if dir:sub(1, #prefix) == prefix then
          local path = dir:sub(#prefix + 1)
          path = path:sub(1, 1) .. ':' .. path:sub(2)
          return path
        end
        return dir
      end

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[s]earch [h]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[s]earch [k]eymaps' })
      -- utils.buffer_dir()
      vim.keymap.set('n', '<leader>Sf', function()
        builtin.find_files {
          cwd = oil_to_windows_dir(require('telescope.utils').buffer_dir()),
        }
      end, { desc = '[S]earch [f]iles in parent of buffer' })
      vim.keymap.set('n', '<leader>sf', function()
        local function rg_file_path_exclusion_filters(exclude_dirs)
          local ans = {}
          for _, dir in ipairs(exclude_dirs) do
            table.insert(ans, '-g')
            table.insert(ans, '!' .. dir)
          end
          return ans
        end

        local spread = table.unpack or unpack
        builtin.find_files {
          find_command = { 'rg', '--files', '--color', 'never', '--hidden', spread(rg_file_path_exclusion_filters(excluded_folders_in_leader_sf)) },
        }
      end, { desc = '[s]earch [f]iles' })
      vim.keymap.set('n', '<leader>sl', function()
        builtin.git_bcommits {
          prompt_title = 'git log <current file>',
          -- FIXME:
          -- the --follow switch is "SVN noob" pleaser, better alternatives include -G -S -L
          -- see https://gitster.livejournal.com/35628.html
          -- see https://stackoverflow.com/questions/5743739/how-to-really-show-logs-of-renamed-files-with-git
          git_command = { 'git', 'log', '--format=%h %an %as %d %s', '--follow', '--abbrev-commit', '--no-merges' },
        }
      end, { desc = '[s]earch git [l]ogs' })
      -- vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[s]earch [s]elect Telescope' })
      vim.keymap.set('n', '<leader>st', function()
        builtin.grep_string { grep_open_files = true }
      end, { desc = '[s]earch [t]his word in open files' })
      vim.keymap.set('x', '<leader>st', function()
        local start = vim.fn.getpos 'v'
        local last = vim.fn.getpos '.'
        local selected = vim.fn.getregion(start, last)
        builtin.grep_string { search = selected[1], grep_open_files = true }
      end, { desc = '[s]earch [t]his word in open files' })
      vim.keymap.set('x', '<leader>sT', function()
        local start = vim.fn.getpos 'v'
        local last = vim.fn.getpos '.'
        local selected = vim.fn.getregion(start, last)
        builtin.grep_string { search = selected[1] }
      end, { desc = '[s]earch [t]his word in open files' })
      vim.keymap.set('n', '<leader>sT', builtin.grep_string, { desc = '[s]earch [t]his word in working dir' })
      vim.keymap.set('n', '<leader>sw', '<cmd>Easypick changed_files<cr>', { desc = "[s]earch files I'm [w]orking on (git changed)" })
      -- vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[s]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[s]earch [r]esume' })
      vim.keymap.set('n', '<leader>s.', function()
        builtin.oldfiles { only_cwd = true }
      end, { desc = '[s]earch recent files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer' })
      -- The following command requires ripgrip executable in path
      -- see https://github.com/BurntSushi/ripgrep
      vim.keymap.set('n', '<leader>?', function()
        builtin.live_grep { glob_pattern = prefix_with_bang(excluded_folders_in_leader_sf) }
      end, { desc = 'enhanced [/] search subdirs' })
      vim.keymap.set('n', '<leader>S?', function()
        builtin.live_grep {
          cwd = oil_to_windows_dir(require('telescope.utils').buffer_dir()),
        }
      end, { desc = '<leader>? but in parent of buffer dir' })
      vim.keymap.set('n', '<leader>m', function()
        builtin.marks()
      end, { desc = 'search marks' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'find in open files',
        }
      end, { desc = '[s]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      -- vim.keymap.set('n', '<leader>sn', function()
      --   builtin.find_files { cwd = vim.fn.stdpath 'config' }
      -- end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
      -- used for completion, annotations and signatures of Neovim apis
      { 'folke/neodev.nvim', opts = {} },
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[g]oto [d]efinition')

          -- Find references for the word under your cursor.
          map('gr', function()
            require('telescope.builtin').lsp_references { show_line = false, path_display = { 'truncate' } }
          end, '[g]oto [r]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[g]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', function()
            require('telescope.builtin').lsp_type_definitions { path_display = { 'tail' } }
          end, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('gs', function()
            require('telescope.builtin').lsp_document_symbols {
              symbol_width = 0.5,
            }
          end, '[g]oto [s]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('gS', function()
            require('telescope.builtin').lsp_dynamic_workspace_symbols {
              fname_width = 0.5,
              path_display = { 'truncate' },
            }
          end, '[g]oto all [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[r]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[c]ode [a]ction')

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[g]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
          end

          -- The following autocommand is used to enable inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled())
            end, 'Inlay [h]ints')
          end
        end,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event.buf }
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- clangd = {},
        -- gopls = {},
        black = {},
        pylint = {},
        docformatter = {},
        pylsp = {},
        pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`tsserver`) will work just fine
        ['typescript-language-server'] = {},
        stylua = {},
        emmet_language_server = {
          filetypes = { 'css', 'html', 'javascriptreact', 'less', 'sass', 'scss', 'typescriptreact' },
          -- Read more about this options in the [vscode docs](https://code.visualstudio.com/docs/editor/emmet#_emmet-configuration).
          -- **Note:** only the options listed in the table are supported.
          init_options = {
            ---@type table<string, string>
            includeLanguages = {},
            --- @type string[]
            excludeLanguages = {},
            --- @type string[]
            extensionsPath = {},
            --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/preferences/)
            preferences = {},
            --- @type boolean Defaults to `true`
            showAbbreviationSuggestions = true,
            --- @type "always" | "never" Defaults to `"always"`
            showExpandedAbbreviation = 'always',
            --- @type boolean Defaults to `false`
            showSuggestionsAsSnippets = false,
            --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/syntax-profiles/)
            syntaxProfiles = {},
            --- @type table<string, string> [Emmet Docs](https://docs.emmet.io/customization/snippets/#variables)
            variables = {},
          },
        },
        eslint = {},
        cssls = {},
        ['css-variables-language-server'] = {},
        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  -- install with yarn or npm
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    -- if error occurs, just run this yourself
    build = 'cd app && yarn',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
      vim.g.mkdp_port = '13334'
      vim.g.mkdp_page_title = '${name}.md'
      vim.g.mkdp_images_path = './assets'
      vim.keymap.set('n', '<leader>vm', '<cmd>MarkdownPreview<cr>', { desc = 'start [m]arkdown preview', noremap = true, silent = true })
    end,
    ft = { 'markdown' },
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    lazy = false,
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        if nil == vim.b[bufnr].enable_format_on_save then
          vim.b[bufnr].enable_format_on_save = DEFAULT_BUFFER_ENABLE_FORMAT_ON_SAVE
        end

        if not vim.b[bufnr].enable_format_on_save then
          vim.notify 'format on save is disabled (this buffer )'
          return nil
        end
        format_hunks(bufnr)
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        html = prettier_formatters,
        css = prettier_formatters,
        less = prettier_formatters,
        -- Conform can also run multiple formatters sequentially
        python = { 'isort', 'black' },
        --
        -- You can use a sub-list to tell conform to run *until* a formatter
        -- is found.
        javascript = prettier_formatters,
        typescript = prettier_formatters,
        javascriptreact = prettier_formatters,
        typescriptreact = prettier_formatters,
        markdown = prettier_formatters,
        json = prettier_formatters,
      },
    },
  },

  'hrsh7th/cmp-path',
  'hrsh7th/cmp-buffer',
  'amarakon/nvim-cmp-buffer-lines',
  -- must list dependencies before nvim-cmp otherwise cmp_luasnip does not work
  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'amarakon/nvim-cmp-buffer-lines',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'uga-rosa/cmp-dictionary',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}
      -- or relative to the directory of $MYVIMRC
      require('luasnip.loaders.from_vscode').lazy_load { paths = './my-snippets' }

      cmp.setup {
        performance = {
          max_view_entries = 13,
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm { select = true },

          -- If you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          --['<CR>'] = cmp.mapping.confirm { select = true },
          --['<Tab>'] = cmp.mapping.select_next_item(),
          --['<S-Tab>'] = cmp.mapping.select_prev_item(),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          { name = 'nvim_lsp' },
          {
            name = 'buffer',
            option = {
              get_bufnrs = function()
                local visible_bufs = {}
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  visible_bufs[vim.api.nvim_win_get_buf(win)] = true
                end
                return vim.tbl_keys(visible_bufs)
              end,
            },
          },
          {
            name = 'buffer-lines',
            option = {
              leading_whitespace = false,
            },
          },
          { name = 'path' },
        },
      }
      require('luasnip.loaders.from_vscode').lazy_load()
    end,
  },

  {
    'uga-rosa/cmp-dictionary',
    priority = 0,
    opts = {
      paths = { (vim.fn.stdpath 'data') .. '/words.txt' },
      exact_length = 2,
      first_case_insensitive = true,
      external = {
        enable = true,
        command = { 'rg', '-N', '-o', '\\b${prefix}\\w+', '${path}', '--trim' },
      },
      document = {
        enable = false,
        -- command = { 'wn', '${label}', '-over' },
      },
    },
  },

  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      -- You can configure highlights by doing something like:
      vim.cmd.hi 'Comment gui=none'
    end,
    opts = {
      on_colors = function(colors)
        colors.bg = '#000000'
      end,
      on_highlights = function(hl, colors)
        hl.LineNrAbove = { fg = '#670067' }
        hl.LineNrBelow = { fg = '#606000' }
        hl.CursorLineNr = { fg = colors.green }
      end,
    },
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = false,
      keywords = {
        ['dnc'] = { color = '#FFFF00', alt = { 'do not commit', 'DO NOT COMMIT' } },
      },
    },
  },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup {
        custom_surroundings = {
          ['('] = { output = { left = '(', right = ')' } },
          [')'] = { output = { left = '( ', right = ' )' } },

          ['['] = { output = { left = '[', right = ']' } },
          [']'] = { output = { left = '[ ', right = ' ]' } },

          ['{'] = { output = { left = '{', right = '}' } },
          ['}'] = { output = { left = '{ ', right = ' }' } },
        },
      }

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = {
        'scss',
        'bash',
        'css',
        'csv',
        'diff',
        'dockerfile',
        'gitignore',
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'html',
        'ini',
        'java',
        'javascript',
        'json',
        'lua',
        'markdown',
        'mermaid',
        'powershell',
        'properties',
        'python',
        'sql',
        'typescript',
        'tsx',
        'jsonc',
        'vim',
        'vimdoc',
        'yaml',
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-n>',
          node_incremental = '<C-m>',
          node_decremental = '<C-n>',
        },
      },
    },
    config = function(_, opts)
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

      -- Prefer git instead of curl in order to improve connectivity in some environments
      require('nvim-treesitter.install').prefer_git = true
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)

      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },

  {
    'stevearc/oil.nvim',
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup {
        skip_confirm_for_simple_edits = true,
        -- always keep an oil in buffer list
        cleanup_delay_ms = 2000,
        -- always keep an oil in buffer list
        buf_options = {
          buflisted = true,
          bufhidden = 'hide',
        },
        keymaps = {
          ['g?'] = 'actions.show_help',
          ['<CR>'] = 'actions.select',
          ['<C-s>'] = 'actions.select_vsplit',
          ['<C-h>'] = false,
          -- ['<C-t>'] = 'actions.select_tab',
          ['<C-p>'] = 'actions.preview',
          ['<C-c>'] = 'actions.close',
          ['<C-l>'] = false,
          ['-'] = 'actions.parent',
          ['_'] = 'actions.open_cwd',
          ['`'] = 'actions.cd',
          ['~'] = 'actions.tcd',
          ['gs'] = 'actions.change_sort',
          ['gx'] = 'actions.open_external',
          ['g.'] = 'actions.toggle_hidden',
          ['g\\'] = 'actions.toggle_trash',
        },
        view_options = {
          show_hidden = true,
        },
      }
    end,
  },

  {
    'li6in9muyou/diffview.nvim',
    opts = {
      file_history_panel = {
        max_len_commit_subject = 9999,
        win_config = {
          win_opts = {
            wrap = true,
          },
        },
      },
      keymaps = {
        file_history_panel = {
          y = false,
        },
      },
    },
  },

  -- The following two comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',
  -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  { import = 'custom.plugins' },
  {
    'folke/noice.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    event = 'VeryLazy',
    opts = {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = false, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
      },
    },
  },
  {
    'li6in9muyou/eyeliner.nvim',
    config = function()
      require('eyeliner').setup {
        highlight_on_key = false,
        dim = false,
        match = '[a-zA-z0-9]',
      }
      vim.api.nvim_set_hl(0, 'EyelinerPrimary', { fg = '#ffff00', underline = true, italic = true })
      vim.api.nvim_set_hl(0, 'EyelinerSecondary', { fg = '#ff00ff', underline = true, italic = true })
    end,
  },

  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'debugloop/telescope-undo.nvim',
    },
    opts = {
      extensions = {
        undo = {},
      },
    },
  },
  {
    'ariel-frischer/bmessages.nvim',
    event = 'CmdlineEnter',
    opts = {},
  },
  {
    'axkirillov/easypick.nvim',
    config = function()
      local easypick = require 'easypick'
      easypick.setup {
        pickers = {
          {
            name = 'changed_files',
            command = 'git diff --name-only',
            previewer = easypick.previewers.file_diff { cwd = git_root },
          },
        },
      }
    end,
  },
  ---@diagnostic disable-next-line: missing-fields
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- Load the colorscheme here.
-- Like many other themes, this one has different styles, and you could load
-- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
vim.cmd.colorscheme 'tokyonight-night'

vim.filetype.add {
  extension = {
    ['fx'] = 'glsl',
  },
  filename = {
    ['.gitconfig'] = 'ini',
  },
}

vim.keymap.set('i', 'kk', '<Esc>:w<CR>', { silent = true })
vim.keymap.set('n', '<leader>vr', ':%s/\\s\\+$//e', { desc = 't[r]im trailing whitespaces', noremap = true })
vim.keymap.set(
  'n',
  '<leader>vu',
  ':%s/\\\\u\\(\\x\\{4\\}\\)/\\=nr2char(str2nr(submatch(1),16))/g',
  { desc = 'convert \\uABCD escape sequences to actual codepoint', noremap = true, silent = true }
)
vim.keymap.set('v', '<leader>vU', function()
  local selected = table.concat(vim.fn.getregion(vim.fn.getpos 'v', vim.fn.getpos '.', { type = vim.fn.mode() }))
  local function toEscaped(input_string)
    if not input_string or #input_string == 0 then
      return ''
    end

    local output_parts = {}
    local num_chars = vim.fn.strchars(input_string)

    for char_idx = 0, num_chars - 1 do
      local char = vim.fn.strcharpart(input_string, char_idx, 1)
      local codepoint = vim.fn.char2nr(char)
      local escaped_char = vim.fn.printf('\\u%04X', codepoint)
      table.insert(output_parts, escaped_char)
    end

    return table.concat(output_parts)
  end
  local escaped = toEscaped(selected)

  vim.fn.setreg('q', escaped, 'v')
  vim.cmd 'normal! "qp'
end, { desc = 'convert unicode characters to \\uABCD escape sequences', noremap = true, silent = true })
vim.keymap.set('n', '<leader>va', 'm0gg<S-v><S-g>', { desc = "select [a]ll in buffer, use '0 to go back", noremap = true, silent = true })

-- warns if buffer is modified by others
local my_config = vim.api.nvim_create_augroup('my-config', {})
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  group = my_config,
  pattern = '*',
  command = ':checktime',
})

-- :Here to open buffer file parent
vim.api.nvim_create_user_command('Here', ':e %:h', { desc = 'open buffer file parent' })
vim.api.nvim_create_user_command('Ex', ':e %:h', { desc = 'open buffer file parent' })
vim.keymap.set('n', '-', '<cmd>Ex<cr>', { desc = 'open buffer file parent' })

-- git log search
vim.keymap.set('v', '<leader>l', function()
  local start_pos = vim.fn.getpos 'v'
  local end_pos = vim.fn.getcurpos()

  local endpoints = { start_pos[2], end_pos[2] }
  table.sort(endpoints, function(lhs, rhs)
    return lhs < rhs
  end)

  local start_line = endpoints[1]
  local end_line = endpoints[2]
  local cmd = '<cmd>' .. start_line .. ',' .. end_line .. 'DiffviewFileHistory<cr>'
  return cmd
end, { desc = 'git [l]og', expr = true })

-- resize window
vim.keymap.set({ 'i', 'n' }, '<C-Down>', '<C-W>-', { desc = 'decrease height', noremap = true, silent = true })
vim.keymap.set({ 'i', 'n' }, '<C-Up>', '<C-W>+', { desc = 'increase height', noremap = true, silent = true })
vim.keymap.set({ 'i', 'n' }, '<C-Right>', '<C-W><', { desc = 'decrease width', noremap = true, silent = true })
vim.keymap.set({ 'i', 'n' }, '<C-Left>', '<C-W>>', { desc = 'increase width', noremap = true, silent = true })
vim.keymap.set({ 'i', 'n' }, '<C-t>', '<C-W>T', { desc = 'move to a new tabpage', noremap = true, silent = true })

vim.opt.fillchars:append { diff = '╱' }

vim.keymap.set('n', '88', '<cmd>w<cr>', { desc = 'alias of :w' })
require('which-key').add { '88', hidden = true }

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  callback = function()
    -- press <C-q> then the Esc key to enter ^[
    vim.fn.setreg('c', '"8yoconsole.log(\'libq Z\', "8pa)TZch')
    vim.fn.setreg('d', "oconsole.log('libq ')hi")
  end,
})

require('conform').formatters.prettierd = {
  range_args = function(_, ctx)
    local bufnr = ctx.buf
    local start = ctx.range.start[1]
    local last = ctx.range['end'][1]

    local lines_before_start = start - 1
    local lines_in_range = last - start + 1
    local eol_len = vim.bo[bufnr].fileformat == 'dos' and 2 or 1
    local eol_before_start = lines_before_start * eol_len
    local eol_in_range = lines_in_range * eol_len
    book.debug(
      'libq rangeargs/enter',
      'ctx',
      ctx,
      'lines_before_start',
      lines_before_start,
      'lines_in_range',
      lines_in_range,
      'eol_len',
      eol_len,
      'eol_before_start',
      eol_before_start,
      'eol_in_range',
      eol_in_range
    )

    local start_by_char = ctx.range.offset_table[start - 1] + eol_before_start
    local end_by_char = ctx.range.offset_table[last] + eol_before_start + eol_in_range

    book.info('libq rangeargs/startend', start_by_char, end_by_char)
    return { '$FILENAME', '--range-start=' .. start_by_char, '--range-end=' .. end_by_char }
  end,
}

vim.keymap.set('x', '<leader>vr', ":'<,'>lua<CR>", { desc = '[r]un visual selection as Lua' })

vim.opt.fileformats = 'unix,dos'

book = require('logger'):new { log_level = 'debug', prefix = 'libq', echo_messages = true }
local show_libq_debug_log = false
local function sync_logger_level()
  if true == show_libq_debug_log then
    book.set_log_level(vim.log.levels.DEBUG)
  else
    book.set_log_level(vim.log.levels.OFF)
  end
end
sync_logger_level()
vim.keymap.set('n', '<leader>td', function()
  show_libq_debug_log = not show_libq_debug_log
  sync_logger_level()
  vim.notify('libq debug: ' .. (show_libq_debug_log and 'on' or 'off'))
end, { desc = '[d]ebug messages', noremap = true })

vim.api.nvim_set_keymap('n', '<C-t><C-t>', ':tabc<CR>', { noremap = true, silent = true })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
