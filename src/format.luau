--!strict
local types = require(script.Parent.types)

local TERMINAL_WIDTH = 80
local BREADCRUMB = ' ▸ '
local DIVIDER = '═'
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

local function format(results: types.RunResults)
	local output = title 'Test Overview'

	for _, test in results.tests do
		local testResults = results.individual[test]

		output ..= `{STATUS_ICONS[testResults.status]} {table.concat(
			test.labels,
			BREADCRUMB
		)}\n`
	end

	if results.tally.fail > 0 then
		output ..= title(`Errors from {results.tally.fail}/{#results.tests} test(s)`)

		for _, test in results.tests do
			local testResults = results.individual[test]

			if testResults.status == 'pass' then
				continue
			end

			local err = testResults.error

			if not err then
				continue
			end

			output ..= `{STATUS_ICONS.fail} {table.concat(test.labels, BREADCRUMB)}\n  |\n  | {err.message}\n  |`

			local trace = err.trace:gsub('\n+$', ''):gsub('\n', '\n  | ')
			output ..= `\n  | Stack Trace:\n  | {trace}\n\n`
		end
	else
		output ..= `No errors in {#results.tests} test(s)!`
	end

	return output
end

return format
