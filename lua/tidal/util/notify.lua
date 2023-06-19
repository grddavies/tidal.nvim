local M = {}

local title = "Tidal"

function M.warn(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = title })
end

function M.error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = title })
end

return M
