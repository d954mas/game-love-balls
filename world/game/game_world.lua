local COMMON = require "libs.common"
local EcsGame = require "world.game.ecs.game_ecs"
local CommandExecutor = require "world.commands.command_executor"
local COMMANDS = require "world.game.command.commands"
local ENUMS = require "world.enums.enums"
local CAMERAS = require "libs_project.cameras"

local TAG = "GAME_WORLD"

---@class GameWorld
local GameWorld = COMMON.class("GameWorld")

---@param world World
function GameWorld:initialize(world)
    self.world = assert(world)
    self.ecs_game = EcsGame(self.world)
    self.command_executor = CommandExecutor()
    self.input = {
        type = ENUMS.GAME_INPUT.NONE,
        start_time = os.clock(),
        move_delta = false,
        handle_long_tap = false,
        ---@type vector3 screen coords
        touch_pos = nil,
        touch_pos_2 = nil,
        touch_pos_dx = nil,
        touch_pos_dy = nil,
        t1_pressed = nil,
        t2_pressed = nil,
        zoom_point = nil,
        zoom_line_len = nil,
        zoom_initial = nil,
        drag = {
            valid = false,
            movable = false
        }
    }
    self.state = {
        state = ENUMS.GAME_STATE.TAP_TO_PLAY,
        timer = self.world.balance.config.timer,
        score = 0
    }
    self.input.drag = nil
    self:on_resize()
end

function GameWorld:init()
    self.ecs_game:add_systems()
    timer.delay(0, false, function()
        -- self:start_game()
    end)
end

function GameWorld:start_game()
    self.state.state = ENUMS.GAME_STATE.GAME
    self.state.score = 0
    self.state.timer = self.world.balance.config.timer
    self:love_balls_spawn(self.world.balance.config.love_balls_start_count)
    ---@type EntityGame[]
    self.love_balls_selected = {}

    local ctx = COMMON.CONTEXT:set_context_top_game_gui()
    ctx.data:game_start()
    ctx:remove()
end

function GameWorld:love_balls_take()
    for _, ball in pairs(self.ecs_game.entities.love_balls_map) do
        ball.selected = false
        ball.can_selected = false
    end
    for _, ball in ipairs(self.love_balls_selected) do
        ball.selected = false
        ball.can_selected = false
    end
    if (#self.love_balls_selected >= 3) then
        local balls_count = #self.love_balls_selected
        for _, ball in ipairs(self.love_balls_selected) do
            self.ecs_game:remove_entity(ball)
            self.ecs_game:add_entity({
                position = vmath.vector3(ball.position),
                love_ball_explosion = true,
                auto_destroy_delay = 2.5
            })
        end
        self:love_balls_spawn(balls_count)

        --add score
        local score = self.world.balance:score_count(balls_count)
        self.state.score = self.state.score + score
        local last_ball = self.love_balls_selected[#self.love_balls_selected]
        local ctx = COMMON.CONTEXT:set_context_top_game_gui()
        ctx.data.views.lbl_score:set_value(self.state.score, false)
        ctx.data:score_change_animate({ position = last_ball.position, score = score })
        ctx:remove()
    end
    self.love_balls_selected = {}
end

function GameWorld:love_balls_explode_all()
    for _, ball in pairs(self.ecs_game.entities.love_balls_map) do
        self.ecs_game:remove_entity(ball)
        if(ball.love_ball_go and ball.love_ball_go.config.visible) then
            self.ecs_game:add_entity({
                position = vmath.vector3(ball.position),
                love_ball_explosion = true,
                auto_destroy_delay = 2.5
            })
        end

    end
end

function GameWorld:restart_game()
    local ctx = COMMON.CONTEXT:set_context_top_game()
    self.ecs_game:clear()
    self.ecs_game:add_systems()
    self:start_game()
    ctx:remove()
end

function GameWorld:love_balls_up()
    for _, ball in pairs(self.ecs_game.entities.love_balls_map) do
        ball.selected = false
        ball.can_selected = false
    end
    for _, ball in ipairs(self.love_balls_selected) do
        ball.selected = false
        ball.can_selected = false
    end
    self.love_balls_selected = {}

    local ctx = COMMON.CONTEXT:set_context_top_game()
    for _, ball in pairs(self.ecs_game.entities.love_balls_map) do
        if (ball.love_ball_go) then
            local scale_y = 1
            if (ball.position.y > 1100) then
                scale_y = 0.25
            elseif (ball.position.y > 800) then
                scale_y = 0.5
            elseif (ball.position.y > 500) then
                scale_y = 0.75
            end
            msg.post(ball.love_ball_go.collision.collision, COMMON.HASHES.hash("apply_force"),
                    { force = vmath.vector3(COMMON.LUME.random(-1.75, 1.75),
                            COMMON.LUME.random(2.5, 3.5) * scale_y, 0) * 7000,
                      position = go.get_world_position(ball.love_ball_go.root) })
        end
    end
    ctx:remove()
end

function GameWorld:love_balls_spawn(count)
    local spawn_poses = COMMON.LUME.clone(self.world.balance.love_ball_spawn_poses)
    --if not big ball count then spawn not too far
    if (count < 15) then
        for i = #spawn_poses, 20, -1 do
            spawn_poses[i] = nil
        end
    end
    spawn_poses = COMMON.LUME.shuffle(spawn_poses)
    for i = 1, count do
        local spawn_pos = table.remove(spawn_poses)
        local e = self.ecs_game.entities:create_love_ball(vmath.vector3(spawn_pos.x + COMMON.LUME.random(-10, 10),
                spawn_pos.y + COMMON.LUME.random(-10, 10), spawn_pos.z))
        self.ecs_game:add_entity(e)
    end
end

function GameWorld:update(dt)
    self.command_executor:act(dt)
    self.ecs_game:update(dt)
    if (self.state.state == ENUMS.GAME_STATE.GAME) then
        self.state.timer = self.state.timer - dt
        if (self.state.timer <= 0) then
            self.state.timer = 0
            self.state.state = ENUMS.GAME_STATE.WIN
            self.world.storage.game:highscore_change(self.state.score)
            self:love_balls_take()
            self:love_balls_explode_all()
        end
    end
end

function GameWorld:final()
    self.ecs_game:clear()
end

function GameWorld:on_resize()

end

function GameWorld:on_input(action_id, action)
    self.ecs_game:add_entity(self.ecs_game.entities:create_input(action_id, action))
end

return GameWorld



