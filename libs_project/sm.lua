local SM = require "libs.sm.scene_manager"

---@class SceneManagerProject:SceneManager
local sm = SM()

local scenes = {
    require "scenes.game.game_scene",
}

sm.SCENES = {
    GAME = "GameScene"
}

function sm:register_scenes()
    local reg_scenes = {}
    for i, v in ipairs(scenes) do reg_scenes[i] = v() end --create instances
    self:register(reg_scenes)
end

return sm