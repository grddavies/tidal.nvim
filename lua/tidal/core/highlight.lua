local config = require("tidal.config")
local ns = config.namespace
local hl_opts = config.options.selection_highlight

local M = {}

local api = vim.api

local higroup = "TidalSent"

api.nvim_set_hl(0, higroup, hl_opts.highlight)

--- Apply a transient highlight to a range in the current buffer
---@param start { [1]: integer, [2]: integer } Start position {line, col}
---@param finish { [1]: integer, [2]: integer } Finish position {line, col}
function M.apply_highlight(start, finish)
  local event = vim.v.event
  local bufnr = api.nvim_get_current_buf()

  vim.hl.range(bufnr, ns, higroup, start, finish, {
    regtype = event.regtype or "v",
    inclusive = event.inclusive,
    priority = vim.hl.priorities.user,
    timeout = hl_opts.timeout,
  })
end

--- Clear tidal.nvim highlights in all buffers
function M.clear_all()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end
end

return M
