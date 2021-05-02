local COMMON = require "libs.common"

local TAG = "Sound"
---@class Sounds
local Sounds = COMMON.class("Sounds")

--gate https://www.defold.com/manuals/sound/
function Sounds:initialize()
    self.gate_time = 0.1
    self.gate_sounds = {}
    self.sounds = {
        take_1 = { name = "take_1", url = msg.url("main:/sounds#take_1") },
        take_2 = { name = "take_2", url = msg.url("main:/sounds#take_2") },
        take_3 = { name = "take_3", url = msg.url("main:/sounds#take_3") },
        man_take_1 = { name = "man_take_1", url = msg.url("main:/sounds#man_take_1") },
        man_take_2 = { name = "man_take_2", url = msg.url("main:/sounds#man_take_2") },
        man_take_3 = { name = "man_take_3", url = msg.url("main:/sounds#man_take_3") },
        man_take_4 = { name = "man_take_4", url = msg.url("main:/sounds#man_take_4") }
    }
    self.music = {
        main = { name = "main", url = msg.url("main:/music#main") }
    }
    self.scheduler = COMMON.RX.CooperativeScheduler.create()
    self.subscription = COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.STORAGE_CHANGED)
                              :go_distinct(self.scheduler):subscribe(function()
        self:on_storage_changed()
    end)
    self.master_gain = 1
    ---@type GameWorld
    self.world = nil
end

function Sounds:on_storage_changed()
    sound.set_group_gain(COMMON.HASHES.hash("sound"), self.world.storage.options:sound_get() and 1 or 0)
    sound.set_group_gain(COMMON.HASHES.hash("music"), self.world.storage.options:music_get() and 1 or 0)
end

function Sounds:pause()
    COMMON.i("pause", TAG)
    self.master_gain = sound.get_group_gain(COMMON.HASHES.hash("master"))
    sound.set_group_gain(COMMON.HASHES.hash("master"), 0)
end

function Sounds:resume()
    COMMON.i("resume", TAG)
    sound.set_group_gain(COMMON.HASHES.hash("master"), self.master_gain)
end

function Sounds:update(dt)
    self.scheduler:update(dt)
    for k, v in pairs(self.gate_sounds) do
        self.gate_sounds[k] = v - dt
        if self.gate_sounds[k] < 0 then
            self.gate_sounds[k] = nil
        end
    end
end

function Sounds:play_sound(sound_obj)
    assert(sound_obj)
    assert(type(sound_obj) == "table")
    assert(sound_obj.url)

    if not self.gate_sounds[sound_obj] then
        self.gate_sounds[sound_obj] = self.gate_time
        sound.play(sound_obj.url)
        COMMON.i("play sound:" .. sound_obj.name, TAG)
    else
        COMMON.i("gated sound:" .. sound_obj.name .. "time:" .. self.gate_sounds[sound_obj], TAG)
    end
end
function Sounds:play_music(music_obj)
    assert(music_obj)
    assert(type(music_obj) == "table")
    assert(music_obj.url)

    sound.play(music_obj.url)
    COMMON.i("play music:" .. music_obj.name, TAG)
end

function Sounds:play_love_balls_take()
    if(COMMON.CONSTANTS.IS_MAN)then
        local idx = math.random(1, 4)
        self:play_sound(self.sounds["man_take_" .. idx])
    else
        local idx = math.random(1, 3)
        self:play_sound(self.sounds["take_" .. idx])
    end

end

return Sounds()