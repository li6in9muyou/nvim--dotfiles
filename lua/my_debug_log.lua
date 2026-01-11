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

