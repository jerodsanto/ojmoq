@implementation OJMoqSelector : CPObject
{
	CPString _name @accessors(property=name, readonly);
	CPInteger _timesCalled @accessors(property=timesCalled);
	id _returnValue @accessors(property=returnValue);
	CPArray _arguments @accessors(property=arguments);
}

-(id)initWithName:(CPString)aName withArguments:(CPArray)someArguments
{
	if(self = [super init])
	{
		_name = aName;
		_arguments = someArguments;
		_timesCalled = 0;
		_returnValue = [[CPObject alloc] init];
	}
	return self;
}

-(BOOL)equals:(OJMoqSelector)anotherSelector
{
	if(_name != [anotherSelector name])
	{
		return NO;
	}
	
	// If no arguments are specified, then we don't care.
	if([_arguments count] > 0 && ![_arguments isEqualToArray:[anotherSelector arguments]]) 
	{
		return NO;
	}
	
	return YES;
}

@end
