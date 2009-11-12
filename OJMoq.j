@import <Foundation/CPObject.j>
@import "OJMoqSelector.j"
@import "CPArray+Find.j"
@import "CPInvocation+Arguments.j"

var wasntExpectingArguments = "Selector {0} wasn't expected to be called with arguments: {1}!";
var wasntCalledEnough = "Selector {0} wasn't called enough times. Expected: {1} Got: {2}";
var wasCalledTooMuch = "Selector {0} was called too many times. Expected: {1} Got: {2}";

/*!
 * A mocking library based off of the Moq library for .NET
 *
 * The benefits of OJMoq include easy-to-use standard mocking and
 * fluent advanced mocking. See the README for more details.
 */
@implementation OJMoq : CPObject
{
	CPObject	_baseObject		@accessors(readonly, property=object);
	CPArray		_selectors;
	CPArray		_expectations;
}

+ (id)mockBaseObject:(CPObject)baseObject
{
	return [[OJMoq alloc] initWithBaseObject:baseObject];
}

- (id)initWithBaseObject:(CPObject)baseObject
{
	if(self = [super init])
	{
		_baseObject = baseObject;
		
		_expectations = [[CPArray alloc] init];
		_selectors = [[CPArray alloc] init];
	}
	return self;
}

- (id)expectSelector:(SEL)selector times:(int)times
{
	return [self expectThatSelector:selector isCalled:times withArguments:[CPArray array]];
}

- (id)expectSelector:(SEL)selector times:(int)times arguments:(CPArray)arguments
{
	var theSelector = [[OJMoqSelector alloc] initWithName:sel_getName(selector) withArguments:arguments];
	var expectationFunction = function(){checkThatSelectorHasBeenCalledExpectedNumberOfTimesX(theSelector, times, _selectors);};
	[_expectations addObject:expectationFunction];
	return self;
}

- (id)selector:(SEL)aSelector returns:(CPObject)value
{
	var theSelector = findSelector([[OJMoqSelector alloc] initWithName:sel_getName(aSelector)], _selectors);
	if(theSelector)
	{
		[theSelector setReturnValue:value];
	}
	else
	{
		var aNewSelector = [[OJMoqSelector alloc] initWithName:sel_getName(aSelector)];
		[aNewSelector setReturnValue:value];
		[_selectors addObject:aNewSelector];
	}
}

- (id)verifyThatAllExpectationsHaveBeenMet
{
	for(var i = 0; i < [_expectations count]; i++)
	{
		_expectations[i]();
	}
	
	return self;
}

// Ignore the following interface unless you know what you are doing! 
// These are here to intercept calls to the underlying object and 
// should be handled automatically.

- (CPMethodSignature)methodSignatureForSelector:(SEL)aSelector
{
	return YES;
}

- (void)forwardInvocation:(CPInvocation)anInvocation
{
	var aSelector = [anInvocation selector];
	var theSelector = findSelector([[OJMoqSelector alloc] initWithName:sel_getName([anInvocation selector]) withArguments:[anInvocation userArguments]], _selectors);
	if(theSelector || [_baseObject respondsToSelector:aSelector])
	{
		incrementNumberOfCalls(anInvocation, _selectors);
		setReturnValue(anInvocation, _selectors);
	}
	else
	{
		CPLog("The base object does not have that selector!");
		[self doesNotRecognizeSelector:aSelector];
	}
}

@end

function incrementNumberOfCalls(anInvocation, _selectors)
{
	var theSelector = findSelector([[OJMoqSelector alloc] initWithName:sel_getName([anInvocation selector]) withArguments:[anInvocation userArguments]], _selectors);
	if(theSelector)
	{
		[theSelector setTimesCalled:[theSelector timesCalled]+1];
	}
	else
	{
		var aNewSelector = [[OJMoqSelector alloc] initWithName:sel_getName([anInvocation selector]) withArguments:[anInvocation userArguments]];
		[aNewSelector setTimesCalled:1];
		[_selectors addObject:aNewSelector];
	}
}

function setReturnValue(anInvocation, _selectors)
{
	var theSelector = findSelector([[OJMoqSelector alloc] initWithName:sel_getName([anInvocation selector])], _selectors);
	if(theSelector)
	{
		[anInvocation setReturnValue:[theSelector returnValue]];
	}
	else
	{
		[anInvocation setReturnValue:[CPObject init]];
	}
}

function fail(message)
{
    [CPException raise:AssertionFailedError reason:(message)];
}

function checkThatSelectorHasBeenCalledExpectedNumberOfTimesX(aSelector, expectedNumberOfTimes, _selectors)
{	
	var theSelector = findSelector(aSelector, _selectors);
	
	if(!theSelector)
	{
		fail(formattedString(wasntExpectingArguments, [aSelector name], [aSelector arguments]));
	}
	else if([theSelector timesCalled] < expectedNumberOfTimes)
	{
		fail(formattedString(wasntCalledEnough, [theSelector name], expectedNumberOfTimes, [theSelector timesCalled]));
	}
	else if([theSelector timesCalled] > expectedNumberOfTimes)
	{
		fail(formattedString(wasCalledTooMuch, [theSelector name], expectedNumberOfTimes, [theSelector timesCalled]));
	}
}

// Shameless copy from Yahoo UI library.
// http://developer.yahoo.com/yui/license.html
function formatedString() { 
  var num = arguments.length; 
  var oStr = arguments[0];
  for (var i = 1; i < num; i++) { 
    var pattern = "\\{" + (i-1) + "\\}"; 
    var re = new RegExp(pattern, "g"); 
    oStr = oStr.replace(re, arguments[i]); 
  } 
  return oStr; 
}

function moq()
{
	return [OJMoq mockBaseObject:[[CPObject alloc] init]];
}

function moq(baseObject)
{
	return [OJMoq mockBaseObject:baseObject];
}

function findSelector(selector, _selectors)
{
	return [_selectors findBy:function(anotherSelector){return [selector equals:anotherSelector]}];
}