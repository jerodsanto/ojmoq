@import "../OJMoq.j"

@implementation OJMoqTest : OJTestCase

- (void)testThatOJMoqLoads
{
	return [self assertNotNull:[[OJMoq alloc] initWithBaseObject:@"Test"]];
}

- (void)testThatOJMoqLoadsWithClassMethod
{
	return [self assertNotNull:[OJMoq mockBaseObject:@"Test"]];
}

- (void)testThatOJMoqLoadsWithJavascriptMethod
{
	return [self assertNotNull:moq(@"Test")];
}

- (void)testThatOJMoqDoesVerifyExpectationThatSelectorIsCalledOnce
{
	var mock = [OJMoq mockBaseObject:@"Test"];
	[mock expectThatSelector:@selector(length) isCalled:2];
	
	[mock length];
	[mock length];
		
	[mock verifyThatAllExpectationsHaveBeenMet];
}

- (void)testThatOJMoqDoesVerifyExpectationThatSelectorIsCalledTwice
{
	var mock = [OJMoq mockBaseObject:@"Test"];
	[mock expectThatSelector:@selector(length) isCalled:2];
	
	[mock length];
	[mock length];
		
	[mock verifyThatAllExpectationsHaveBeenMet];
}

- (void)testThatOJMoqDoesNotVerifyExpectationThatSelectorIsCalledTwiceWhenCalledOnce
{
	var mock = [OJMoq mockBaseObject:@"Test"];
	[mock expectThatSelector:@selector(length) isCalled:2];
	
	[mock length];
		
	[self assertThrows:function(){[mock verifyThatAllExpectationsHaveBeenMet]}];
}

- (void)testThatOJMoqDoesNotVerifyExpectationThatSelectorIsCalledTwiceWhenCalledThreeTimes
{
	var mock = [OJMoq mockBaseObject:@"Test"];
	[mock expectThatSelector:@selector(length) isCalled:2];
	
	[mock length];
	[mock length];
	[mock length];
		
	[self assertThrows:function(){[mock verifyThatAllExpectationsHaveBeenMet]}];
}

- (void)testThatOJMoqDoesVerifyExpectationsThatSelectorIsCalledOnceWithArguments
{
	var mock = moq(@"Test"); // shorthard function to make mocking easily. Idea from "flexmock()" in Ruby.
	var arguments = [CPArray arrayWithObject:@"Bob"];
	
	[mock expectThatSelector:@selector(compare:) isCalled:1 withArguments:new Array("Bob")];
	
	[mock compare:"Bob"];
	[mock compare:"Tom"];
	
	[mock verifyThatAllExpectationsHaveBeenMet];
}

- (void)testThatOJMoqDoesNotVerifyExpectationsThatSelectorIsCalledOnceWithArguments
{
	var mock = moq(@"Test"); // shorthard function to make mocking easily. Idea from "flexmock()" in Ruby.
	var arguments = [CPArray arrayWithObject:@"Bob"];
	
	[mock expectThatSelector:@selector(compare:) isCalled:1 withArguments:new Array("Bob")];
	
	[mock compare:"Tom"];
	
	[self assertThrows:function(){[mock verifyThatAllExpectationsHaveBeenMet]}];
}

- (void)testThatOJMoqDoesVerifyExpectationsThatSelectorIsCalledOnceWithArgumentsAndTwoExpectationsOnThoseArguments
{
	var mock = moq(@"Test"); // shorthard function to make mocking easily. Idea from "flexmock()" in Ruby.
	var arguments = [CPArray arrayWithObject:@"Bob"];
	
	[mock expectThatSelector:@selector(compare:) isCalled:1 withArguments:new Array("Bob")];
	[mock expectThatSelector:@selector(compare:) isCalled:1 withArguments:new Array("Tom")];
	
	[mock compare:"Bob"];
	[mock compare:"Tom"];
	
	[mock verifyThatAllExpectationsHaveBeenMet];
}

- (void)testThatOJMoqDoesNotVerifyExpectationsThatSelectorIsCalledOnceWithArgumentsAndTwoExpectationsOnThoseArguments
{
	var mock = moq(@"Test"); // shorthard function to make mocking easily. Idea from "flexmock()" in Ruby.
	var arguments = [CPArray arrayWithObject:@"Bob"];
	
	[mock expectThatSelector:@selector(compare:) isCalled:1 withArguments:new Array("Bob")];
	[mock expectThatSelector:@selector(compare:) isCalled:1 withArguments:new Array("Tom")];
	
	[mock compare:"Bob"];
	
	[self assertThrows:function(){[mock verifyThatAllExpectationsHaveBeenMet]}];
}

// Only necessarily until new release of ojtest.
- (void)assertThrows:(Function)zeroArgClosure
{
    var exception = nil;
    try { zeroArgClosure(); }
    catch (e) { exception = e; }
    [self assertNotNull:exception message:"Should have caught an exception, but got nothing"];
}

@end