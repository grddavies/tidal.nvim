local select = require("tidal.util.select")
local notify = require("tidal.util.notify")
local scd = require("tidal.util.scd")

local M = {}

--- Send a command to the tidal interpreter
---@param text string
function M.send(text)
  local _, proc = scd.filetype()

  if not proc then
    return
  end

  vim.api.nvim_chan_send(proc, text .. "\n")
end

--- Send a multiline command to the tidal interpreter
---@param lines string[]
function M.send_multiline(lines)
  local ftype, _ =  scd.filetype()

  if ftype == 'haskell' then
    M.send(":{\n" .. table.concat(lines, "\n") .. "\n:}")
  elseif ftype == 'supercollider' then
    M.send(scd.scd_concat(lines))
  end
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
