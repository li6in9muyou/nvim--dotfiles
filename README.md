# DIY bootstraping

## dictionary file

## install ripgrep

## build MarkdownPreview

# nvim config todo

- [ ] seach `git log -s -L${v_start},${v_end}:${current_buffer}` with Telescope
- [ ] how about 'mini.git'
- [ ] telescope preview from `:AdvancdGitSearch` can not scroll, something is wrong with advanced-git-search, `:Telescope git_bcommits` can scroll.
- [ ] disable `<c-l|h|j|k>` key binds from oil
- [ ] figure out what is going on here, I was editing a file in `%TEMP%`

  > Error detected while processing BufWritePre Autocommands for "\*":
  > Error executing lua callback: ...ata/Local/nvim-data/lazy/conform.nvim/lua/conform/fs.lua:76: assertion failed!
  > stack traceback:
  > [C]: in function 'assert'
  > ...ata/Local/nvim-data/lazy/conform.nvim/lua/conform/fs.lua:76: in function 'relative_path'
  > ...Local/nvim-data/lazy/conform.nvim/lua/conform/runner.lua:40: in function 'build_cmd'
  > ...Local/nvim-data/lazy/conform.nvim/lua/conform/runner.lua:291: in function 'run_formatter'
  > ...Local/nvim-data/lazy/conform.nvim/lua/conform/runner.lua:633: in function 'format_lines_sync'
  > ...Local/nvim-data/lazy/conform.nvim/lua/conform/runner.lua:589: in function 'format_sync'
  > ...a/Local/nvim-data/lazy/conform.nvim/lua/conform/init.lua:451: in function 'format'
  > ...a/Local/nvim-data/lazy/conform.nvim/lua/conform/init.lua:104: in function <...a/Local/nvim-data/lazy/conform.nvim/lua/conform/init.lua:95>

- [ ] show diagnostics in top-right corner https://github.com/dgagn/diagflow.nvim
- [ ] clean up '<leader>s' keymaps
- [ ] do not capitalize letter in which-key popup
- [ ] complete _DIY bootstraping_ section
- [x] auto complete workspace file names
- [x] Emmet
- [x] Dictionary auto completeion does not work out-of-the-box
- [x] MarkdownPreview does not work out-of-the-box
- [x] shell path should not be absolute path, use `pwsh` if possible
- [x] LSP diagnostics are append to line end and they does not wrap, so sometimes they are not readable at all. This is reverted in last two commits, it's just annoying.
- [x] limit length of auto completion list from dictionary
- [x] remove trailing spaces before newline
- [x] cmp-dictionary, when `max_number_items` is set, inputting "righ" does not suggest "right". see `C:/Users/Li6q/AppData/Local/nvim-data/lazy/cmp-dictionary/lua/cmp_dictionary/source.lua`. Changing config in `nvim-cmp` can work around this.
- [x] telescope grip current dir recursively does not work, fix it! fix: this requires ripgrip.
