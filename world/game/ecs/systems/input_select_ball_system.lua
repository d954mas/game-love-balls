local ECS = require 'libs.ecs'
local COMMON = require "libs.common"
local ENUMS = require "world.enums.enums"
local CAMERAS = require "libs_project.cameras"

---@class InputSelectBallSystem:ECSSystemProcessing
local System = ECS.processingSystem()
System.filter = ECS.filter("input_info")
System.name = "InputSystem"

function System:init()
    local cam = CAMERAS.game_camera
    self.input_handler = COMMON.INPUT()
    self.input_handler:add(COMMON.HASHES.INPUT.TOUCH, function(_, _, action)
        local game = self.world.game_world.game
        local input = game.input
        local world_pos = CAMERAS.game_camera:screen_to_world_2d(action.screen_x, action.screen_y)
        if (action.pressed) then
            for _, ball in ipairs(game.love_balls_selected) do
                ball.selected = false
                ball.can_selected = false
            end
            game.love_balls_selected = {}
            local selected_balls = self:balls_found(world_pos.x, world_pos.y, 35)
            if (#selected_balls >= 1) then
                local ball = selected_balls[1]
                ball.selected = true
                table.insert(game.love_balls_selected, ball)
            end
        elseif (action.released) then
            game:love_balls_take()
        else

            if (#game.love_balls_selected > 0) then
                local start_ball = game.love_balls_selected[#game.love_balls_selected]

                --reset
                for _, ball in ipairs(game.love_balls_selected) do
                    ball.can_selected = false
                end

                --select new ball if can
                local selected_balls = self:balls_found(world_pos.x, world_pos.y, 35)
                if (#selected_balls >= 1) then
                    local ball = selected_balls[1]
                    if (ball.love_ball.type == start_ball.love_ball.type and not ball.selected) then
                        local dx = start_ball.position.x - ball.position.x
                        local dy = start_ball.position.y - ball.position.y
                        local dist = math.sqrt(dx * dx + dy * dy)
                        if(dist<100)then
                            ball.selected = true
                            table.insert(game.love_balls_selected, ball)
                            start_ball = ball
                        end
                    end
                    --return to prev_ball
                    if(#game.love_balls_selected >= 2)then
                        local prev_ball = game.love_balls_selected[#game.love_balls_selected-1]
                        if(ball == prev_ball)then
                            local removed_ball = table.remove(game.love_balls_selected)
                            removed_ball.selected = false
                        end
                    end
                end


                selected_balls = self:balls_found(start_ball.position.x, start_ball.position.y, 100)
                for _, ball in ipairs(selected_balls) do
                    if (ball.love_ball.type == start_ball.love_ball.type) then
                        ball.can_selected = true
                    end
                end
            end

        end
    end, true, false, true, true)
end

---@return EntityGame[]
function System:balls_found(x, y, radius)
    local result = {}
    for _, ball in pairs(self.world.game_world.game.ecs_game.entities.love_balls_map) do
        local dx = x - ball.position.x
        local dy = y - ball.position.y
        local dist = math.sqrt(dx * dx + dy * dy)
        if (dist < radius) then
            table.insert(result, ball)
        end
    end
    return result
end

function System:preProcess(dt)

end

---@param e EntityGame
function System:process(e, dt)
    self.input_handler:on_input(self, e.input_info.action_id, e.input_info.action)
end

System:init()

return System
