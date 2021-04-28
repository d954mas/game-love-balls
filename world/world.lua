local COMMON = require "libs.common"
local Storage = require "world.storage.storage"
local GameWorld = require "world.game.game_world"
local CommandExecutor = require "world.commands.command_executor"
local Balance = require "world.balance.balance"
local Ads = require "libs.ads.ads"
local Utils = require "world.utils.utils"
local SOUNDS = require "libs.sounds"

local TAG = "WORLD"
---@class World
local M = COMMON.class("World")

function M:initialize()
    COMMON.i("init", TAG)
    self.subscription = COMMON.RX.SubscriptionsStorage()
    self.scheduler = COMMON.RX.CooperativeScheduler.create()
    self.storage = Storage(self)
    self.command_executor = CommandExecutor()
    self.balance = Balance(self)
    self.game = GameWorld(self)
    self.ads = Ads(self)
    self.utils = Utils(self)
    self.sounds = SOUNDS
    self.sounds.world = self
    self.sounds:on_storage_changed()

    self.subscription:add(COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.WINDOW_RESIZED)
                                :go_distinct(self.scheduler):subscribe(function()
        self:on_resize()
    end))
end

function M:update(dt)
    self.command_executor:act(dt)
    self.storage:update(dt)
end

function M:on_resize()
    self.game:on_resize()
end

function M:on_storage_changed()

end

function M:final()
    COMMON.i("final", TAG)
    self.subscription:unsubscribe()
    self.subscription = nil
end

return M()