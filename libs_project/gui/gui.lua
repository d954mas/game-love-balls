local M = {}
M.Button = require "libs_project.gui.button"
M.ButtonBase = require "libs_project.gui.button_base"
M.ButtonIconTest = require "libs_project.gui.button_icon_text"
M.ButtonScale = require "libs_project.gui.button_scale"
M.RichtextLbl = require "libs_project.gui.richtext_lbl"
M.TickLbl = require "libs_project.gui.tick_label"
M.CheckboxWithLabel = require "libs_project.gui.checkbox_with_label"
M.ProgressBar = require "libs_project.gui.progress_bar"


function M.get_scaled_size(node)
    assert(node)
    local size = gui.get_size(node)
    local scale = gui.get_scale(node)
    size.x = size.x * scale.x
    size.y = size.y * scale.y
    size.z = size.z * scale.z
    return size
end

return M