local notify_record = nil
local ns_id = vim.api.nvim_create_namespace 'marks_notify'

local function update_marks_display()
  local bufnr = vim.api.nvim_get_current_buf()
  local marks_data = {}
  local highlights = {}
  local charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

  for i = 1, #charset do
    local char = charset:sub(i, i)
    local mark = vim.api.nvim_buf_get_mark(bufnr, char)
    local row = mark[1]

    if row > 0 then
      local lines = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)
      local line_content = vim.trim(lines[1] or '')
      if #line_content > 60 then
        line_content = line_content:sub(1, 60) .. '...'
      end

      local row_str = tostring(row)
      local line_text = string.format('%s %s %s', char, row_str, line_content)
      table.insert(marks_data, line_text)

      table.insert(highlights, {
        char_end = #char,
        row_start = #char + 1,
        row_end = #char + 1 + #row_str,
        content_start = #char + 1 + #row_str + 1,
      })
    end
  end

  if #marks_data == 0 then
    marks_data = { 'No Marks' }
  end

  local notify = require 'notify'
  -- 在 marks_data 生成后，添加一个微小的差异以规避 x2 计数
  table.insert(marks_data, string.format(' %f', os.clock())) -- 放在数组末尾作为一个隐藏行或仅用于改变哈希

  local res = notify(marks_data, 'info', {
    title = 'Marks',
    timeout = false,
    animate = false,
    replace = notify_record,
    render = function(buf, notif, hl)
      -- 1. 填充内容
      -- 去掉我们最后为了规避 x2 添加的那个时间戳行
      local display_content = {}
      for i = 1, #notif.message - 1 do
        table.insert(display_content, notif.message[i])
      end
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, display_content)

      -- 2. 应用高亮
      -- 注意：render 函数执行时已经处于正确的 buffer 上下文中
      vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)

      -- 这里直接使用你闭包里的 highlights 表
      for i, pos in ipairs(highlights) do
        local line_idx = i - 1
        if line_idx < #display_content then
          vim.api.nvim_buf_add_highlight(buf, ns_id, 'Function', line_idx, 0, pos.char_end)
          vim.api.nvim_buf_add_highlight(buf, ns_id, 'DiagnosticWarn', line_idx, pos.row_start, pos.row_end)
          vim.api.nvim_buf_add_highlight(buf, ns_id, 'WhichKeyValue', line_idx, pos.content_start, -1)
        end
      end
    end,
  })
  notify_record = res
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'CursorHold', 'CursorHoldI' }, {
  callback = update_marks_display,
})
