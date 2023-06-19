---@class TidalProcState
---@field buf? integer
---@field proc? integer

---@class TidalState
local state = {
  ---@type boolean
  launched = false,
  ---@type TidalProcState
  ghci = {},
  ---@type TidalProcState
  sclang = {},
}

return state
