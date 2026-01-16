local notify_record = nil
local ns_id = vim.api.nvim_create_namespace 'marks_notify'

local function update_marks_display()
  local bufnr = vim.api.nvim_get_current_buf()
  local raw_marks = {}
  local charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

  -- 1. 获取所有标记数据
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
      table.insert(raw_marks, { char = char, row = row, content = line_content })
    end
  end

  -- 2. 按照行号从小到大排序
  table.sort(raw_marks, function(a, b)
    return a.row < b.row
  end)

  -- 3. 准备显示文本和高亮位置
  local marks_data = {}
  local highlights = {}
  for _, m in ipairs(raw_marks) do
    local row_str = tostring(m.row)
    local line_text = string.format('%s %s %s', m.char, row_str, m.content)
    table.insert(marks_data, line_text)
    table.insert(highlights, {
      char_end = #m.char,
      row_start = #m.char + 1,
      row_end = #m.char + 1 + #row_str,
      content_start = #m.char + 1 + #row_str + 1,
    })
  end

  if #marks_data == 0 then
    marks_data = { 'No Marks' }
  end

  -- 添加随机后缀规避 nvim-notify 的 x2 计数合并
  table.insert(marks_data, string.format(' %f', os.clock()))

  local notify = require 'notify'
  local res = notify(marks_data, 'info', {
    title = 'Marks',
    timeout = false,
    animate = false,
    replace = notify_record,
    render = function(buf, notif, hl)
      local display_content = {}
      for i = 1, #notif.message - 1 do
        table.insert(display_content, notif.message[i])
      end

      -- 设置内容
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, display_content)

      -- 应用自定义高亮
      vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
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

-- 1. 仅保留 Buffer 切换事件
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  callback = update_marks_display,
})

-- 2. 设置定时轮询，间隔 1000 毫秒
local timer = vim.loop.new_timer()
timer:start(
  1000,
  1000,
  vim.schedule_wrap(function()
    update_marks_display()
  end)
)
