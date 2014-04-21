#import "SPRecord.h"

NSUInteger staticID = 0;

@interface SPRecord ()
{
	NSString *studentID;
}

@end

@implementation SPRecord

+ (NSArray *)arrayWithContentsOfURL:(NSURL *)url
{
	NSUInteger oldStaticID;
	NSArray *array;
	NSMutableArray *results;
	SPRecord *record;

	if (!url) {
		return nil;
	}

	array = [NSArray arrayWithContentsOfURL:url];
	if (!array) {
		return nil;
	}
	results = [NSMutableArray array];

	oldStaticID = staticID;
	for (NSDictionary *dictionary in array) {
		record = [[SPRecord alloc] init];
		record.identifier = [dictionary[@"identifier"] unsignedIntegerValue];
		record.question = [dictionary[@"question"] unsignedIntegerValue];
		record.studentID = dictionary[@"studentID"];
		record.name = dictionary[@"name"];
		record.passed = [dictionary[@"passed"] boolValue];
		record.time = dictionary[@"time"];

		staticID = record.identifier + 1;

		[results addObject:record];
	}

	if (staticID < oldStaticID) {
		staticID = oldStaticID;
	}

	return [NSArray arrayWithArray:results];
}

- (id)init
{
	self = [super init];

	if (self) {
		self.identifier = staticID++;
		self.question = 0;
		self.studentID = @"";
		self.name = @"";
		self.passed = NO;
		self.time = @"00:00.0";
	}

	return self;
}

- (NSDictionary *)dictionary
{
	return @{@"identifier":[NSNumber numberWithUnsignedInteger:self.identifier],
			@"question":[NSNumber numberWithUnsignedInteger:self.question],
			@"studentID":self.studentID,
			@"name":self.name,
			@"passed":[NSNumber numberWithBool:self.passed],
			@"time":self.time};
}

- (void)setStudentID:(NSString *)newStudentID
{
	NSString *newName;

	newName = nil;
	if (![studentID isEqualToString:newStudentID]){
		newName = [self.delegate nameFromStudentID:newStudentID];
	}
	studentID = newStudentID;
	if (newName) {
		self.name = newName;
	}
}

- (NSString *)studentID
{
	return studentID;
}

- (BOOL)validateStudentID:(NSString **)newStudentID error:(NSError *__autoreleasing *)outError
{
	NSUInteger length;

	if (!*newStudentID) {
		return YES;
	}
	
	if (![[NSCharacterSet decimalDigitCharacterSet] isSupersetOfSet:[NSCharacterSet characterSetWithCharactersInString:*newStudentID]]) {
		if (outError) {
            *outError = [[NSError alloc] initWithDomain:SPRECORD_ERROR_DOMAIN
												   code:SPRECORD_INVALID_ID_CHARACTER_CODE
											   userInfo:@{ NSLocalizedDescriptionKey : @"ID must be composed by digits."}];
		}
		return NO;
	}

	length = [*newStudentID length];
	if (length != 8) {
		if (outError) {
            *outError = [[NSError alloc] initWithDomain:SPRECORD_ERROR_DOMAIN
												   code:SPRECORD_INVALID_ID_LENGTH_CODE
											   userInfo:@{ NSLocalizedDescriptionKey : @"The length of ID must be eight."}];
		}
		return NO;
	}
	return YES;
}

@end
