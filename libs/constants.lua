local lume = require "libs.lume"

local M = {}


M.SYSTEM_INFO = sys.get_sys_info()
M.PLATFORM = M.SYSTEM_INFO.system_name
M.PLATFORM_IS_WEB = M.PLATFORM == "HTML5"
M.PLATFORM_IS_WINDOWS = M.PLATFORM == "Windows"
M.PLATFORM_IS_LINUX = M.PLATFORM == "Linux"
M.PLATFORM_IS_MACOS = M.PLATFORM == "Darwin"
M.PLATFORM_IS_ANDROID = M.PLATFORM == "Android"
M.PLATFORM_IS_IPHONE = M.PLATFORM == "iPhone OS"

M.PLATFORM_IS_PC = M.PLATFORM_IS_WINDOWS or M.PLATFORM_IS_LINUX or M.PLATFORM_IS_MACOS
M.PLATFORM_IS_MOBILE = M.PLATFORM_IS_ANDROID or M.PLATFORM_IS_IPHONE

M.PROJECT_VERSION = sys.get_config("project.version")

M.GAME_VERSION = sys.get_config("game.version")

M.VERSION_IS_DEV = M.GAME_VERSION == "dev"
M.VERSION_IS_RELEASE = M.GAME_VERSION == "release"

M.GAME_TARGET = sys.get_config("game.target")

M.TARGETS = {
    EDITOR = "editor",
    PLAY_MARKET = "play_market",
    GAME_DISTRIBUTION = "game_distribution",
    POKI = "poki",
    ITCH_IO = "itch_io",
    YANDEX_GAMES = "yandex_games",
}

assert(lume.find(M.TARGETS, M.GAME_TARGET), "unknown target:" .. M.GAME_TARGET)

M.TARGET_IS_EDITOR = M.GAME_TARGET == M.TARGETS.EDITOR
M.TARGET_IS_PLAY_MARKET = M.GAME_TARGET == M.TARGETS.PLAY_MARKET
M.TARGET_IS_GAME_DISTRIBUTION = M.GAME_TARGET == M.TARGETS.GAME_DISTRIBUTION
M.TARGET_IS_POKI = M.GAME_TARGET == M.TARGETS.POKI
M.TARGET_IS_ITCH_IO = M.GAME_TARGET == M.TARGETS.ITCH_IO
M.TARGET_IS_YANDEX_GAMES = M.GAME_TARGET == M.TARGETS.YANDEX_GAMES

M.IS_TESTS = sys.get_config("tests.tests_run")

M.LOCALIZATION = {
    DEFAULT = sys.get_config("localization.default") or "en",
    USE_SYSTEM = (sys.get_config("localization.use_system") or "false") == "true",
    FORCE_LOCALE = sys.get_config("localization.force_locale")
}

M.GUI_ORDER = {
    GAME = 2,
    MODAL_1 = 3,
    MODAL_2 = 4,
    MODAL_3 = 5,
    DEBUG = 15,
}

return M
