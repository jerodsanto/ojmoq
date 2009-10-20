OJMoq
=====

OJMoq is a mocking library for Objective-J. OJMoq can be dropped into any project and quick, easily get people running with mocks.

Usage
=====

To quickly get started, all you need to do is use the following line of code:
	
	var mock = [OJMoq mockBaseObject:yourObject];
	
And badda-bing-badda-boom! You have your very own mock ready to use.

Advanced Techniques
===================

You can set expectations that will be verified:
	
	var mock = [OJMoq mockBaseObject:@"Test"];
	[mock expectThatSelector:@selector(equals:) isCalled:2];
	[mock equals:@"Doesnt Matter"];
	[mock equals:@"Doesnt Matter"];
	[mock verifyThatAllExpectationsHaveBeenMet];  // verifies!
	
You can specify return values:
	
	var mock = [OJMoq mockBaseObject:@"Test"];
	[mock selector:@selector(equals:) returns:YES];
	[mock equals:@"Doesnt Matter"];
	
More to come!