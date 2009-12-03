OJMoq
=====

OJMoq is a mocking library for Objective-J. OJMoq can be dropped into any project and quickly, easily get people running with mocks.

Installation
============

New, and improved, you can now use the Narwhal package manager to install OJMoq. To pull down from github with tusk
    tusk update
    sudo tusk install ojmoq
And then to install it in your Cappuccino project, go to the project root (where AppController.j is) and run
    ojmoq init
And you're done! Now you can use @import <OJMoq/OJMoq.j> in your tests.

Usage
=====

To quickly get started, all you need to do is use the following line of code:
	
	var mock = moq();
	
And badda-bing-badda-boom! You have your very own mock ready to use. You can throw this object into any object and it will effectively stub out any dangerous or difficult dependency. For more information and features, see Advanced Techniques below. Also, you can see usage by looking at the OJMoqTest.j file in the tests folder above.

Advanced Techniques
===================

You can set expectations that will be verified:
	
	var mock = moq(@"Test");
	[mock expectSelector:@selector(equals:) times:2];
	[mock equals:@"Doesnt Matter"];
	[mock equals:@"Doesnt Matter"];
	[mock verifyThatAllExpectationsHaveBeenMet];  // verifies!
	
You can specify return values:
	
	var mock = moq(@"Test");
	[mock selector:@selector(equals:) returns:YES];
	[mock equals:@"Doesnt Matter"]; // returns YES
	
You can set expectations that will check parameters:
	
	var mock = moq(@"Test");
	var arguments = [CPArray withObject:@"WillStillPass"];
	[mock expectSelector:@selector(compare:) times:2 arguments:arguments];
	[mock compare:@"WillStillPass"];
	[mock compare:@"Bob"];
	[mock compare:@"WillStillPass"];
	[mock compare:@"Bill"];
	[mock verifyThatAllExpectationsHaveBeenMet]; // verifies!
	
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
	
or

	jake test
	
or, my favorite, with autotest

	autotest
	
from the top level of the project.

Even More Information
=====================

Look at OJMoqTest.j for usage.
Look at hammerdr/Omni-Software-Localization for more usage.

Contact me if you have questions, suggestions or comments!

Twitter: @hammerdr
On the Cappuccino IRC
On the Cappuccino mailing list
derek.r.hammer@gmail.com