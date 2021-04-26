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

---@class LoveBall
---@field type number [1-5]


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
---@field selected boolean
---@field love_ball LoveBall
---@field love_ball_go LoveBallView
---@field love_ball_explosion LoveBallView
---@field love_ball_explosion_go LoveBallExplosionView



---@class ENTITIES
local Entities = COMMON.class("Entities")

---@param world World
function Entities:initialize(world)
    self.world = world
    ---@type EntityGame[]
    self.by_tag = {}
    self.love_balls_map = {}
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
    if (e.love_ball) then
        self.love_balls_map[e] = nil
    end
    if (e.love_ball_go) then
        go.delete(e.love_ball_go.root, true)
        e.love_ball_go = nil
    end
    if (e.love_ball_explosion_go) then
        go.delete(e.love_ball_explosion_go.root, true)
        e.love_ball_explosion_go = nil
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
    if (e.love_ball) then
        self.love_balls_map[e] = e
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

---@return EntityGame
function Entities:create_love_ball(pos)
    assert(pos)
    ---@type EntityGame
    local e = {}
    e.love_ball = {
        type = math.random(1, 5)
    }
    e.love_ball_go = nil
    e.visible = false
    e.position = vmath.vector3(pos.x, pos.y, pos.z)
    return e
end

return Entities




