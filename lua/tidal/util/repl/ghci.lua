local Buffer = require("tidal.util.buffer")

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
---@field window? table

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

--- Send text to GHCi
function Ghci:send(text)
  vim.api.nvim_chan_send(self.proc, text)
  self.buf:scroll_to_bottom()
end

--- Send line of text to GHCi
---@param text string
function Ghci:send_line(text)
  self:send(text .. "\n")
end

--- Send multi-line text to GHCi
---@param lines string[]
function Ghci:send_multiline(lines)
  self:send_line(":{\n" .. table.concat(lines, "\n") .. "\n:}")
end

--- Close the REPL
function Ghci:exit()
  if self.proc then
    vim.fn.jobstop(self.proc)
  end
end

return Ghci
