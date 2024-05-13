# DIY bootstraping

## dictionary file

## install ripgrep

## build MarkdownPreview

# nvim config todo

- [ ] show diagnostics in top-right corner https://github.com/dgagn/diagflow.nvim
- [ ] seach `git log -s -L${v_start},${v_end}:${current_buffer}` with Telescope
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
