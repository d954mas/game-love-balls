local COMMON = require "libs.common"
local VK = require "libs.vkminibridge.vkminibridge"
local TAG = "SDK"

local Sdk = COMMON.class("Sdk")

function Sdk:initialize(world)
    checks("?", "class:World")
    self.world = world
end

function Sdk:share(text)
    COMMON.i("share:" .. text,TAG)
    if (COMMON.CONSTANTS.TARGET_IS_VK_GAMES) then
        VK.send("VKWebAppShowWallPostBox", { message = text, attachments = "https://vk.com/app7841255_16253997" })
    end
end

return Sdk
