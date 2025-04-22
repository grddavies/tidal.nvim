local state = require("tidal.core.state")
local select = require("tidal.util.select")
local notify = require("tidal.util.notify")

local M = {}

--- Send a command to the tidal interpreter
---@param text string
function M.send(text)
  local buf = vim.api.nvim_get_current_buf()
  local ftype = vim.api.nvim_get_option_value('filetype', { buf = buf })

  if ftype == 'haskell' then
    if not state.ghci.proc then
      return
    end
    vim.api.nvim_chan_send(state.ghci.proc, text .. "\n")
  elseif ftype == 'supercollider' then
    if not state.sclang.proc then
      return
    end
    vim.api.nvim_chan_send(state.sclang.proc, text .. "\n")
  end
end

--- Send a multiline command to the tidal interpreter
---@param lines string[]
function M.send_multiline(lines)
  M.send(":{\n" .. table.concat(lines, "\n") .. "\n:}")
end

--- Send a text contained in a motion to the tidal interpreter
---@param motion "line" | "char" | "block"
function M.send_motion(motion)
  local motions = { char = true, block = true }
  if motions[motion] then
    notify.warn(motion .. "-wise motions not implemented")
  end
  M.send_multiline(select.get_motion_text())
end

--- Enter operator pending mode to send text to tidal interpreter
function M.set_operator_pending()
  vim.o.operatorfunc = "v:lua.require'tidal.core.message'.send_motion"
  return "g@"
end

return M
