local COMMON = require "libs.common"
local VK = require "libs.vkminibridge.vkminibridge"
local YA = require "libs.yagames.yagames"
local TAG = "SDK"

local Sdk = COMMON.class("Sdk")

---@param world World
function Sdk:initialize(world)
    checks("?", "class:World")
    self.world = world

    self:init_yandex()
end

function Sdk:init_yandex()
    if (yagames_private) then
        COMMON.i("yagames init start", TAG)
        YA.init(function(_, err)
            if err then
                COMMON.LOG.e("yagames init error: " .. tostring(err), TAG)
            else
                COMMON.LOG.e("yagames init success", TAG)
                YA.leaderboards_init(function (_,err) end)
                YA.player_get_data(nil, function(_, err, result)
                    pprint(err)
                    pprint(result)
                end)
            end
        end)

    end
end

function Sdk:share(text)
    COMMON.i("share:" .. text, TAG)
    if (COMMON.CONSTANTS.TARGET_IS_VK_GAMES) then
        VK.send("VKWebAppShowWallPostBox", { message = text, attachments = COMMON.CONSTANTS.IS_MAN and "https://vk.com/app7850847" or "https://vk.com/app7841255"
        })
    end
end

function Sdk:leaderboard_push_new_score(score)
    if (COMMON.CONSTANTS.TARGET_IS_YANDEX_GAMES) then
        if (YA.leaderboards_ready) then
            YA.leaderboards_set_score("highscore", score)
        else
            YA.leaderboards_init(function (_,err)

            end)
        end
    end
end

function Sdk:storage_restore()
    if (COMMON.CONSTANTS.TARGET_IS_YANDEX_GAMES) then
        if (YA.player_ready) then
            YA.player_get_data(nil, function(_, err, result)
                pprint(err)
                pprint(result)
            end)
        end
    end
end

function Sdk:storage_save()
    if (COMMON.CONSTANTS.TARGET_IS_YANDEX_GAMES) then
        if (YA.player_ready) then
            YA.player_set_data({highscore = self.world.storage.game:highscore_get() }, function(_, err, result)
              --  pprint(err)
              --  pprint(result)
            end)
        end
    end
end

return Sdk
