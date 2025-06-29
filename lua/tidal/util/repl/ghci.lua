local Repl = require("tidal.util.repl.repl")

---@class Ghci : Repl
---@field buf Buffer
---@field proc integer
local Ghci = Repl:new()
Ghci.__index = Ghci

--- Send multi-line text to GHCi
---@param lines string[]
function Ghci:send_multiline(lines)
	local send_str = ":{\n" .. table.concat(lines, "\n") .. "\n:}"
	send_str = send_str:gsub("\t", " ")
	return self:send_line(send_str)
end

return Ghci
