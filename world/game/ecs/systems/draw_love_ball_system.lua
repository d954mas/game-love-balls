local ECS = require 'libs.ecs'
local ENUMS = require "world.enums.enums"
local COMMON = require "libs.common"

local FACTORY = msg.url("game_scene:/factories#love_ball")
local FACTORY_IDS = {
    ROOT = COMMON.HASHES.hash("/root"),
    PORTRAIT = COMMON.HASHES.hash("/portrait"),
    COLLISION = COMMON.HASHES.hash("/root"),
    SELECTED = COMMON.HASHES.hash("/selected"),
}

-- luacheck: push ignore _LoveBallView
---@class LoveBallView
---@field root url
local _LoveBallView = {
    portrait = {
        root = msg.url(),
        sprite = msg.url()
    },
    collision = {
        root = msg.url(),
        collision = msg.url()
    },
    selected = {
        root = msg.url(),
        sprite = msg.url()
    },
    config = {
        selected = false
    }
}
-- luacheck: pop

---@class DrawLoveBallSystem:ECSSystem
local System = ECS.processingSystem()
System.filter = ECS.filter("love_ball")
System.name = "DrawLoveBallSystem"

local V3 = vmath.vector3(0, 0, 0.1)

function System:init()

end

---@param e EntityGame
function System:process(e, dt)
    local game = self.world.game_world.game
    if (not e.love_ball_go) then
        local collection = collectionfactory.create(FACTORY,
                vmath.vector3(e.position.x, e.position.y, 0.1),
                vmath.quat_rotation_z(-math.pi/4 +math.random()*math.pi/2), nil,
                vmath.vector3(1)
        )
        local love_ball_go = {
            root = msg.url(assert(collection[FACTORY_IDS.ROOT])),
            collision = {

            },
            portrait = {
                root = msg.url(assert(collection[FACTORY_IDS.PORTRAIT])),
                sprite = nil
            },
            collision = {
                root  = msg.url(assert(collection[FACTORY_IDS.COLLISION])),
                collision = nil
            },
            selected = {
                root  = msg.url(assert(collection[FACTORY_IDS.SELECTED])),
                sprite = nil
            },
            config = {
                selected = false,
                can_selected = false,
                alpha = 1
            }
        }
        love_ball_go.portrait.sprite = msg.url(love_ball_go.portrait.root.socket,
                love_ball_go.portrait.root.path, COMMON.HASHES.SPRITE)
        love_ball_go.collision.collision = msg.url(love_ball_go.collision.root.socket,
                love_ball_go.collision.root.path, COMMON.HASHES.hash("collisionobject"))
        love_ball_go.selected.sprite = msg.url(love_ball_go.selected.root.socket,
                love_ball_go.selected.root.path, COMMON.HASHES.SPRITE)

        e.love_ball_go = love_ball_go
        -- apply a force of 1 Newton towards world-x at the center of the game object instance
        msg.post(love_ball_go.collision.collision, COMMON.HASHES.hash("apply_force"), {force = vmath.vector3(math.random()*1, math.random()*1, 0), position = go.get_world_position()})
        sprite.play_flipbook(e.love_ball_go.portrait.sprite,COMMON.HASHES.hash("portrait_" .. e.love_ball.type))
        go.set(love_ball_go.selected.sprite,COMMON.HASHES.hash("tint.w"),0)
    end

    if (e.love_ball_go) then
        e.position = go.get_position(e.love_ball_go.root)
        local selected_balls = self.world.game_world.game.love_balls_selected
        local alpha = 1
        if(#selected_balls>0)then
            alpha = 0.5
        end
        if(e.selected ~= e.love_ball_go.config.selected)then
            e.love_ball_go.config.selected = e.selected
            go.set(e.love_ball_go.selected.sprite,COMMON.HASHES.hash("tint.w"),
                e.selected  and 1 or 0)
            e.position.z = e.selected and 0.25 or 0.1
            go.set_position(e.position,e.love_ball_go.root)
        end
        if(e.can_selected ~= e.love_ball_go.config.can_selected)then
            e.love_ball_go.config.can_selected = e.can_selected
        end


        if(e.can_selected)then alpha = 0.8 end
        if(e.selected)then alpha = 1 end

        if(e.love_ball_go.config.alpha ~= alpha)then
            e.love_ball_go.config.alpha = alpha
            go.set(e.love_ball_go.portrait.sprite,COMMON.HASHES.hash("tint.w"),
                    alpha)
        end

    end
end

return System