local Buffer = require("tidal.util.buffer")

---@class Sclang
---@field buf Buffer
---@field proc integer

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
---@field window? table

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

  self.buf:show(opts.window)

  self.proc = vim.fn.jobstart(vim.list_extend({ opts.cmd }, opts.args), {
    term = true,
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
  vim.api.nvim_chan_send(self.proc, text)
  self.buf:scroll_to_bottom()
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

--- Close the REPL
function Sclang:exit()
  if self.proc then
    vim.fn.jobstop(self.proc)
  end
end

return Sclang
