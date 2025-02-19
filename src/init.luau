local context = require(script.context)

type Test = {
	labels: { string },
	callback: () -> (),
}

type Error = {
	type: 'errorReport',
	message: string,
	trace: string,
	origin: string,
}

type TestResults = {
	status: 'pass' | 'fail',
	error: Error?,
}

type RunResults = {
	tests: { Test },
	tally: { pass: number, fail: number },
	individual: { [Test]: TestResults },
}

local tinunit = {}
tinunit.decribe = require(script.describe)
tinunit.test = require(script.test)
tinunit.expect = require(script.expect)

function tinunit.collectTests(callback: () -> ())
	local tests = {}

	context.withContext({ labels = {}, tests = tests }, callback)

	return tests
end

function tinunit.runTests(tests: { Test }): RunResults
	local testContext = {}

	local individual = {}
	for _, test in tests do
		local _, testResults = xpcall(function()
			context.withContext(testContext, test.callback)

			return { status = 'pass' }
		end, function(message)
			if typeof(message) == 'table' and message.type == 'errorReport' then
				return { status = 'fail', error = message }
			end

			return {
				status = 'fail',
				error = {
					type = 'errorReport',
					message = tostring(message),
					trace = debug.traceback(),
				},
			}
		end)

		individual[test] = testResults
	end

	local tally = {
		pass = 0,
		fail = 0,
	}

	for _, result in individual do
		tally[result.status] += 1
	end

	return {
		tests = tests,
		tally = tally,
		individual = individual,
	}
end

local TERMINAL_WIDTH = 80
local BREADCRUMB = ' ▸ '
local DIVIDER = '═'
local MARGIN = '║'
local STATUS_ICONS = {
	pass = '[PASS]',
	fail = '[FAIL]',
}

local function title(text: string)
	local dividerCount = (TERMINAL_WIDTH - #text - 2) / 2
	local lhs = string.rep(DIVIDER, math.floor(dividerCount))
	local rhs = string.rep(DIVIDER, math.ceil(dividerCount))

	return `{lhs} {text} {rhs}\n`
end

local function window(text: string, label: string?)
	local maxWidth = 0

	text:gsub('[^\n\r]+', function(line)
		maxWidth = math.min(math.max(#line, maxWidth), TERMINAL_WIDTH)
	end)

	local top

	if label then
		top = `╔{DIVIDER} {label} {string.rep(DIVIDER, maxWidth - #label - 1)}╗`
	else
		top = `╔{string.rep(DIVIDER, maxWidth + 2)}╗`
	end

	local bottom = `╚{string.rep(DIVIDER, maxWidth + 2)}╝`

	local body = text:gsub('[^\n\r]+', function(line)
		local len = #line
		return `{MARGIN} {line}{string.rep(' ', maxWidth - len)} {MARGIN}`
	end)

	local output = `{top}\n{body}\n{bottom}`

	return output
end

function tinunit.formatRunResults(results: RunResults)
	local output = title 'Test Overview'

	for _, test in results.tests do
		local testResults = results.individual[test]

		output ..= `{STATUS_ICONS[testResults.status]} {table.concat(test.labels, BREADCRUMB)}\n`
	end

	if results.tally.fail > 0 then
		output ..= title(`Errors from {results.tally.fail}/{#results.tests} test(s)`)

		for _, test in results.tests do
			local testResults = results.individual[test]

			if testResults.status == 'pass' then
				continue
			end

			output ..= `{STATUS_ICONS.fail} {table.concat(test.labels, BREADCRUMB)}\n  {testResults.error.message}`

			local trace = window(testResults.error.trace:gsub('\n+$', ''), 'Stack Trace')
			output ..= `\n{trace}\n\n`
		end
	else
		output ..= `No errors in {#results.tests} test(s)!`
	end

	return output
end

return tinunit
