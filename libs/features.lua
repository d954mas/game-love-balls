local COMMON = require "libs.common"

---@class Features
local Features = COMMON.class("Features")

function Features:initialize()
    self.features_base = {
        debug_gui = false,
        resizer = false,
        show_dt = false
    }
end

function Features:debug_config()
    self.features_base.debug_gui = true
    self.features_base.resizer = COMMON.CONSTANTS.PLATFORM_IS_PC
    self.features_base.show_dt = true

end
function Features:prod_config()

end

function Features:load()
    if(self.features_base.debug_gui)then
        collectionfactory.create("/features#factory_debug_gui")
    end
    if(self.features_base.resizer)then
        collectionfactory.create("/features#factory_resizer")
    end
    if(self.features_base.show_dt)then
        collectionfactory.create("/features#factory_show_dt")
    end
end

return Features