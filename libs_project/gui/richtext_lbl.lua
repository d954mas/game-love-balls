local COMMON = require "libs.common"
local TEXT_SETTING = require "libs.text_settings"
local RICHTEXT = require "richtext.richtext"

local Lbl = COMMON.CLASS("RichtextLbl")

function Lbl:initialize()
	self.nodes = nil
	self.text_metrics = nil
	self.text = nil
	self.center_v = false
	self.root_node = gui.new_box_node(vmath.vector3(0), vmath.vector3(1))
	self:set_text_setting(TEXT_SETTING.BASE_CENTER)
	self:set_font("Base")
end

function Lbl:set_parent(parent)
	gui.set_parent(self.root_node,assert(parent))
end

function Lbl:set_font(font)
	checks("?", "string")
	self.font = font
end

function Lbl:set_text_setting(config)
	checks("?", "table")
	self.text_setting = TEXT_SETTING.make_copy(config, { parent = self.root_node })
end

function Lbl:set_text(text)
	checks("?", "string")
	if(self.text == text) then
		return
	end
	self.text = text
	if (self.nodes) then
		for _, node in ipairs(self.nodes) do
			gui.delete_node(node.node)
		end
	end
	RICHTEXT.DEFAULT_ALIGN = gui.PIVOT_W
	self.nodes, self.text_metrics = RICHTEXT.create(self.text, self.font, self.text_setting)
	RICHTEXT.DEFAULT_ALIGN = nil

	if(self.center_v)then
		gui.set_position(self.root_node,vmath.vector3(0,self.text_metrics.height/2,0))
	else
		gui.set_position(self.root_node,vmath.vector3(0))
	end
end

return Lbl