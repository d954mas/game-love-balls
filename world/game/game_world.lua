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
    self.input.drag = nil
    self:on_resize()
end

function GameWorld:init()
    self.ecs_game:add_systems()
end

function GameWorld:update(dt)
    self.command_executor:act(dt)
    self.ecs_game:update(dt)
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



