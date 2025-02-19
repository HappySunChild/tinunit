type Context = {}

local context = {}
local currentContext = nil

function context.getContext()
	return currentContext
end

function context.withContext(newContext: Context, callback)
	local oldContext = currentContext

	currentContext = newContext

	local success, err = pcall(callback, newContext)

	currentContext = oldContext

	if not success then
		error(err.message, 0)
	end
end

function context.withInnerContext(makeContext: (Context) -> Context, callback)
	local outerContext = context.getContext()
	local innerContext = makeContext(outerContext)

	context.withContext(innerContext, callback)
end

return context
