#import "SPDateTransformer.h"

@implementation SPDateTransformer

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
	NSDateFormatter *formatter;

	formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"YYYY.MM.dd"];
	return [formatter stringFromDate:(NSDate *)value];
}

@end
