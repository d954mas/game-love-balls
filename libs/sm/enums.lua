local COMMON = require "libs.common"

local STATES = COMMON.LUME.read_only({
	UNLOADED = "UNLOADED",
	LOADING = "LOADING",
	HIDE = "HIDE", --scene is loaded.But not showing on screen
	PAUSED = "PAUSED", --scene is showing.But update not called.
	RUNNING = "RUNNING", --scene is running
})

local TRANSITIONS = COMMON.LUME.read_only({
	ON_HIDE = "ON_HIDE",
	ON_SHOW = "ON_SHOW",
	ON_BACK_SHOW = "ON_BACK_SHOW",
	ON_BACK_HIDE = "ON_BACK_HIDE",
})

return COMMON.LUME.read_only({
	STATES = STATES,
	TRANSITIONS = TRANSITIONS
})

