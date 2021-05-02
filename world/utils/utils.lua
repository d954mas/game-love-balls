local COMMON = require "libs.common"

local Utils = COMMON.class("WorldUtils")

---@param world World
function Utils:initialize(world)
    checks("?", "class:World")
    self.world = world
end

return Utils