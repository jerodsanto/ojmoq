@implementation CPInvocation (Arguments)

- (CPArray)arguments
{
	return _arguments;
}

- (CPArray)userArguments
{
	var userArguments = [CPArray array];
	
	for(var i = 2; i < [_arguments count]; i++)
	{
		[userArguments addObject:[_arguments objectAtIndex:i]];
	}
	
	return userArguments;
}

@end