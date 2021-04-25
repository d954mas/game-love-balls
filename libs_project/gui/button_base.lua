local COMMON = require "libs.common"
local BtnScale = require "libs_project.gui.button_scale"
local COLOR = require "richtext.color"

local DISABLED_COLOR = COLOR.parse_hex("#999999")

---@class BtnBase:BtnScale
local Btn = COMMON.class("BtnBase", BtnScale)

function Btn:initialize(...)
    BtnScale.initialize(self, ...)
    self.vh2 = {
        bg = gui.get_node(self.template_name .. "/bg"),
        lbl = gui.get_node(self.template_name .. "/label")
    }
end

function Btn:text_set(text)
    gui.set_text(self.vh2.lbl, text)
end

function Btn:set_ignore_input(ignore)
    self.ignore_input = ignore
    gui.set_color(self.vh2.bg, self.ignore_input and DISABLED_COLOR or COLOR.COLORS.white)
end

return Btn