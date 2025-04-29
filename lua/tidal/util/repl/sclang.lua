local Buffer = require("tidal.util.buffer")
local Process = require("tidal.util.process")

---@class Sclang
---@field buf Buffer
---@field proc Process

local Sclang = {}
Sclang.__index = Sclang

local keycodes = {
  interpret_print = string.char(0x0c),
  interpret = string.char(0x1b),
  recompile = string.char(0x18),
}

---@class SclangOpts
---@field cmd string
---@field args? table<string> additional arguments to for sclang
---@field name? string repl buffer name
---@field on_exit fun(code: number, signal: number)?

--- Create a new sclang REPL
--- @param opts? SclangOpts
function Sclang.new(opts)
  opts = opts or {}
  local self = setmetatable({}, Sclang)
  self.buf = Buffer.new({
    name = opts.name,
    scratch = true,
    listed = false,
  })
  self.proc = Process.new(opts.cmd, opts.args or {}, {
    on_stdout = function(data)
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

--- Send text to sclang
function Sclang:send(text)
  self.buf:append(text)
  self.proc.stdin:write(text)
end

--- Send line of text to sclang and evaluate
---@param text string
function Sclang:send_line(text)
  self:send(text .. keycodes.interpret_print)
end

--- Send multiline text to ghci
---@param lines string[]
function Sclang:send_multiline(lines)
  self:send_line(table.concat(lines, "\n"))
end

return Sclang
