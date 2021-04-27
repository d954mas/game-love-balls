local COMMON = require "libs.common"
local GUI = require "libs_project.gui.gui"
local WORLD = require "world.world"
local CAMERAS = require "libs_project.cameras"

---@class SoundMusicGuiScriptBase
local Script = COMMON.new_n28s()

function Script:bind_vh()
    self.vh = {}
    self.view = {
        btn_sound = GUI.ButtonScale("btn_sound"),
        btn_music = GUI.ButtonScale("btn_music"),
    }
    self.view.btn_sound.vh.icon = gui.get_node("btn_sound/icon")
    self.view.btn_music.vh.icon = gui.get_node("btn_music/icon")
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
    gui.play_flipbook(self.view.btn_sound.vh.icon,
            COMMON.HASHES.hash(WORLD.storage.options:sound_get() and "icon_sound" or "icon_sound_off"))
    gui.play_flipbook(self.view.btn_music.vh.icon,
            COMMON.HASHES.hash(WORLD.storage.options:music_get() and "icon_music" or "icon_music_off"))
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
    local action_new = COMMON.LUME.clone_deep(action)
    local world_coord = CAMERAS.game_camera:screen_to_world_2d(action.screen_x, action.screen_y)
    action_new.x = world_coord.x *  COMMON.RENDER.config_size.w/CAMERAS.game_camera.screen_size.w
    action_new.y = world_coord.y *  COMMON.RENDER.config_size.h/CAMERAS.game_camera.screen_size.h
    if (self.view.btn_music:on_input(action_id, action_new)) then return true end
    if (self.view.btn_sound:on_input(action_id, action_new)) then return true end
end

function Script:update(dt)
    self.scheduler:update(dt)
end

function Script:final()
    self.subscription:unsubscribe()
end


return Script