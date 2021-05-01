local COMMON = require "libs.common"
---@type SceneManagerProject
local SM = COMMON.LUME.meta_getter(function() return reqf "libs_project.sm" end)
---@type Sounds
local SOUNDS = COMMON.LUME.meta_getter(function() return reqf "libs.sounds" end)
local SCENE_ENUMS = require "libs.sm.enums"
local ANALYTICS = require "libs_project.analytics"
local VK = require "libs.vkminibridge.vkminibridge"
local yagames = require "libs.yagames.yagames"

local TAG = "SDK"

local Sdk = COMMON.class("Sdk")

function Sdk:initialize(world)
    checks("?", "class:World")
    self.world = world
end

function Sdk:share(text)
    if (COMMON.CONSTANTS.TARGET_IS_VK_GAMES) then
        VK.send("VKWebAppShowWallPostBox", { message = text, attachments = "https://vk.com/app7841255_16253997" })
    end
end

return Sdk
