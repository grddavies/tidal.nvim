local Buffer = require("tidal.util.buffer")
local Process = require("tidal.util.process")

---@class Ghci
---@field buf Buffer
---@field proc Process

local Ghci = {}
Ghci.__index = Ghci

---@class GhciOpts
---@field cmd string
---@field args? table<string> additional arguments to for GHCi
---@field name? string repl buffer name
---@field on_exit fun(code: number, signal: number)?

--- Create a new GHCi REPL
--- @param opts? GhciOpts
function Ghci.new(opts)
  opts = opts or {}
  local self = setmetatable({}, Ghci)
  self.buf = Buffer.new({
    name = opts.name,
    scratch = true,
    listed = false,
  })
  self.buf:set_option("buftype", "nofile")
  self.buf:set_option("swapfile", false)
  self.buf:set_option("undolevels", -1)

  self.proc = Process.new(opts.cmd, opts.args or {}, {
    on_stdout = function(data)
      self.buf:append(data)
    end,
    on_stderr = function(data)
      self.buf:append(data)
    end,
    on_exit = function(code, signal)
      self.buf:delete()
      if opts.on_exit then
        opts.on_exit(code, signal)
      end
    end,
  })
  return self
end

--- Send text to ghci
function Ghci:send(text)
  self.buf:append(text)
  self.proc.stdin:write(text)
end

--- Send line of text to ghci and evaluate
---@param text string
function Ghci:send_line(text)
  self:send(text .. "\n")
end

--- Send multiline text to ghci
---@param lines string[]
function Ghci:send_multiline(lines)
  self:send_line(":{\n" .. table.concat(lines, "\n") .. "\n:}")
end

return Ghci
