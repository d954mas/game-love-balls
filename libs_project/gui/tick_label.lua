local COMMON = require "libs.common"
local ACTIONS = require "libs.actions.actions"

local Lbl = COMMON.CLASS("Ticklabel")

function Lbl:initialize(lbl)
	self.lbl = assert(lbl)
	self.animation_config = {
		time = 1,
		easing = "outCubic"
	}
	self.animation = {
		value = 0,
		tween = nil
	}
	self.value = 0
end

function Lbl:force_finish()
	if self.animation.tween then
		self.animation.tween:force_finish()
		self.animation.tween = nil
		self.value = self.animation.value
		self:gui_refresh()
	end
end

function Lbl:set_value(value, force)
	checks("?", "number","boolean|nil")
	self:force_finish()
	self.animation.tween = ACTIONS.TweenTable { object = self.animation, property = "value", from = { value = self.value },
												to = { value = value }, time = self.animation_config.time,
												easing = self.animation_config.easing }
	self.value = value

	if (force) then
		self:force_finish()
	end
end


function Lbl:gui_refresh()
	gui.set_text(self.lbl, math.floor(self.animation.value))
end

function Lbl:update(dt)
	if self.animation.tween and not self.animation.tween:is_finished() then
		self.animation.tween:update(dt)
		self.value = self.animation.value
		self:gui_refresh()
	end
end

return Lbl