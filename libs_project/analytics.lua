local COMMON = require "libs.common"
local JSON = require "libs.json"

local Analytics = COMMON.class("Analytics")

function Analytics:init(config)
    checks("?", "table")
    assert(not self.initialized, "already inited")
    self.initialized = true
    self.config = config
    self.disabled = false
    if (COMMON.CONSTANTS.PLATFORM_IS_WINDOWS) then
        self.disabled = true
    end
    if(gameanalytics)then
        gameanalytics.setEnabledInfoLog(COMMON.CONSTANTS.VERSION_IS_DEV)
        gameanalytics.setCustomDimension01(COMMON.CONSTANTS.GAME_TARGET)
    else
        self.disabled = true
    end


    local handle = crash.load_previous()
    if handle and not self.disabled then
        self:critical(crash.get_extra_data(handle))
        crash.release(handle)
    end
end

function Analytics:register_error_handler()
    sys.set_error_handler(function(source, message, traceback)
        --close all contexts on error. Or engine can be broken
        COMMON.CONTEXT:clear()
        --do not send same message
        self.exception_prev_time = self.exception_prev_time or 0
        if (self.exception_prev ~= message or (os.time() - self.exception_prev_time) > 60 * 1) then
            self:error((JSON.encode({ source = source, message = message, traceback = traceback }, false)));
            self.exception_prev = message
            self.exception_prev_time = os.time()
        end
    end)
end

function Analytics:error(message)
    if (self.initialized and not self.disabled) then
        gameanalytics.addErrorEvent { severity = "Error", message = message }
    end
end
function Analytics:critical(message)
    if (self.initialized and not self.disabled) then
        gameanalytics.addErrorEvent { severity = "Critical", message = message }
    end
end

function Analytics:eventCustom(id, value)
    if (self.initialized and not self.disabled) then
        gameanalytics.addDesignEvent { eventId = id, value = value }
    end
end

function Analytics:ad_interstitial(adSdkName, adPlacement)
    if (self.initialized and not self.disabled) then
        gameanalytics.addAdEvent {
            adAction = "Show",
            adType = "Interstitial",
            adSdkName = adSdkName,
            adPlacement = adPlacement
        }
    end
end
function Analytics:ad_rewarded_show(adSdkName, adPlacement)
    checks("?", "string", "string")
    if (self.initialized and not self.disabled) then
        gameanalytics.addAdEvent {
            adAction = "RewardReceived",
            adType = "RewardedVideo",
            adSdkName = adSdkName,
            adPlacement = adPlacement
        }
    end
end

local a = Analytics()
a:init({})
a:register_error_handler()
return a
