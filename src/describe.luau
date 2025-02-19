--!strict
local context = require(script.Parent.context)
local types = require(script.Parent.types)

local function describe(label: string, callback: (types.Context) -> ())
	context.withInnerContext(function(outerContext)
		local innerContext = table.clone(outerContext :: types.DescribeContext)
		innerContext.labels = table.clone((outerContext :: types.DescribeContext).labels)

		table.insert(innerContext.labels, label)

		return innerContext
	end, callback)
end

return describe
