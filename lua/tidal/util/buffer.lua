---@class Buffer
---@field bufnr integer

local Buffer = {}
Buffer.__index = Buffer

---@class BufferOpts
---@field name? string
---@field listed? boolean
---@field scratch? boolean
function Buffer.new(opts)
  local self = setmetatable({}, Buffer)
  opts = vim.tbl_extend("force", {
    listed = true,
    scratch = false,
  }, opts)

  self.bufnr = vim.api.nvim_create_buf(opts.listed, opts.scratch)
  if opts.name then
    vim.api.nvim_buf_set_name(self.bufnr, opts.name)
  end
  return self
end

function Buffer:set_option(name, value)
  vim.api.nvim_set_option_value(name, value, { buf = self.bufnr })
end

function Buffer:delete()
  vim.api.nvim_buf_delete(self.bufnr, { force = true })
end

---Show the buffer in a window
---@param win_opts table|nil Window options
---  - split: string|nil - Split type ('', 'v', 'h')
---  - win: number|nil - Window to use (default: current window)
---@return number|nil win_id Window ID or nil on failure
function Buffer:show(win_opts)
  if not vim.api.nvim_buf_is_valid(self.bufnr) then
    return nil
  end

  win_opts = win_opts or {}
  local win_id = win_opts.win or 0

  if win_opts.split then
    if win_opts.split == "v" then
      vim.cmd("vsplit")
    elseif win_opts.split == "h" then
      vim.cmd("split")
    end
    win_id = vim.api.nvim_get_current_win()
  end

  -- Set the buffer in the window
  vim.api.nvim_win_set_buf(win_id, self.bufnr)
  return win_id
end

function Buffer:append(text)
  local bufnr = self.bufnr
  local lines = vim.split(text, "\n")
  if #lines > 0 then
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local last_line = vim.api.nvim_buf_get_lines(bufnr, line_count - 1, line_count, false)[1]
    -- Append to the first line in our list
    lines[1] = last_line .. lines[1]
    -- Replace the last line and add any additional lines
    vim.api.nvim_buf_set_lines(bufnr, line_count - 1, line_count, false, lines)

    -- Auto-scroll if buffer is visible in a window
    local windows = vim.fn.win_findbuf(bufnr)
    for _, win in ipairs(windows) do
      vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(bufnr), 0 })
    end
  end
end

return Buffer
