local message = require("tidal.core.message")
local state = require("tidal.core.state")
local scd = require("tidal.util.scd")

local M = {}

---Start a tidal repl
---@param args TidalProcConfig
function M.tidal(args)
  if not args.enabled then
    return
  end
  if state.ghci.buf then
    local ok = pcall(vim.api.nvim_set_current_buf, state.ghci.buf)
    if not ok then
      state.ghci.buf = nil
      M.tidal(args)
      return
    end
  else
    state.ghci.buf = vim.api.nvim_create_buf(false, false)
    M.tidal(args)
    return
  end
  state.ghci.proc = vim.fn.jobstart(
    args.cmd .. " -XOverloadedStrings " .. table.concat(args.args, " ") .. " -ghci-script=" .. args.file,
    {
      term = true,
      on_exit = function()
        if state.ghci.buf ~= nil and #vim.fn.win_findbuf(state.ghci.buf) > 0 then
          vim.api.nvim_win_close(vim.fn.win_findbuf(state.ghci.buf)[1], true)
        end
        vim.api.nvim_buf_delete(state.ghci.buf, {})
        state.ghci.buf = nil
        state.ghci.proc = nil
      end,
    }
  )
end

---Start an sclang instance
---@param args TidalProcConfig
function M.sclang(args)
  if not args.enabled then
    return
  end
  if state.sclang.buf then
    local ok = pcall(vim.api.nvim_set_current_buf, state.sclang.buf)
    if not ok then
      state.sclang.buf = nil
      M.sclang(args)
    end
  else
    state.sclang.buf = vim.api.nvim_create_buf(false, false)
    M.sclang(args)
    return
  end

  state.sclang.proc = vim.fn.termopen(args.cmd, {
    term = true,
    on_exit = function()
      if state.sclang.buf ~= nil and #vim.fn.win_findbuf(state.sclang.buf) > 0 then
        vim.api.nvim_win_close(vim.fn.win_findbuf(state.sclang.buf)[1], true)
      end
      vim.api.nvim_buf_delete(state.sclang.buf, {})
      state.sclang.buf = nil
      state.sclang.proc = nil
    end,
  })

  local lines;
  if scd.file_exists(args.glob) then
    lines = scd.lines_from(args.glob)
  elseif scd.file_exists(args.file) then
    lines = scd.lines_from(args.file)
  else
    return
  end
  message.send_multiline(lines, 'sc')
end

return M
