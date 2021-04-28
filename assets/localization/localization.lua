local I18N = require "libs.i18n.init"
local LOG = require "libs.log"
local CONSTANTS = require "libs.constants"
local TAG = "LOCALIZATION"
local LUME = require "libs.lume"
local LOCALES = { "en", "ru" }
local DEFAULT = CONSTANTS.LOCALIZATION.DEFAULT
local FALLBACK = DEFAULT

---@class Localization
local M = {
	highscore_lbl = { en = "HIGHSCORE\n%{score}", ru = "РЕКОРД\n%{score}" },
	highscore_new_lbl = { en = "NEW HIGHSCORE\n%{score}", ru = "НОВЫЙ РЕКОРД\n%{score}" },

}

function M:locale_exist(key)
	local locale = self[key]
	if not locale then
		LOG.w("key:" .. key .. " not found", TAG,2)
	end
end

function M:set_locale(locale)
	LOG.w("set locale:" .. locale,TAG)
	I18N.setLocale(locale)
end

function M:locale_get()
	return I18N.getLocale()
end

I18N.setFallbackLocale(FALLBACK)
M:set_locale(DEFAULT)
if(CONSTANTS.LOCALIZATION.FORCE_LOCALE)then
	LOG.i("force locale:" .. CONSTANTS.LOCALIZATION.FORCE_LOCALE,TAG)
	M:set_locale(CONSTANTS.LOCALIZATION.FORCE_LOCALE)
elseif(CONSTANTS.LOCALIZATION.USE_SYSTEM)then
	local system_locale = sys.get_sys_info().language
	LOG.i("system locale:" .. system_locale,TAG)
	if(LUME.findi(LOCALES,system_locale)) then
		M:set_locale(system_locale)
	else
		LOG.i("unknown system locale:" .. system_locale,TAG)
		pprint(LOCALES)
	end

end

for _, locale in ipairs(LOCALES) do
	local table = {}
	for k, v in pairs(M) do
		if type(v) ~= "function" then
			table[k] = v[locale]
		end
	end
	I18N.load({ [locale] = table })
end

for k, v in pairs(M) do
	if type(v) ~= "function" then
		M[k] = function(data)
			return I18N(k, data)
		end
	end
end

--return key if value not founded
---@type Localization
local t = setmetatable({ __VALUE = M, }, {
	__index = function(_, k)
		local result = M[k]
		if not result then
			LOG.w("no key:" .. k, TAG,2)
			result = function() return k end
			M[k] = result
		end
		return result
	end,
	__newindex = function() error("table is readonly", 2) end,
})


return t
