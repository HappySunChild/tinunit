--!nonstrict
local context = require(script.context)
local types = require(script.types)

local tinunit = {}
tinunit.describe = require(script.describe)
tinunit.test = require(script.test)
tinunit.expect = require(script.expect)
tinunit.format = require(script.format)

function tinunit.collectTests(callback: (types.Context) -> ())
	local tests = {}

	context.withContext({ labels = {}, tests = tests }, callback)

	return tests
end

function tinunit.runTests(tests: { types.Test }): types.RunResults
	local testContext = {}

	local individual: { [types.Test]: types.TestResults } = {}

	for _, test in tests do
		local _, testResults: types.TestResults = xpcall(function()
			context.withContext(testContext, test.callback)

			return { status = 'pass' } :: types.TestResults
		end, function(message: types.Error | string)
			local err = nil

			if typeof(message) == 'table' and message.type == 'errorReport' then
				err = message
			else
				err = {
					type = 'errorReport',
					message = tostring(message),
					trace = debug.traceback(),
				}
			end

			return {
				status = 'fail',
				error = err,
			}
		end)

		individual[test] = testResults
	end

	local tally = {
		pass = 0,
		fail = 0,
	}

	for _, result in individual do
		local index = result.status

		tally[index] += 1
	end

	return {
		tests = tests,
		tally = tally,
		individual = individual,
	} :: types.RunResults
end

return tinunit
