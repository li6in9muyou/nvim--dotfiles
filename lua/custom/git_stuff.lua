local M = {}

function M.is_current_buffer_untracked()
  local filename = vim.fn.expand '%:p'
  book.debug('libq icbu/filename', filename)
  if filename == '' or not vim.fn.filereadable(filename) then
    return false
  end

  local git_root = vim.fn.system { 'git', 'rev-parse', '--show-toplevel' }
  git_root = vim.trim(git_root)

  book.debug('libq icbu/gitroot', git_root)
  if vim.v.shell_error ~= 0 or git_root == '' then
    return false
  end

  git_root = git_root:gsub('\\', '/')
  filename = filename:gsub('\\', '/')

  local relative_path
  local absolute_git_root_len = #git_root
  if string.sub(filename, 1, absolute_git_root_len) == git_root then
    relative_path = string.sub(filename, absolute_git_root_len + 2)
  else
    relative_path = filename
  end

  book.debug('libq icbu/relpath', relative_path)

  local tracked_check = vim.fn.system { 'git', '-C', git_root, 'ls-files', '--error-unmatch', '--', relative_path }
  if vim.v.shell_error == 0 then
    book.debug 'libq icbu/returnfalse tracked_check'
    return false
  end

  local untracked_check = vim.fn.system { 'git', '-C', git_root, 'ls-files', '--others', '--exclude-standard', '--', relative_path }
  if vim.v.shell_error == 0 then
    if vim.trim(untracked_check) == relative_path then
      return true
    end
  end

  book.debug 'libq icbu/returnfalse endoffunction'
  return false
end

return M
