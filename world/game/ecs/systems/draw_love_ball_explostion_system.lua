local ECS = require 'libs.ecs'
local COMMON = require "libs.common"

local FACTORY = msg.url("game_scene:/factories#love_ball_explosion")
local FACTORY_IDS = {
    ROOT = COMMON.HASHES.hash("/fx"),
    FX = COMMON.HASHES.hash("/fx"),
}

-- luacheck: push ignore _LoveBallView
---@class LoveBallExplosionView
---@field root url
local _LoveBallView = {
    fx = {
        root = msg.url(),
        particlefx = msg.url()
    },
}
-- luacheck: pop

---@class DrawLoveBallExplosionSystem:ECSSystem
local System = ECS.processingSystem()
System.filter = ECS.filter("love_ball_explosion")
System.name = "DrawLoveBallExplosionSystem"


function System:init()

end

---@param e EntityGame
function System:process(e, dt)
    if (not e.love_ball_explosion_go) then
        local collection = collectionfactory.create(FACTORY,
                vmath.vector3(e.position.x, e.position.y, 0.5)
        )
        ---@type LoveBallExplosionView
        local love_ball_explosion_go = {
            root = msg.url(assert(collection[FACTORY_IDS.ROOT])),
            fx = {
                root = msg.url(assert(collection[FACTORY_IDS.FX])),
                particlefx = nil
            },
        }
        love_ball_explosion_go.fx.particlefx = msg.url(love_ball_explosion_go.fx.root.socket,
                love_ball_explosion_go.fx.root.path, COMMON.HASHES.hash("particlefx"))

        e.love_ball_explosion_go = love_ball_explosion_go
        particlefx.play(love_ball_explosion_go.fx.particlefx)
    end
end

return System