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

return nil
