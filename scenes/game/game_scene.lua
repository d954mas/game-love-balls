local BaseScene = require "libs.sm.scene"


---@class GameScene:Scene
local Scene = BaseScene:subclass("Game")
function Scene:initialize()
    BaseScene.initialize(self, "GameScene", "/game_scene#collectionproxy")
end

return Scene