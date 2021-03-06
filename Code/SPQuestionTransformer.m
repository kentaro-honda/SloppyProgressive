#import "SPQuestionTransformer.h"

@implementation SPQuestionTransformer

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
	NSUInteger number;

	number = [(NSNumber *)value unsignedIntegerValue];

	return (number == 0) ? @"none" : (number > 100) ? @"04.5" : [NSString stringWithFormat:(number < 11) ? @"0%ld" : @"%ld", number-1];
}

@end
