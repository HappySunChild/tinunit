local context = require(script.Parent.context)

local function test(label: string, callback: () -> ())
	local currentContext = context.getContext()

	local labels = table.clone(currentContext.labels)
	table.insert(labels, label)

	table.insert(currentContext.tests, {
		labels = labels,
		callback = callback,
	})
end

return test
