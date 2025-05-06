---@class TidalState
local state = {
  ---@type boolean
  launched = false,
  ---@type Ghci?
  ghci = nil,
  ---@type Sclang?
  sclang = nil,
}

return state
