@import <Foundation/CPObject.j>

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
	CPDictionary _timesSelectorHasBeenCalled;
	CPArray		_expectations;
	CPDictionary _returnValues;
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
		
		_returnValues = [CPDictionary dictionary];
		_timesSelectorHasBeenCalled = [CPDictionary dictionary];
		
		_expectations = [[CPArray alloc] init];
		_selectors = [[CPArray alloc] init];
	}
	return self;
}

- (id)expectThatSelector:(SEL)selector isCalled:(int)times
{
	var expectationFunction = function(){checkThatSelectorHasBeenCalledExpectedNumberOfTimes(selector, times, _timesSelectorHasBeenCalled);};	
	[_expectations addObject:expectationFunction];	
	return self;
}

- (id)verifyThatAllExpectationsHaveBeenMet
{
	for(var i = 0; i < [_expectations count]; i++)
	{
		_expectations[i]();
	}
	
	return self;
}

- (id)selector:(SEL)aSelector returns:(CPObject)value
{
	[_returnValues setObject:value forKey:aSelector];
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
	if([_baseObject respondsToSelector:aSelector])
	{
		incrementNumberOfCalls(anInvocation, _timesSelectorHasBeenCalled);
		setReturnValue(anInvocation, _returnValues);
	}
	else
	{
		CPLog("The base object does not have that selector!");
		[self doesNotRecognizeSelector:aSelector];
	}
}

@end

function incrementNumberOfCalls(anInvocation, _timesSelectorHasBeenCalled)
{
	var aSelector = [anInvocation selector];
	if([[_timesSelectorHasBeenCalled allKeys] containsObject:aSelector])
	{
		[_timesSelectorHasBeenCalled setObject:[_timesSelectorHasBeenCalled valueForKey:aSelector]+1 forKey:aSelector];
	}
	else
	{
		[_timesSelectorHasBeenCalled setObject:1 forKey:aSelector];
	}
}

function setReturnValue(anInvocation, _returnValues)
{
	var aSelector = [anInvocation selector];
	if([[_returnValues allKeys] containsObject:aSelector])
	{
		[anInvocation setReturnValue:[_returnValues objectForKey:aSelector]];
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

function checkThatSelectorHasBeenCalledExpectedNumberOfTimes(selector, expectedNumberOfTimes, _timesSelectorHasBeenCalled)
{
	if([_timesSelectorHasBeenCalled objectForKey:selector] < expectedNumberOfTimes)
	{
		fail("Selector " + sel_getName(selector) + " wasn't called enough times. Expected: " + expectedNumberOfTimes + " Got: " + [_timesSelectorHasBeenCalled objectForKey:selector]);
	}
	else if([_timesSelectorHasBeenCalled objectForKey:selector] > expectedNumberOfTimes)
	{
		fail("Selector " + sel_getName(selector) + " was called too many times. Expected: " + expectedNumberOfTimes + " Got: " + [_timesSelectorHasBeenCalled objectForKey:selector]);			
	}
}

function moq(baseObject)
{
	return [OJMoq mockBaseObject:baseObject];
}