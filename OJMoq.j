@import <Foundation/CPObject.j>

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
	}
	return self;
}

- (id)expectThatSelector:(SEL)selector isCalled:(int)times
{
	[_expectations addObject:function(){ if(_timesSelectorHasBeenCalled[selector] == times) {  return true; } else { assertFailed("Failed!"); return false; } }];
	
	return self;
}

- (id)verifyThatAllExpectationsHaveBeenMet
{
	for(var i = 0; i < [_expectations size]; i++)
	{
		_expectations[i]();
	}
	
	return self;
}

- (id)selector:(SEL)aSelector returns:(CPObject)value
{
	[_returnValues setObject:value forKey:aSelector];
}

- (CPMethodSignature)methodSignatureForSelector:(SEL)aSelector
{
	return YES;
}

- (void)forwardInvocation:(CPInvocation)anInvocation
{
	var aSelector = [anInvocation selector];
	if([_baseObject respondsToSelector:aSelector])
	{
		if([[_timesSelectorHasBeenCalled allKeys] containsObject:aSelector])
		{
			[_timesSelectorHasBeenCalled setObject:[_timesSelectorHasBeenCalled valueForKey:aSelector]+1 forKey:aSelector];
		}
		else
		{
			[_timesSelectorHasBeenCalled setObject:1 forKey:aSelector];
		}
		
		if([[_returnValues allKeys] containsObject:aSelector])
		{
			[anInvocation setReturnValue:[_returnValues objectForKey:aSelector]];
		}
		else
		{
			[anInvocation setReturnValue:[CPObject init]];
		}
	}
	else
	{
		CPLog("The base object does not have that selector!");
		[self doesNotRecognizeSelector:aSelector];
	}
}

@end

function assertFailed(message)
{
	throw message;
}
