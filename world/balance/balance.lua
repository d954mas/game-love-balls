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
            local pos_x = start_x + (x - 1) * step_x
            if (x % 2 == 1) then
                pos_x = pos_x + ball_size / 2
            end
            local pos = vmath.vector3(pos_x, start_y + (y - 1) * step_y, 0)
            table.insert(self.love_ball_spawn_poses, pos)
        end
    end
end

function Balance:score_count(balls_count)
    if (balls_count < 3) then return 0 end
    --5 7(5+2) 9(5+2) 12(9+3) 15(12+3) 19(15+4) 23(19+4) 28(23+5)
    local score = 5
    local counter = 2
    local counter_step = 0
    local counter_max_step = 2
    for i = 4, balls_count do
        score = score + counter
        counter_step = counter_step + 1
        if (counter_step >= counter_max_step) then
            counter = counter + 1
            counter_step = 0
        end
    end
    return score
end

return Balance