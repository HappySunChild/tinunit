--!strict
local function quote(x: any, indentAmount: number?)
	if type(x) == 'string' then
		return string.format('%q', x)
	elseif type(x) == 'function' then
		return 'function() ... end'
	elseif type(x) == 'table' then
		local tab = x :: { any }

		local outerIndentAmount = indentAmount or 0
		local innerIndentAmount = outerIndentAmount + 1

		local outerIndent = string.rep('  ', outerIndentAmount)
		local innerIndent = string.rep('  ', innerIndentAmount)

		local sortedPairs = {}

		for key, value in tab do
			table.insert(sortedPairs, {
				key = quote(key, innerIndentAmount),
				value = quote(value, innerIndentAmount),
			})
		end

		table.sort(sortedPairs, function(a, b)
			return a.key < b.key
		end)

		local frozen = table.isfrozen(tab)
		local lines = { frozen and 'table.freeze {' or '{' }

		for _, pair in sortedPairs do
			table.insert(lines, `{innerIndent}[{pair.key}] = {pair.value},`)
		end

		table.insert(lines, outerIndent .. '}')

		return table.concat(lines, '\n')
	end

	return tostring(x)
end

return quote
