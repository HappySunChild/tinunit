local ServerScriptService = game:GetService 'ServerScriptService'

local tinunit = require(ServerScriptService.tinunit)
local describe, test, expect = tinunit.describe, tinunit.test, tinunit.expect

local function exampleTest()
	describe('epic feature', function()
		test('math works', function()
			expect(1 + 1).to.equal(2)
			expect(3 + 3).to.equal(6)
		end)

		test('throw test', function()
			expect(function()
					error 'goodbye'
				end).to.throw('goodbye')
		end)

		test('key test', function()
			expect({}).to.have.key('test')
		end)
	end)
end

local tests = tinunit.collectUnitTests(exampleTest)
local results = tinunit.runTests(tests)

print(tinunit.formatRunResults(results))
