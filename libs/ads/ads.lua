local COMMON = require "libs.common"
---@type SceneManagerProject
local SM = COMMON.LUME.meta_getter(function() return reqf "libs_project.sm" end)
---@type Sounds
local SOUNDS = COMMON.LUME.meta_getter(function() return reqf "libs.sounds" end)
local SCENE_ENUMS = require "libs.sm.enums"
local ANALYTICS = require "libs_project.analytics"
local VK = require "libs.vkminibridge.vkminibridge"
local TAG = "ADS"

local Ads = COMMON.class("Ads")
local yagames = require "libs.yagames.yagames"

---@param world World
function Ads:initialize(world)
    checks("?", "class:World")
    self.world = world
    self.interstitial_ad_next_time = 0
    self.interstitial_ad_delay = 4 * 60
    self.callback = nil
    self.context = nil
    self.subscription = COMMON.RX.SubscriptionsStorage()
    self.subscription:add(COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.JSTODEF):subscribe(function(event)
        self:on_event(event)
    end))
end

function Ads:on_event(event)
    local message_id = event.message_id
    local message = event.message
    print("ADS EVENT. message_id:" .. message_id .. " message:")
    pprint(message)
end

function Ads:callback_save(cb)
    assert(not self.callback)
    self.callback = cb
    self.context = lua_script_instance.Get()
end

function Ads:callback_execute()
    if (self.callback) then
        local ctx_id = COMMON.CONTEXT:set_context_top_by_instance(self.context)
        self.callback(true)
        COMMON.CONTEXT:remove_context_top(ctx_id)
        self.context = nil
        self.callback = nil
    else
        COMMON.w("no callback to execute", TAG)
    end
end

--have some problems if try to init in constructor
--gdsdk listener not worked
function Ads:init()
    self:gdsdk_init()
    self:yandex_init()
    self:vk_init()
end

function Ads:vk_init()
    if (COMMON.CONSTANTS.TARGET_IS_VK_GAMES) then
        COMMON.i("vk games init start", TAG)
        VK.init(nil, function()
            COMMON.i("vk games init", TAG)
            -- Sends event to client
            VK.send('VKWebAppInit', {})
        end)
    end
end

function Ads:yandex_init()
    if (yagames_private) then
        COMMON.i("yagames init start", TAG)
        yagames.init(function(_, err)
            if err then
                COMMON.LOG.e("yagames init error: " .. tostring(err), TAG)
            else
                COMMON.LOG.e("yagames init success", TAG)
            end
        end)
    end

end

function Ads:gdsdk_init()
    if (gdsdk) then
        COMMON.i("init gdsdk", TAG)
        gdsdk.set_listener(function(_, event, message)
            print(event)
            COMMON.i("event:" .. tostring(event), TAG)
            pprint(message)
            if event == gdsdk.SDK_GAME_PAUSE then
                SOUNDS:pause()
                local scene = SM:get_top()
                if (scene and scene._state == SCENE_ENUMS.STATES.RUNNING) then
                    scene:pause()
                end
            elseif event == gdsdk.SDK_GAME_START then
                if (self.callback) then
                    self:callback_execute()
                end

                SOUNDS:resume()
                local scene = SM:get_top()
                if (scene and scene._state == SCENE_ENUMS.STATES.PAUSED) then
                    scene:resume()
                end
            end
        end)
    end
end

function Ads:show_interstitial_ad(ad_placement, cb)
    if (os.clock() > self.interstitial_ad_next_time) then
        COMMON.i("interstitial_ad show", TAG)
        if (gdsdk) then
            if (self.callback) then
                COMMON.w("can't show already have callback")
                if (cb) then cb(false, "callback exist") end
                return
            else
                self:callback_save(cb)
            end
            gdsdk.show_interstitial_ad()
            ANALYTICS:ad_rewarded_show("gdsdk", ad_placement)
            --  if (cb) then cb(true) end
        elseif (yagames_private) then
            yagames.adv_show_fullscreen_adv({
                open = function()
                    ANALYTICS:ad_rewarded_show("yagames", ad_placement)
                    -- if (cb) then cb(true) end
                end,
                close = function()
                    if (cb) then cb(true, "close") end
                end,
                offline = function()
                    if (cb) then cb(false, "offline") end
                end,
                error = function()
                    if (cb) then cb(false, "error") end
                end
            })
        elseif (COMMON.CONSTANTS.TARGET_IS_VK_GAMES) then

        else
            COMMON.i("interstitial_ad no provider")
            if (cb) then cb(false, "no provider") end
        end
        self.interstitial_ad_next_time = os.clock() + self.interstitial_ad_delay
    else
        COMMON.i("interstitial_ad need wait", TAG)
        if (cb) then cb(false, "need wait") end
    end
end

function Ads:rewarded_ad_show(ad_placement, cb)
    COMMON.i("rewarded_ad show", TAG)
    if (gdsdk) then
        if (self.callback) then
            COMMON.w("can't show already have callback")
            if (cb) then cb(false, "callback exist") end
            return
        else
            self:callback_save(cb)
        end
        gdsdk.show_rewarded_ad()
        ANALYTICS:ad_rewarded_show("gdsdk", ad_placement)
    elseif (yagames_private) then
        yagames.adv_show_rewarded_video({
            open = function()
                ANALYTICS:ad_rewarded_show("yagames", ad_placement)
                -- if (cb) then cb(true) end
            end,
            close = function()
                if (cb) then cb(false, "close") end
            end,
            rewarded = function()
                if (cb) then cb(true) end
            end,
            error = function()
                if (cb) then cb(false, "error") end
            end })
    else
        COMMON.i("rewarded_ad no provider")
        if (cb) then cb(false, "no provider") end
    end
end

function Ads:rewarded_ad_exist()
    if (gdsdk) then return true

    elseif yagames then return true
    else
        return true
    end
end

function Ads:banner_show(ad_placement)
    COMMON.i("banner show:" .. ad_placement)
    if (gdsdk) then
        gdsdk.show_display_ad("canvas-ad")
    end
end

function Ads:banner_hide(ad_placement)
    COMMON.i("banner hide:" .. ad_placement)
    if (gdsdk) then
        gdsdk.hide_display_ad("canvas-ad")
    end
end

return Ads
