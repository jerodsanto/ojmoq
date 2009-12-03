@import <Foundation/CPObject.j>
@import "OJMoqSelector.j"
@import "CPArray+Find.j"
@import "CPInvocation+Arguments.j"

var failedCalledMessage = "The base object does not have that selector or you forgot to set up expectations for selector %@!";
var wasntExpectingArguments = "Selector %@ wasn't expected to be called with arguments: %@!";
var wasntCalledEnough = "Selector %@ wasn't called enough times. Expected: %@ Got: %@";
var wasCalledTooMuch = "Selector %@ was called too many times. Expected: %@ Got: %@";

// Create a mock object based on a typical object.
function moq()
{
	return moq([[CPObject alloc] init]);
}

// Create a mock object based on a given object.
function moq(baseObject)
{
	return [OJMoq mockBaseObject:baseObject];
}

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
	return [self expectSelector:selector times:times arguments:[CPArray array]];
}

- (id)expectSelector:(SEL)selector times:(int)times arguments:(CPArray)arguments
{
	var theSelector = [[OJMoqSelector alloc] initWithName:sel_getName(selector) withArguments:arguments];
	var expectationFunction = function(){__ojmoq_checkThatSelectorHasBeenCalledExpectedNumberOfTimes(theSelector, times, _selectors);};
	[_expectations addObject:expectationFunction];
	return self;
}

- (id)selector:(SEL)aSelector returns:(CPObject)value
{
	[self selector:aSelector withArguments:[CPArray array] returns:value];
}

- (id)selector:(SEL)aSelector withArguments:(CPArray)arguments returns:(CPObject)value
{
	var theSelector = __ojmoq_findSelector([[OJMoqSelector alloc] initWithName:sel_getName(aSelector) withArguments:arguments], _selectors);
	if(theSelector)
	{
		[theSelector setReturnValue:value];
	}
	else
	{
		var aNewSelector = [[OJMoqSelector alloc] initWithName:sel_getName(aSelector) withArguments:arguments];
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
	__ojmoq_incrementNumberOfCalls(anInvocation, _selectors);
	__ojmoq_setReturnValue(anInvocation, _selectors);
}

@end

function __ojmoq_incrementNumberOfCalls(anInvocation, _selectors)
{
	var theSelector = __ojmoq_findSelector([[OJMoqSelector alloc] initWithName:sel_getName([anInvocation selector]) 
		withArguments:[anInvocation userArguments]], _selectors);
	if(theSelector)
	{
		[theSelector setTimesCalled:[theSelector timesCalled]+1];
	}
	else
	{
		var aNewSelector = [[OJMoqSelector alloc] initWithName:sel_getName([anInvocation selector]) 
			withArguments:[anInvocation userArguments]];
		[aNewSelector setTimesCalled:1];
		[_selectors addObject:aNewSelector];
	}
}

function __ojmoq_setReturnValue(anInvocation, _selectors)
{
	var theSelector = __ojmoq_findSelector([[OJMoqSelector alloc] initWithName:sel_getName([anInvocation selector]) withArguments:[anInvocation userArguments]], _selectors);
	if(theSelector)
	{
		[anInvocation setReturnValue:[theSelector returnValue]];
	}
	else
	{
		[anInvocation setReturnValue:[[CPObject alloc] init]];
	}
}

function __ojmoq_fail(message)
{
    [CPException raise:AssertionFailedError reason:message];
}

function __ojmoq_checkThatSelectorHasBeenCalledExpectedNumberOfTimes(aSelector, expectedNumberOfTimes, _selectors)
{	
	var theSelector = __ojmoq_findSelector(aSelector, _selectors);
	
	if(!theSelector)
	{
		__ojmoq_fail([CPString stringWithFormat:wasntExpectingArguments, [aSelector name], [aSelector arguments]]);
	}
	else if([theSelector timesCalled] < expectedNumberOfTimes)
	{
		__ojmoq_fail([CPString stringWithFormat:wasntCalledEnough, [theSelector name], 
			expectedNumberOfTimes, [theSelector timesCalled]]);
	}
	else if([theSelector timesCalled] > expectedNumberOfTimes)
	{
		__ojmoq_fail([CPString stringWithFormat:wasCalledTooMuch, [theSelector name], 
			expectedNumberOfTimes, [theSelector timesCalled]]);
	}
}

function __ojmoq_findSelector(selector, _selectors)
{
	return [_selectors findBy:function(anotherSelector){return [selector equals:anotherSelector]}];
}