--!nonstrict
local quote = require(script.Parent.quote)

local function fail(message: string?, level: number?): never
	level = level or 3

	return error({
		message = {
			type = 'errorReport',
			message = message,
			trace = debug.traceback(nil, level),
		},
	}, 0)
end

local function assertFail(condition: boolean, message: string)
	if not condition then
		fail(message, 4)
	end
end

local function formatMessage(message: string, condition: boolean, ...: unknown): string
	local conditional = message:gsub(' NOT', condition and '' or ' not')

	return conditional:format(...)
end

local function isIndexable(value: unknown): boolean
	if type(value) == 'table' or type(value) == 'userdata' then
		return true
	end

	return false
end

local function expect(value: unknown)
	local condition: boolean = true

	local newExpectation = {}
	local methods = setmetatable({}, {
		__index = newExpectation,
	})

	function methods.ok()
		local success = (value ~= nil) == condition

		assertFail(success, formatMessage('Expected value to be NOT nil', condition))

		return methods
	end

	function methods.a(typeName: string)
		local success = (typeof(value) == typeName) == condition

		assertFail(
			success,
			formatMessage(
				"Expected value NOT of type '%s', got value %s of type '%s'",
				condition,
				typeName,
				quote(value),
				type(value)
			)
		)

		return methods
	end

	function methods.equal(otherValue: any)
		local success = (value == otherValue) == condition

		assertFail(
			success,
			formatMessage(
				'Expected value to NOT equal %s, got %s',
				condition,
				quote(otherValue),
				quote(value)
			)
		)

		return methods
	end

	function methods.near(otherValue: number, epsilon: number)
		assertFail(
			type(value) == 'number',
			"Expectation value must be a number to use 'near'"
		)
		assertFail(type(otherValue) == 'number', 'otherValue must be a number')
		assertFail(
			type(epsilon) == 'number' or epsilon == nil,
			'epsilon must be a number or nil'
		)

		epsilon = epsilon or 0.001

		local success = (math.abs((value :: number) - otherValue) <= epsilon) == condition

		assertFail(
			success,
			formatMessage(
				'Expected value to NOT be near %f (within %f) but got %f instead',
				condition,
				otherValue,
				epsilon,
				value
			)
		)

		return methods
	end

	function methods.throw(errorMessage: string?)
		local ok, err = pcall(value :: () -> string) -- have to lie about the function returning a string because luau-lsp still has this issue!
		local success = ok ~= condition

		local message = 'Expected function to NOT throw an error'

		if errorMessage and not ok then
			success = (string.match(err, errorMessage) ~= nil) == condition

			message =
				'Expected function to NOT throw an error containing %q, but it threw: %q'
		end

		assertFail(success, formatMessage(message, condition, errorMessage, err))

		return methods
	end

	function methods.key(key: any)
		assertFail(key ~= nil, 'key cannot be nil')
		assertFail(
			isIndexable(value),
			`Expected value to be indexable, got {type(value)}`
		)

		local success = ((value :: { any })[key] ~= nil) == condition

		assertFail(
			success,
			formatMessage('Expected value to NOT have key %s', condition, quote(key))
		)

		return methods
	end

	function methods.value(subValue: any)
		assertFail(
			isIndexable(value),
			`Expected value to be indexable, got {type(value)}`
		)

		local success = (table.find(value :: { any }, subValue) ~= nil) == condition

		assertFail(
			success,
			formatMessage(
				'Expected value to NOT have value %s',
				condition,
				quote(subValue)
			)
		)

		return methods
	end

	methods.an = methods.a

	newExpectation.be = methods
	newExpectation.to = methods
	newExpectation.ever = methods
	newExpectation.have = methods

	newExpectation.never = function()
		condition = not (condition :: boolean)

		return methods
	end

	return newExpectation
end

return expect
