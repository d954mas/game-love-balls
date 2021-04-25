local COMMON = require "libs.common"
local StoragePart = require "world.storage.storage_part_base"

---@class DebugStoragePart:StoragePartBase
local Debug = COMMON.class("DebugStoragePart", StoragePart)

function Debug:initialize(...)
    StoragePart.initialize(self, ...)
    self.debug = self.storage.data.debug
end

function Debug:developer_is() return self.debug.developer end
function Debug:developer_set(enable)
    self.debug.developer = enable
    self:save_and_changed()
end

return Debug