local COMMON = require "libs.common"
local TweenAction = require "libs.actions.tween_action"

---@class TweenActionGO:TweenAction
local Action = COMMON.class("TweenGOAction", TweenAction)

function Action:config_get_from()
	local data = go.get(self.config.object, self.config.property)
	return self:config_value_to_table(data)
end

function Action:set_property()
	if(self.context_error)then return end
	return go.set(self.config.object, self.config.property, self:config_table_to_value(self.tween_value))
end

return Action