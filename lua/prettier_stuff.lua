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
