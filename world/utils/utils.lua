local COMMON = require "libs.common"
local CAMERAS = require "libs_project.cameras"
local ENUMS = require "world.enums.enums"

local Utils = COMMON.class("WorldUtils")

---@param world World
function Utils:initialize(world)
    checks("?", "class:World")
    self.world = world
end

return Utils