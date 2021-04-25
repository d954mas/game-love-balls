local COMMON = require "libs.common"
local TAG = "Entities"
local ENUMS = require "world.enums.enums"
local ACTIONS = require "libs.actions.actions"
---@type Sounds
local SOUNDS = COMMON.LUME.meta_getter(function()
    return reqf "libs.sounds"
end)

---@class MoveCurveConfig
---@field curve Curve
---@field a number position in curve [0,1]
---@field speed number
---@field deviation number
---@field position_descriptor number

---@class InputInfo
---@field action_id hash
---@field action table

---@class Size
---@field w number
---@field h number


---@class EntityGame
---@field _in_world boolean is entity in world
---@field tag string tag can search entity by tag
---@field position vector3
---@field move_curve_config MoveCurveConfig
---@field input_info InputInfo
---@field auto_destroy_delay number
---@field auto_destroy boolean
---@field actions Action[]
---@field visible boolean


---@class ENTITIES
local Entities = COMMON.class("Entities")

---@param world World
function Entities:initialize(world)
    self.world = world
    ---@type EntityGame[]
    self.by_tag = {}
end

function Entities:find_by_tag(tag)
    return self.by_tag[assert(tag)]
end


--region ecs callbacks
---@param e EntityGame
function Entities:on_entity_removed(e)
    e._in_world = false
    if (e.tag) then
        self.by_tag[e.tag] = nil
    end

end

---@param e EntityGame
function Entities:on_entity_added(e)
    e._in_world = true
    if (e.tag) then
        COMMON.i("entity with tag:" .. e.tag, TAG)
        assert(not self.by_tag[e.tag])
        self.by_tag[e.tag] = e
    end
end

---@param e EntityGame
function Entities:on_entity_updated(e)
end
--endregion


--region Entities

---@return EntityGame
function Entities:create_input(action_id, action)
    return { input_info = { action_id = action_id, action = action }, auto_destroy = true }
end

return Entities




