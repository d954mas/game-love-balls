local COMMON = require "libs.common"
local Balance = COMMON.class("Balance")

---@param world World
function Balance:initialize(world)
    checks("?", "class:World")
    self.world = world
    self.config = {

    }
end


return Balance