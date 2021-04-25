local M = {}
M.hashes = {}
setmetatable(M.hashes, {
    __index = function(t, key)
        local h = hash(key)
        rawset(t, key, h)
        return h
    end
})

function M.hash(key)
    return M.hashes[key]
end

M.INPUT = {
    ACQUIRE_FOCUS = M.hash("acquire_input_focus"),
    RELEASE_FOCUS = M.hash("release_input_focus"),
    BACK = M.hash("back"),
    TOUCH = M.hash("touch"),
    TOUCH_MULTI = M.hash("touch_multi"),
    RIGHT_CLICK = M.hash("right_click"),
    SCROLL_UP = M.hash("scroll_up"),
    SCROLL_DOWN = M.hash("scroll_down"),
    LEFT_CTRL = M.hash("left_ctrl"),
}

M.MSG = {
    PHYSICS = {
        CONTACT_POINT_RESPONSE = M.hash("contact_point_response"),
        COLLISION_RESPONSE = M.hash("collision_response"),
        TRIGGER_RESPONSE = M.hash("trigger_response"),
        RAY_CAST_RESPONSE = M.hash("ray_cast_response")
    },
    RENDER = {
        CLEAR_COLOR = M.hash("clear_color"),
        SET_VIEW_PROJECTION = M.hash("set_view_projection"),
        WINDOW_RESIZED = M.hash("window_resized"),
        DRAW_LINE = M.hash("draw_line"),
    },
    PLAY_SOUND = M.hash("play_sound"),
    ENABLE = M.hash("enable"),
    DISABLE = M.hash("disable"),
    PLAY_ANIMATION = M.hash("play_animation"),
    ACQUIRE_CAMERA_FOCUS = M.hash("acquire_camera_focus"),
    SET_PARENT = M.hash("set_parent"),
    SET_TIME_STEP = M. hash("set_time_step"),
    LOADING = {
        PROXY_LOADED = M.hash("proxy_loaded"),
        ASYNC_LOAD = M.hash("async_load"),
        UNLOAD = M.hash("unload"),
    },
    TINT = {
        TINT = M.hash("tint"),
        X = M.hash("tint.x"),
        Y = M.hash("tint.y"),
        Z = M.hash("tint.z"),
        W = M.hash("tint.w"),
    }
}

M.EMPTY = M.hash("empty")
M.NIL = M.hash("nil")
M.SPRITE = M.hash("sprite")

return M
