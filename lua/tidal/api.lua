local boot = require("tidal.core.boot")
local message = require("tidal.core.message")
local state = require("tidal.core.state")
local util = require("tidal.util")
local notify = require("tidal.util.notify")
local select = require("tidal.util.select")
-- Lazily require highlight module to ensure 'setup' is called before

local M = {}

--- Begin a Tidal session
--- Will start an sclang instance if specified in config
---@param args TidalBootConfig
function M.launch_tidal(args)
  local current_win = vim.api.nvim_get_current_win()
  if state.launched then
    notify.warn("Tidal is already running")
    return
  end
  if args.tidal.enabled then
    vim.cmd(args.split == "v" and "vsplit" or "split")
    boot.tidal(args.tidal)
  end
  if args.sclang.enabled then
    vim.cmd(args.split == "v" and "split" or "vsplit")
    boot.sclang(args.sclang)
  end
  -- Follow terminal output
  if state.ghci.buf then
    vim.api.nvim_buf_call(state.ghci.buf, function()
      vim.cmd.normal("G")
    end)
  end
  if state.sclang.buf then
    vim.api.nvim_buf_call(state.sclang.buf, function()
      vim.cmd.normal("G")
    end)
  end
  vim.api.nvim_set_current_win(current_win)
  state.launched = true
end

--- Quit Tidal session
function M.exit_tidal()
  if not state.launched then
    notify.warn("Tidal is not running. Launch with ':TidalLaunch'")
    return
  end
  if state.ghci.proc then
    vim.fn.jobstop(state.ghci.proc)
  end
  if state.sclang.proc then
    vim.fn.jobstop(state.sclang.proc)
  end
  state.launched = false
end

M.send = message.send

-- Send 'd{count} silence' to tidal interpreter to silence a pattern d1-d16
M.send_silence = function()
  message.send(string.format("d%d silence", vim.v.count1), 'tc')
end

M.send_multiline = message.send_multiline

--- Send the current line to the tidal interpreter
M.send_line = function()
  local line = select.get_current_line()
  local text = line.lines[1]
  if #text > 0 then
    require("tidal.util.highlight").apply_highlight(line.start, line.finish)
    M.send(text)
  end
end

--- Send the last visual selection to the tidal interpreter
M.send_visual = function()
  local visual = select.get_visual()
  if visual then
    require("tidal.util.highlight").apply_highlight(visual.start, visual.finish)
    message.send_multiline(visual.lines)
  end
end

--- Send the current block to tidal interpreter
M.send_block = function()
  if util.is_empty(vim.api.nvim_get_current_line()) then
    return
  end
  local block = select.get_block()
  require("tidal.util.highlight").apply_highlight(block.start, block.finish)
  message.send_multiline(block.lines)
end

--- Send current TS block to tidal interpreter
function M.send_node()
  local block = select.get_node()
  if block then
    require("tidal.util.highlight").apply_highlight(block.start, block.finish)
    message.send_multiline(block.lines)
  end
end

return M
