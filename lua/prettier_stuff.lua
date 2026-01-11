require('conform').formatters.prettierd = {
  range_args = function(_, ctx)
    time 'libq rangeargs'
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
    time_end 'libq rangeargs'
    return { '$FILENAME', '--range-start=' .. start_by_char, '--range-end=' .. end_by_char }
  end,
}

local M = {}

local is_current_buffer_untracked = require('git_stuff').is_current_buffer_untracked

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

function M.format_hunks(bufnr)
  time 'libq fmthunks'
  local hunks = require('gitsigns').get_hunks(bufnr)

  if is_current_buffer_untracked() then
    book.debug 'libq fmthunk/wholefile because it is untracked'
    require('conform').format(DEFAULT_CONFORM_OPT())
    return
  end

  if hunks == nil then
    book.debug 'libq fmthunk/skip because hunks is nil'
    return
  end

  local offset_table = count_char_offsets_for_hunks(bufnr, hunks)

  local format = require('conform').format
  for i = #hunks, 1, -1 do
    time('libq fmthunks/fmt ' .. i)
    local hunk = hunks[i]
    book.debug('libq fmthunk/hunk', hunk)
    if hunk ~= nil and hunk.type ~= 'delete' then
      local start = hunk.added.start
      local last = start + hunk.added.count
      -- nvim_buf_get_lines uses zero-based indexing -> subtract from last
      local last_hunk_line = vim.api.nvim_buf_get_lines(0, last - 2, last - 1, true)[1]
      local range = { start = { start, 0 }, ['end'] = { last - 1, last_hunk_line:len() }, offset_table = offset_table }
      time('libq fmthunk/conformformat ' .. i)
      format(RANGE_CONFORM_OPT(range))
      time_end('libq fmthunk/conformformat ' .. i)
    else
      book.debug 'libq fmthunk/skip hunk.type==delete'
    end
    time_end('libq fmthunks/fmt ' .. i)
  end
  time_end 'libq fmthunks'
end

return M
