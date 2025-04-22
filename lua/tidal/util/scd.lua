local state = require("tidal.core.state")

local M = {}

function M.file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function M.lines_from(file)
  if not M.file_exists(file) then return {} end
  local lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line:gsub('//.*$', '')
  end
  return lines
end

function M.scd_concat(lines)
  --- strip comments
  for k,v in pairs(lines) do
    lines[k] = v:gsub('//.*$', '')
  end
  return table.concat(lines, " "):gsub('/%*.*%*/', '')
end

function M.filetype()
  local buf = vim.api.nvim_get_current_buf()
  local ftype = vim.api.nvim_get_option_value('filetype', { buf = buf })
  local proc

  if ftype == 'haskell' then
    proc = state.ghci.proc
  elseif ftype == 'supercollider' then
    proc = state.sclang.proc
  end

  return ftype, proc

end

return M
