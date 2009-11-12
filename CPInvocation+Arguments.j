@implementation CPInvocation (Arguments)

- (CPArray)arguments
{
	return _arguments;
}

- (CPArray)userArguments
{
	return _arguments.splice(0,2);
}

@end