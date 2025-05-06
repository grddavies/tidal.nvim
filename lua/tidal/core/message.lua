local state = require("tidal.core.state")

local M = {}

---@class message.TidalRepl
M.tidal = {}

--- Send text to the tidal interpreter
---@param text string
function M.tidal.send(text)
  if not state.ghci then
    return
  end
  state.ghci:send(text)
end

--- Send a line of text to the tidal interpreter
---@param text string
function M.tidal.send_line(text)
  if not state.ghci then
    return
  end
  state.ghci:send_line(text)
end

--- Send multiline text to the tidal interpreter
---@param lines string[]
function M.tidal.send_multiline(lines)
  if not state.ghci then
    return
  end
  state.ghci:send_multiline(lines)
end

--- --- Send a text contained in a motion to the tidal interpreter
--- ---@param motion "line" | "char" | "block"
--- function M.tidal.send_motion(motion)
---   local motions = { char = true, block = true }
---   if motions[motion] then
---     notify.warn(motion .. "-wise motions not implemented")
---   end
---   M.tidal.send_multiline(select.get_motion_text())
--- end
---
--- --- Enter operator pending mode to send text to tidal interpreter
--- function M.tidal.set_operator_pending()
---   vim.o.operatorfunc = "v:lua.require'tidal.core.message'.tidal.send_motion"
---   return "g@"
--- end

---@class message.SclangRepl
M.sclang = {}

--- Send text to the supercollider interpreter
---@param text string
function M.sclang.send(text)
  if not state.sclang then
    return
  end
  state.sclang:send(text)
end

--- Send a line of text to the tidal interpreter
---@param text string
function M.sclang.send_line(text)
  if not state.sclang then
    return
  end
  state.sclang:send_line(text)
end

--- Send multiline text to the scd interpreter
---@param lines string[]
function M.sclang.send_multiline(lines)
  if not state.sclang then
    return
  end
  state.sclang:send_multiline(lines)
end

return M
