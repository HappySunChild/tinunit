--!nonstrict
local context = require(script.context)
local types = require(script.types)

local tinunit = {}
tinunit.describe = require(script.describe)
tinunit.test = require(script.test)
tinunit.expect = require(script.expect)
tinunit.format = require(script.format)

local function isTestModule(module: Instance)
	return (module:IsA 'ModuleScript' and module.Name:match '%.spec$' ~= nil)
end

local function getModules(root: Instance)
	local modules = {}

	for _, child in root:GetChildren() do
		if isTestModule(child) then
			table.insert(modules, require(child) :: (types.Context) -> ())
		end

		local subModules = getModules(child)

		for _, subModule in subModules do
			table.insert(modules, subModule)
		end
	end

	return modules :: {(types.Context) -> ()}
end

function tinunit.collectUnitTests(callback: (types.Context) -> ())
	local tests = {}

	context.withContext({ labels = {}, tests = tests }, callback)
	
	return tests
end

function tinunit.collectAllTests(root: Instance)
	local modules = getModules(root)
	local globalTests = {}
	
	for _, callback in modules do
		local unitTests = tinunit.collectUnitTests(callback)
		
		for _, test in unitTests do
			table.insert(globalTests, test)
		end
	end
	
	return globalTests
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

function tinunit.run(root: Instance)
	local tests = tinunit.collectAllTests(root)
	local results = tinunit.runTests(tests)
	
	print(tinunit.format(results))
end

return tinunit
