local DEFTEST = require "tests.deftest.deftest"


local M = {}
function M.run()
	sys.set_error_handler(function (source,message,traceback)
		assert(nil,"main_menu error:" .. message)
	end)
	DEFTEST.run()
end

function M.update(dt)
	if DEFTEST.co and coroutine.status(DEFTEST.co)~="dead" then
		DEFTEST.continue(dt)
	end
end

return M