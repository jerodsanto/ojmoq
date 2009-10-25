@import <Foundation/CPObject.j>
@import "OJMoqSelector.j"
@import "Find+CPArray.j"

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

- (id)expectThatSelector:(SEL)selector isCalled:(int)times
{
	var theSelector = [[OJMoqSelector alloc] initWithName:sel_getName(selector)];
	var expectationFunction = function(){checkThatSelectorHasBeenCalledExpectedNumberOfTimes(findSelector(theSelector, _selectors), times);};	
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

- (id)selector:(SEL)aSelector withArguments:(CPArray)someArguments returns:(CPObject)value
{
	
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
	if([_baseObject respondsToSelector:aSelector])
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
	var theSelector = findSelector([[OJMoqSelector alloc] initWithName:sel_getName([anInvocation selector])], _selectors);
	if(theSelector)
	{
		[theSelector setTimesCalled:[theSelector timesCalled]+1];
	}
	else
	{
		var aNewSelector = [[OJMoqSelector alloc] initWithName:sel_getName([anInvocation selector])];
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

function checkThatSelectorHasBeenCalledExpectedNumberOfTimes(theSelector, expectedNumberOfTimes)
{	
	if(!theSelector)
	{
		fail("Selector " + [theSelector name] + " wasn't expected to be called!");
	}
	else if([theSelector timesCalled] < expectedNumberOfTimes)
	{
		fail("Selector " + [theSelector name] + " wasn't called enough times. Expected: " + 
			expectedNumberOfTimes + " Got: " + [theSelector timesCalled]);
	}
	else if([theSelector timesCalled] > expectedNumberOfTimes)
	{
		fail("Selector " + [theSelector name] + " was called too many times. Expected: " + 
			expectedNumberOfTimes + " Got: " + [theSelector timesCalled]);
	}
}

function moq(baseObject)
{
	return [OJMoq mockBaseObject:baseObject];
}

function findSelector(selector, _selectors)
{
	return [_selectors findBy:function(anotherSelector){return [selector equals:anotherSelector]}];
}