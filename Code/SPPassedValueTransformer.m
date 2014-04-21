#import "SPPassedValueTransformer.h"

@implementation SPPassedValueTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
	BOOL passed;
	char check[] = "\u2713";
	char cross[] = "\u2717";

	passed = [(NSNumber *)value boolValue];

	return [[NSString alloc] initWithUTF8String:(passed) ? check : cross];
}

@end
