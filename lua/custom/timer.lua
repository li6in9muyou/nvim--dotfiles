-- lua/my_timer.lua (or directly in your init.lua)

local timers = {}

--- Starts a timer with a given label.
-- @param label string A unique label for this timer.
function _G.time(label)
  if not label or type(label) ~= 'string' then
    print('time: Label must be a string.')
    return
  end
  timers[label] = vim.uv.hrtime() -- Stores the high-resolution nanosecond timestamp
end

--- Ends a timer and prints the elapsed time.
-- @param label string The label of the timer to end.
function _G.time_end(label)
  if not label or type(label) ~= 'string' then
    vim.notify('time_end: Label must be a string.', vim.log.levels.WARN)
    return
  end

  local start_time = timers[label]
  if not start_time then
    vim.notify('time_end: Timer "' .. label .. '" was not started or already ended.', vim.log.levels.WARN)
    return
  end

  local end_time = vim.uv.hrtime() -- Get current high-resolution nanosecond timestamp

  -- Calculate elapsed time directly in nanoseconds
  local elapsed_ns = end_time - start_time

  -- Convert to milliseconds for readability
  local elapsed_ms = elapsed_ns / 1e6

  print(string.format('Timer "%s": %.3f ms', label, elapsed_ms))

  -- Clean up the timer
  timers[label] = nil
end

-- Example Usage (you can put this in a separate file or comment out after testing)
-- To test, you can source this file or put these calls in your init.lua
-- _G.time("my_long_operation")
--
-- -- Simulate some work
-- for i = 1, 1000000 do
--     local x = math.sin(i) * math.cos(i)
-- end
--
-- _G.time_end("my_long_operation")
--
-- _G.time("another_task")
-- vim.cmd('sleep 500m') -- Simulate 500ms delay
-- _G.time_end("another_task")
