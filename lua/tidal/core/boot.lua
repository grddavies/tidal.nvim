local Ghci = require("tidal.util.repl.ghci")
local Sclang = require("tidal.util.repl.sclang")
local state = require("tidal.core.state")

local M = {}

---Start a tidal repl
---@param opts TidalProcConfig
function M.tidal(opts)
  if not opts.enabled then
    return
  end

  state.ghci = Ghci.new({
    name = "tidal",
    cmd = opts.cmd,
    args = vim.list_extend({
      "-XOverloadedStrings",
      "-ghci-script=" .. vim.fn.expand(opts.file),
    }, opts.args or {}),
    on_exit = function(_code, _signal)
      state.ghci = nil
    end,
    window = {
      split = "v",
    },
  })
end

---Start an sclang instance
---@param opts TidalProcConfig
function M.sclang(opts)
  if not opts.enabled then
    return
  end

  state.sclang = Sclang.new({
    name = "sclang",
    cmd = opts.cmd,
    args = vim.list_extend({
      "-i",
      "scnvim",
    }, opts.args or {}),
    on_exit = function(_code, _signal)
      state.sclang = nil
    end,
  })

  state.sclang.proc:start()

  local file = vim.fn.expand(opts.file)
  state.sclang:send_line('"' .. file .. '".load;')
end

return M
