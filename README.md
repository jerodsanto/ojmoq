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

The Power of OJMoq
==================

An example of a complex Moq that would be unreadable otherwise:
	
	var mock = moq(@"Test");
	[mock doSomething];
	[[[[[mock
	     expectThatSelector:@selector(equals:) isCalled:2]
	     selector:@selector(equals:) returns:YES]
	     expectThatSelector:@selector(compare:) isCalled:3]
	     selector:@selector(compare:) returns:NO]
	     verifyThatAllExpectationsHaveBeenMet];

Testing
=======

You can run the tests by running:

	ojtest tests/OJMoqTest.j
	
from the top level of the project.