#import "SPPassedColorTransformer.h"

@implementation SPPassedColorTransformer

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
	BOOL passed;

	passed = [(NSNumber *)value boolValue];

	return (passed) ? [NSColor greenColor] : [NSColor redColor];
}

@end
