local COMMON = require "libs.common"
local StoragePart = require "world.storage.storage_part_base"

---@class GamePartOptions:StoragePartBase
local Storage = COMMON.class("GamePartOptions", StoragePart)

function Storage:initialize(...)
    StoragePart.initialize(self, ...)
    self.game = self.storage.data.game
end

function Storage:highscore_change(score)
    if score > self.game.highscore then
        self.game.highscore = score
        self:save_and_changed()
    end
end

return Storage