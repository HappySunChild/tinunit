local context = require(script.Parent.context)

local function describe(label: string, callback: () -> ())
	context.withInnerContext(function(outerContext)
		local innerContext = table.clone(outerContext)
		innerContext.labels = table.clone(outerContext.labels)

		table.insert(innerContext.labels, label)

		return innerContext
	end, callback)
end

return describe
