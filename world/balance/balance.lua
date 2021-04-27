local COMMON = require "libs.common"
local Balance = COMMON.class("Balance")

---@param world World
function Balance:initialize(world)
    checks("?", "class:World")
    self.world = world
    self.config = {
        love_balls_start_count = 40,
        -- have extra 2 second. Balls fallow
        --gui show only 60
        timer = 61.5,
        timer_gui_max = 60
    }
    self.love_ball_spawn_poses = {}

    local ball_size = 70
    local start_x = -210 + ball_size / 2 + 10
    local end_x = 210 - ball_size / 2 - 10 - ball_size
    local step_x = (end_x - start_x) / 10
    local step_y = 80
    local start_y = 1000
    for y = 1, 7 do
        for x = 1, 10 do
            local pos_x = start_x+ (x-1) * step_x
            if(x%2 == 1)then
                pos_x = pos_x + ball_size/2
            end
            local pos = vmath.vector3(pos_x, start_y + (y-1) * step_y, 0)
            table.insert(self.love_ball_spawn_poses, pos)
        end
    end
end

function Balance:score_count(balls_count)
    return balls_count
end

return Balance