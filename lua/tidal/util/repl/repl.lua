local Buffer = require("tidal.util.buffer")

---@class Repl
---@field buf Buffer
---@field proc? integer
---@field opts ReplOpts
local Repl = {}
Repl.__index = Repl

---@class ReplOpts
---@field cmd string
---@field args? table<string> additional arguments to for GHCi
---@field name? string repl buffer name
---@field on_exit fun(code: number, signal: number)?

--- Create a new REPL
--- @generic T - generic type for type inference on child 'classes'
--- @param self T
--- @param opts? ReplOpts
--- @return T for method chaining
function Repl:new(opts)
  opts = opts or {}
  local obj = {}
  setmetatable(obj, self)
  obj.buf = Buffer.new({
    name = opts.name,
    scratch = true,
    listed = false,
  })
  obj.opts = opts

  return obj
end

--- Start the REPL
--- @param opts table|nil Window options
---  - split: string|nil - Split type ('', 'v', 'h')
---  - win: number|nil - Window to use (default: current window)
--- @generic T
--- @return T for method chaining
function Repl:start(opts)
  if self.proc == nil then
    self.buf:show(opts or {})
    self.proc = vim.fn.jobstart(vim.list_extend({ self.opts.cmd }, self.opts.args or {}), {
      term = true,
      on_exit = function(code, signal)
        self.buf:delete()
        if self.opts.on_exit then
          self.opts.on_exit(code, signal)
        end
      end,
    })
  end
  return self
end

--- Send text to REPL
--- @generic T
--- @return T for method chaining
function Repl:send(text)
  if self.proc == nil then
    -- not running - error?
    return self
  end
  vim.api.nvim_chan_send(self.proc, text)
  self.buf:scroll_to_bottom()
  return self
end

--- Send line of text to REPL
---@param text string
--- @generic T
--- @return T for method chaining
function Repl:send_line(text)
  return self:send(text .. "\n")
end

--- Send multi-line text to REPL
--- @param lines string[]
--- @generic T
--- @return T for method chaining
function Repl:send_multiline(lines)
  return self:send_line(table.concat(lines, "\n"))
end

--- Close the REPL
--- @return self for method chaining
function Repl:exit()
  if self.proc then
    -- Removes buffers and closes windows
    vim.fn.jobstop(self.proc)
  end
  return self
end

return Repl
