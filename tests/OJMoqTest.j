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

- (void)testThatOJMoqDoesVerifyExpectationThatSelectorIsCalledOnce
{
	var mock = [OJMoq mockBaseObject:@"Test"];
	[mock expectThatSelector:@selector(length) isCalled:2];
	
	[mock length];
	[mock length];
		
	[mock verifyThatAllExpectationsHaveBeenMet];
}


@end