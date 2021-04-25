local COMMON = require "libs.common"
local ACTIONS = require "libs.actions.actions"

local Bar = COMMON.class("Bar")

function Bar:initialize(root_name)
    self.vh = {
        root = gui.get_node(root_name .. "/root"),
        bg = gui.get_node(root_name .. "/bg"),
        progress = gui.get_node(root_name .. "/progress"),
        center = gui.get_node(root_name .. "/center"),
        lbl = nil
    }
    local status, lbl = pcall(gui.get_node, root_name .. "/lbl")
    if status then
        self.vh.lbl = lbl
        local center = vmath.vector3(gui.get_size(self.vh.bg).x / 2, gui.get_position(self.vh.progress).y, 0)
        gui.set_position(self.vh.lbl, center)
    end
    self.value_max = 100
    self.value = 0
    self.padding_progress = gui.get_position(self.vh.progress).x
    self.progress_width_max = gui.get_size(self.vh.bg).x - self.padding_progress * 2
    self.nine_texture_size = gui.get_slice9(self.vh.progress)
    self.nine_texture_size_origin = gui.get_slice9(self.vh.progress)
    self.animation_config = {
        time = 0.5,
        easing = "linear"
    }
    self.animation = {
        value = 0,
        tween = nil
    }
    self.animation_pulse_sequence = ACTIONS.Sequence()
    self.animation_pulse_sequence.drop_empty = false

    self:set_value(self.value)
    self:gui_update()
end

function Bar:set_value_max(value)
    assert(value > 0)
    self.value_max = value
    self:gui_update()
end

function Bar:update(dt)
    if self.animation.tween and not self.animation.tween:is_finished() then
        self.animation.tween:update(dt)
        self:gui_update()
    end
    self.animation_pulse_sequence:update(dt)
end

function Bar:lbl_format_value()
    return (math.ceil(self.animation.value) .. "/" .. self.value_max)
end

function Bar:gui_update()
    if self.vh.lbl then
        gui.set_text(self.vh.lbl, self:lbl_format_value())
    end

    local size = vmath.vector3(self.progress_width_max * self.animation.value / self.value_max, gui.get_size(self.vh.progress).y, 0)
    if (size.x == 0) then
        if (not self.progress_disabled) then
            self.progress_disabled = true
            gui.set_enabled(self.vh.progress, false)
        end
    elseif (size.x < self.nine_texture_size_origin.x + self.nine_texture_size_origin.w) then
        self.nine_texture_size_changed = true
        self.nine_texture_size.x = size.x
        self.nine_texture_size.w = 0
        gui.set_slice9(self.vh.progress, self.nine_texture_size)
    else
        if (self.nine_texture_size_changed) then
            self.nine_texture_size = vmath.vector4(self.nine_texture_size_origin)
            gui.set_slice9(self.vh.progress, self.nine_texture_size)
            self.nine_texture_size_changed = nil
        end
    end

    if (size.x ~= 0 and self.progress_disabled) then
        self.progress_disabled = nil
        gui.set_enabled(self.vh.progress, true)
    end
    gui.set_size(self.vh.progress, size)
end

function Bar:set_enabled(enabled)
    gui.set_enabled(self.vh.root, enabled)
end

function Bar:set_value(value,force)
    if self.animation.tween then
        self.animation.tween:force_finish()
        self.animation.tween = nil
    end
    self.animation.tween = ACTIONS.TweenTable { object = self.animation, property = "value", from = { value = self.value },
                                                to = { value = value }, time = self.animation_config.time,
                                           easing = self.animation_config.easing }
    self.value = COMMON.LUME.clamp(value, 0, self.value_max)
    if(force)then
        self.animation.tween:force_finish()
        self:gui_update()
    end
end

function Bar:animation_pulse()
    local scale = ACTIONS.TweenGui { object = self.vh.root, property = "scale", v3 = true,
                                     from = vmath.vector3(1), to = vmath.vector3(1.15), time = 0.2 }
    local scale2 = ACTIONS.TweenGui { object = self.vh.root, property = "scale", v3 = true,
                                      from = vmath.vector3(1.15), to = vmath.vector3(1), time = 0.2 }
    self.animation_pulse_sequence:add_action(scale)
    self.animation_pulse_sequence:add_action(scale2)
end

return Bar