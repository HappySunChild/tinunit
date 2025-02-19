--!strict
local types = require(script.Parent.types)

local context = {}
local currentContext = nil

function context.getContext(): types.Context
	return currentContext or {}
end

function context.withContext(newContext: types.Context, callback: (types.Context) -> ())
	local oldContext = currentContext

	currentContext = newContext

	local success, err = pcall(callback, newContext)

	currentContext = oldContext

	if not success then
		error(err.message, 0)
	end
end

function context.withInnerContext(makeContext: (types.Context) -> types.Context, callback)
	local outerContext = context.getContext()
	local innerContext = makeContext(outerContext)

	context.withContext(innerContext, callback)
end

return context
