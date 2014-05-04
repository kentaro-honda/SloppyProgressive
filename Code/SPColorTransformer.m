#import "SPColorTransformer.h"

@implementation SPColorTransformer

+ (Class)transformedValueClass
{
	return [NSColor class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
	return ([(NSNumber *)value boolValue]) ? [NSColor redColor] : [NSColor whiteColor];
}

@end
