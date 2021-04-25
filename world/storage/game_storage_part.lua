local COMMON = require "libs.common"
local StoragePart = require "world.storage.storage_part_base"

---@class GamePartOptions:StoragePartBase
local Storage = COMMON.class("GamePartOptions", StoragePart)

function Storage:initialize(...)
    StoragePart.initialize(self, ...)
    self.game = self.storage.data.game
end

return Storage