--!strict
local types = require(script.Parent.types)

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

local function formatMessage(message: string, condition: boolean): string
	if condition then
		message = message:gsub('%s*CF%(.-%)', '')
	else
		message = message:gsub('%s*CT%(.-%)', '')
	end

	message = message:gsub('%u+%((.-)%)', function(inner: string)
		return inner
	end)

	return message
end

local function isIndexable(value: unknown): boolean
	if type(value) == 'table' or type(value) == 'userdata' then
		return true
	end

	return false
end

local SELF_KEYS = {
	also = true,
	please = true,
	have = true,
	to = true,
	be = true,
	ever = true,
}
local INVERT_KEYS = {
	never = true,
}

local class = {}
local METATABLE = table.freeze {
	__index = function(self: types.Expectation<unknown>, key: any)
		if INVERT_KEYS[key] then
			self._condition = not self._condition

			return self
		elseif SELF_KEYS[key] then
			return self
		end

		return class[key]
	end,
}

local function expect<V>(value: V): types.Expectation<V>
	local newExpectation = setmetatable({
		_value = value,
		_condition = true,
	}, METATABLE)

	return newExpectation :: types.Expectation<V>
end

function class.ok(self: types.Expectation<unknown>)
	local value, condition = self._value, self._condition
	local success = (value ~= nil) == condition

	assertFail(
		success,
		formatMessage(
			`Expected value to be CT(not) nil CF(, got {tostring(value)})`,
			condition
		)
	)

	return expect(value)
end

function class.a(self: types.Expectation<unknown>, typeName: string)
	local value, condition = self._value, self._condition

	local success = (typeof(value) == typeName) == condition

	assertFail(
		success,
		formatMessage(
			`Expected value CF(not) of type '{typeName}', got value '{tostring(value)}' of type '{type(
				value
			)}'`,
			condition
		)
	)

	return expect(value)
end

function class.equal(self: types.Expectation<unknown>, otherValue: any)
	local value, condition = self._value, self._condition

	local success = (value == otherValue) == condition

	assertFail(
		success,
		formatMessage(
			`Expected value to CF(not) equal {otherValue}, got {value}`,
			condition
		)
	)

	return expect(value)
end

function class.near(self: types.Expectation<unknown>, otherValue: number, epsilon: number)
	local value, condition = self._value, self._condition

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
			`Expected value to CF(not) be near {otherValue} (within {epsilon}) but CT(got) CF(value is) {value}`,
			condition
		)
	)

	return expect(value)
end

function class.above(self: types.Expectation<unknown>, otherValue: number)
	local value, condition = self._value, self._condition

	assertFail(
		type(value) == 'number',
		"Expectation value must be a number to use 'above'"
	)
	assertFail(type(otherValue) == 'number', 'otherValue must be a number')

	local success = ((value :: number) > otherValue) == condition

	assertFail(
		success,
		formatMessage(
			`Expected value to CF(not) be above {otherValue}, but got {value}`,
			condition
		)
	)

	return expect(value)
end

function class.below(self: types.Expectation<unknown>, otherValue: number)
	local value, condition = self._value, self._condition

	assertFail(
		type(value) == 'number',
		"Expectation value must be a number to use 'above'"
	)
	assertFail(type(otherValue) == 'number', 'otherValue must be a number')

	local success = ((value :: number) < otherValue) == condition

	assertFail(
		success,
		formatMessage(
			`Expected value to CF(not) be below {otherValue}, but got {value}`,
			condition
		)
	)

	return expect(value)
end

function class.throw(self: types.Expectation<unknown>, errorMessage: string?)
	local value, condition = self._value, self._condition

	local ok, err = pcall(value :: () -> string) -- have to lie about the function returning a string because luau-lsp still has this issue!
	local success = ok ~= condition

	local message = `Expected function to CF(not) throw an errorCF(, but it threw: {err})`

	if errorMessage and not ok then
		success = (string.match(err, errorMessage) ~= nil) == condition

		message =
			`Expected function to CF(not) throw an error containing "{errorMessage}", but it threw: "{err}"`
	end

	assertFail(success, formatMessage(message, condition))

	return expect(value)
end

function class.key(self: types.Expectation<unknown>, key: any)
	local value, condition = self._value, self._condition

	assertFail(key ~= nil, 'key cannot be nil')
	assertFail(isIndexable(value), `Expected value to be indexable, got {type(value)}`)

	local success = ((value :: { any })[key] ~= nil) == condition

	assertFail(
		success,
		formatMessage(`Expected value to CF(not) have key {tostring(key)}`, condition)
	)

	return expect(value)
end

function class.value(self: types.Expectation<unknown>, subValue: any)
	local value, condition = self._value, self._condition

	assertFail(isIndexable(value), `Expected value to be indexable, got {type(value)}`)

	local success = (table.find(value :: { any }, subValue) ~= nil) == condition

	assertFail(
		success,
		formatMessage(
			`Expected value to CF(not) have value {tostring(subValue)}`,
			condition
		)
	)

	return expect(value)
end

function class.work(self: types.Expectation<unknown>)
	local value, condition = self._value, self._condition

	local success = pcall(value :: () -> ())

	assertFail(
		success == condition,
		formatMessage(`Expected function to CF(not) workCF(, but it did)`, condition)
	)

	return expect(value)
end

class.an = class.a

return expect
