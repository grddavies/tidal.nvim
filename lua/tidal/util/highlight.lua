local config = require("tidal.config")
local ns = config.namespace
local hl_opts = config.options.selection_highlight

local M = {}

local api = vim.api

---@type string | table<string, any>
local style = {}
if type(hl_opts.highlight) == "string" then
  style = api.nvim_get_hl(0, { name = hl_opts.highlight })
elseif type(hl_opts.highlight) == "table" then
  style = hl_opts.highlight
end
---@cast style table<string, any>
local higroup = "TidalSent"
api.nvim_set_hl_ns(ns)
api.nvim_set_hl(ns, higroup, style)

local timeout = hl_opts.timeout

local hl_timer

--- Apply a transient highlight to a range in the current buffer
---@param start { [1]: integer, [2]: integer } Start position {line, col}
---@param finish { [1]: integer, [2]: integer } Finish position {line, col}
function M.apply_highlight(start, finish)
  local event = vim.v.event
  local bufnr = api.nvim_get_current_buf()
  api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  if hl_timer then
    hl_timer:close()
  end

  vim.highlight.range(
    bufnr,
    ns,
    higroup,
    start,
    finish,
    { regtype = event.regtype, inclusive = event.inclusive, priority = vim.highlight.priorities.user }
  )

  hl_timer = vim.defer_fn(function()
    hl_timer = nil
    if api.nvim_buf_is_valid(bufnr) then
      api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    end
  end, timeout)
end

return M
