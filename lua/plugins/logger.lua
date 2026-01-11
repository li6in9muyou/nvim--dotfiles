return {
  'rmagatti/logger.nvim',
  lazy = false,
  config = function()
    _G.book = require('logger'):new { log_level = 'debug', prefix = 'libq', echo_messages = true }
    _G.console = _G.book
    _G.console.log = _G.book.debug
  end,
}
