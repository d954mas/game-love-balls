local CLASS = require "libs.middleclass"
local ContextManager = require "libs.contexts_manager"

---@class ContextManagerProject:ContextManager
local Manager = CLASS.class("ContextManagerProject", ContextManager)

Manager.NAMES = {
	GAME = "GAME",
	MAIN = "MAIN",
	GAME_GUI = "GAME_GUI",
	GAME_WORLD_GUI = "GAME_WORLD_GUI",
	DEBUG_GUI = "DEBUG_GUI",
	MENU_GUI = "MENU_GUI",
}

---@class ContextStackWrapperMain:ContextStackWrapper
-----@field data ScriptMain

---@return ContextStackWrapperMain
function Manager:set_context_top_main()
	return self:set_context_top_by_name(self.NAMES.MAIN)
end

---@return ContextStackWrapperMain
function Manager:set_context_top_game()
	return self:set_context_top_by_name(self.NAMES.GAME)
end

---@class ContextStackWrapperGameGui:ContextStackWrapper
---@field data GameSceneGuiScript

---@return ContextStackWrapperGameGui
function Manager:set_context_top_game_gui()
	return self:set_context_top_by_name(self.NAMES.GAME_GUI)
end

---@class ContextStackWrapperGameWorldGui:ContextStackWrapper
---@field data GameWorldGuiScript

---@return ContextStackWrapperGameWorldGui
function Manager:set_context_top_game_world_gui()
	return self:set_context_top_by_name(self.NAMES.GAME_WORLD_GUI)
end


return Manager()