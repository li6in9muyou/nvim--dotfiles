# DIY bootstraping

## dictionary file

## install ripgrep

## build MarkdownPreview

# nvim config todo

- [ ] migrate this todo list to GitHub Issues
- [ ] seach `git log -s -L${v_start},${v_end}:${current_buffer}` with Telescope
- [x] how about 'mini.git'? Not good, it refuses to show `git log -L` when working tree is dirty.
- [ ] telescope preview from `:AdvancdGitSearch` can not scroll, something is wrong with advanced-git-search, `:Telescope git_bcommits` can scroll.
- [x] disable `<c-l|h|j|k>` key binds from oil
- [x] show diagnostics in top-right corner https://github.com/dgagn/diagflow.nvim. The float window sometimes covers my code which is really annoying.
- [x] clean up '<leader>s' keymaps
- [x] do not capitalize letter in which-key popup
- [ ] complete _DIY bootstraping_ section TODO: do this when I have to set up an nvim on a new machine
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
