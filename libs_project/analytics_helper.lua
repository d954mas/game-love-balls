local ANALYTICS = require "libs_project.analytics"

local DT_SEND_TIME_DELAY = 60

local Helper = {
    dt = {
        time = 0,
        frames = 0,
        send_delay = DT_SEND_TIME_DELAY
    }
}

function Helper.performance_init_time(time)
    ANALYTICS:eventCustom("performance:init_time",time)
end

function Helper.performance_scene_load_time(name, time)
    ANALYTICS:eventCustom("performance:scene:" .. name .. ":load_time",time)
end

function Helper.performance_dt(dt)
    local dt_config = Helper.dt
    dt_config.time = dt_config.time + dt
    dt_config.frames = dt_config.frames + 1
    dt_config.send_delay = dt_config.send_delay - dt
    if(dt_config.send_delay<0)then
        dt_config.send_delay = DT_SEND_TIME_DELAY
        ANALYTICS:eventCustom("performance:dt",dt_config.time/dt_config.frames)
        dt_config.time = 0
        dt_config.frames = 0
    end

end





return Helper