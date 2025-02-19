local ServerScriptService = game:GetService 'ServerScriptService'

local tinunit = require(ServerScriptService.tinunit)
local describe, test, expect = tinunit.decribe, tinunit.test, tinunit.expect

local function exampleTest()
	describe('epic feature', function()
		test('math works', function()
			expect(1 + 1).to.equal(2)
			expect(3 + 3).to.equal(6)
		end)

		test('throw test', function()
			expect(function()
					error 'goodbye'
				end).to
				.never()
				.throw()
		end)

		test('key test', function()
			expect(1).to.have.value(123)
		end)
	end)
end

local tests = tinunit.collectTests(exampleTest)
local results = tinunit.runTests(tests)

print(tinunit.formatRunResults(results))
