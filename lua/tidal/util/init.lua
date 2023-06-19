local M = {}

---@param line string
function M.is_empty(line)
  return #line:gsub("\\s", "") == 0
end

---@param n integer buffer line number (0-indexed)
function M.line_empty(n)
  local text = vim.api.nvim_buf_get_lines(0, n, n + 1, true)
  return M.is_empty(text[1])
end

return M
