--!strict

export type Test = {
	labels: { string },
	callback: (RunContext) -> (),
}

export type Error = {
	type: 'errorReport',
	message: string,
	trace: string,
}

export type TestResults = {
	status: 'pass' | 'fail',
	error: Error?,
}

export type RunResults = {
	tests: { Test },
	tally: { pass: number, fail: number, [string]: number },
	individual: { [Test]: TestResults },
}

export type DescribeContext = {
	labels: { string },
	tests: { Test },
}
export type RunContext = {}
export type Context = DescribeContext | RunContext

export type Expectation<V> = {
	_value: V,
	_condition: boolean,

	also: Expectation<V>,
	please: Expectation<V>,
	have: Expectation<V>,
	to: Expectation<V>,
	be: Expectation<V>,
	ever: Expectation<V>,
	never: Expectation<V>,

	ok: () -> Expectation<V>,
	a: (class: string) -> Expectation<V>,
	an: (class: string) -> Expectation<V>,
	equal: (other: any) -> Expectation<V>,
	near: (other: number, epsilon: number) -> Expectation<V>,
	above: (other: number) -> Expectation<V>,
	below: (other: number) -> Expectation<V>,
	throw: (message: string?) -> Expectation<V>,
	work: () -> Expectation<V>,
	key: (key: any) -> Expectation<V>,
	value: (value: any) -> Expectation<V>,
}

return nil
