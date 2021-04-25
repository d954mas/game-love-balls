local COMMON = require "libs.common"
local GUI = require "libs_project.gui.gui"
local WORLD = require "world.world"

---@class SoundMusicGuiScriptBase
local Script = COMMON.new_n28s()

function Script:bind_vh()
    self.vh = {}
    self.view = {
        btn_sound = GUI.ButtonScale("btn_sound"),
        btn_music = GUI.ButtonScale("btn_music"),
    }
end

function Script:init_gui()
    self.view.btn_music:set_input_listener(function()
        WORLD.storage.options:music_set(not WORLD.storage.options:music_get())
    end)
    self.view.btn_sound:set_input_listener(function()
        WORLD.storage.options:sound_set(not WORLD.storage.options:sound_get())
    end)
end

function Script:on_storage_changed()
    gui.play_flipbook(self.view.btn_sound.vh.root,
            COMMON.HASHES.hash(WORLD.storage.options:sound_get() and "btn_sound_on" or "btn_sound_off"))
    gui.play_flipbook(self.view.btn_music.vh.root,
            COMMON.HASHES.hash(WORLD.storage.options:music_get() and "btn_music_on" or "btn_music_off"))
end

function Script:init()
    self:bind_vh()
    self.subscription = COMMON.RX.SubscriptionsStorage()
    self.scheduler = COMMON.RX.CooperativeScheduler.create()
    self.subscription:add(COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.STORAGE_CHANGED):go_distinct(self.scheduler):subscribe(function()
        self:on_storage_changed()
    end))
    self:init_gui()
    self:on_storage_changed()
end

function Script:on_input(action_id, action)
    if (self.view.btn_music:on_input(action_id, action)) then return true end
    if (self.view.btn_sound:on_input(action_id, action)) then return true end
end

function Script:update(dt)
    self.scheduler:update(dt)
end

function Script:final()
    self.subscription:unsubscribe()
end


return Script