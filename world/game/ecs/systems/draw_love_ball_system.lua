local ECS = require 'libs.ecs'
local COMMON = require "libs.common"

local FACTORY = msg.url("game_scene:/factories#love_ball")
local FACTORY_IDS = {
    ROOT = COMMON.HASHES.hash("/root"),
    PORTRAIT = COMMON.HASHES.hash("/portrait"),
    COLLISION = COMMON.HASHES.hash("/root"),
    SELECTED = COMMON.HASHES.hash("/selected"),
    HEART_LINE = COMMON.HASHES.hash("/heart_line"),
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
        sprite = msg.url(),
        sprite_additive = msg.url()
    },
    heart_line = {
        root = msg.url(),
        sprite = msg.url(),
        sprite_additive = msg.url()
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

function System:init()

end

---@param e EntityGame
function System:process(e, dt)
    if (not e.love_ball_go) then
        local collection = collectionfactory.create(FACTORY,
                vmath.vector3(e.position.x, e.position.y, 0.1),
                vmath.quat_rotation_z(-math.pi / 4 + math.random() * math.pi / 2), nil,
                vmath.vector3(1)
        )
        ---@type LoveBallView
        local love_ball_go = {
            root = msg.url(assert(collection[FACTORY_IDS.ROOT])),
            portrait = {
                root = msg.url(assert(collection[FACTORY_IDS.PORTRAIT])),
                sprite = nil
            },
            collision = {
                root = msg.url(assert(collection[FACTORY_IDS.COLLISION])),
                collision = nil
            },
            selected = {
                root = msg.url(assert(collection[FACTORY_IDS.SELECTED])),
                sprite = nil,
                sprite_additive = nil
            },
            heart_line = {
                root = msg.url(assert(collection[FACTORY_IDS.HEART_LINE])),
                sprite = nil,
                sprite_additive = nil
            },
            config = {
                selected = false,
                can_selected = false,
                alpha = 1,
                visible = true
            }
        }
        love_ball_go.portrait.sprite = msg.url(love_ball_go.portrait.root.socket,
                love_ball_go.portrait.root.path, COMMON.HASHES.SPRITE)
        love_ball_go.collision.collision = msg.url(love_ball_go.collision.root.socket,
                love_ball_go.collision.root.path, COMMON.HASHES.hash("collisionobject"))
        love_ball_go.selected.sprite = msg.url(love_ball_go.selected.root.socket,
                love_ball_go.selected.root.path, COMMON.HASHES.SPRITE)
        love_ball_go.selected.sprite_additive = msg.url(love_ball_go.selected.root.socket,
                love_ball_go.selected.root.path, COMMON.HASHES.hash("sprite_additive"))
        love_ball_go.heart_line.sprite = msg.url(love_ball_go.heart_line.root.socket,
                love_ball_go.heart_line.root.path, COMMON.HASHES.SPRITE)
        love_ball_go.heart_line.sprite_additive = msg.url(love_ball_go.heart_line.root.socket,
                love_ball_go.heart_line.root.path, COMMON.HASHES.hash("sprite_additive"))

        e.love_ball_go = love_ball_go
        -- apply a force of 1 Newton towards world-x at the center of the game object instance
        msg.post(love_ball_go.collision.collision, COMMON.HASHES.hash("apply_force"),
                { force = vmath.vector3(COMMON.LUME.random(-0.75, 0.75),
                        -COMMON.LUME.random(1.5, 2.5), 0) * 10000,
                  position = go.get_world_position(love_ball_go.root)
                })
        sprite.play_flipbook(e.love_ball_go.portrait.sprite, COMMON.HASHES.hash(
                (COMMON.CONSTANTS.IS_MAN and "man_portrait_" or "portrait_") .. e.love_ball.type))
        msg.post(love_ball_go.selected.root, COMMON.HASHES.MSG.DISABLE)
        msg.post(love_ball_go.heart_line.root, COMMON.HASHES.MSG.DISABLE)
    end

    if (e.love_ball_go) then
        e.position = go.get_position(e.love_ball_go.root)
        local visible = e.position.y < 745
        local selected_balls = self.world.game_world.game.love_balls_selected
        local alpha = 1
        if (#selected_balls > 0) then
            alpha = 0.5
        end
        if (e.selected ~= e.love_ball_go.config.selected) then
            e.love_ball_go.config.selected = e.selected
            local message = e.selected and COMMON.HASHES.MSG.ENABLE or COMMON.HASHES.MSG.DISABLE
            msg.post(e.love_ball_go.selected.root, message)
            msg.post(e.love_ball_go.heart_line.root, message)
            e.position.z = e.selected and 0.25 or 0.1
            go.set_position(e.position, e.love_ball_go.root)
        end
        if (e.can_selected ~= e.love_ball_go.config.can_selected) then
            e.love_ball_go.config.can_selected = e.can_selected
        end

        if (e.can_selected) then alpha = 0.8 end
        if (e.selected) then
            alpha = 1
            --update line pos
            local idx = COMMON.LUME.findi(selected_balls, e)
            if (idx) then
                local next = selected_balls[idx + 1]
                if (not next) then
                    go.set_scale(vmath.vector3(0.33, 0.001, 1), e.love_ball_go.heart_line.root)
                else
                    local dx, dy = next.position.x - e.position.x, next.position.y - e.position.y
                    local angle = COMMON.LUME.angle_vector(dx, dy) - math.pi / 2
                    angle = angle - math.rad(go.get(e.love_ball_go.root, "euler.z"))
                    go.set_rotation(vmath.quat_rotation_z(angle), e.love_ball_go.heart_line.root)
                    local dist = math.sqrt(dx * dx + dy * dy)
                    go.set_scale(vmath.vector3(0.33, dist / 30, 1), e.love_ball_go.heart_line.root)
                end
            end

        end

        if (e.love_ball_go.config.alpha ~= alpha) then
            e.love_ball_go.config.alpha = alpha
            go.set(e.love_ball_go.portrait.sprite, COMMON.HASHES.hash("tint.w"),
                    alpha)
        end

        if (e.love_ball_go.config.visible ~= visible) then
            e.love_ball_go.config.visible = visible
            local message = visible and COMMON.HASHES.MSG.ENABLE or COMMON.HASHES.MSG.DISABLE
            msg.post(e.love_ball_go.portrait.sprite, message)
        end

    end
end

return System