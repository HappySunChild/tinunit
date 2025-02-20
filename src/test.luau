--!strict
local context = require(script.Parent.context)
local types = require(script.Parent.types)

local function test(label: string, callback: () -> ())
	local currentContext = context.getContext() :: types.DescribeContext

	if not currentContext then
		return
	end

	local labels = table.clone(currentContext.labels)
	table.insert(labels, label)
	table.insert(currentContext.tests, {
		labels = labels,
		callback = callback,
	})
end

return test
