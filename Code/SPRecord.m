#import "SPRecord.h"

NSUInteger staticID = 0;

@interface SPRecord ()
{
	NSString *studentID;
}

@property (readwrite) BOOL editable;

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
		record.date = dictionary[@"date"];
		record.editable = [record.date timeIntervalSinceNow] > -24*60*60;

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
		self.date = [NSDate date];
		self.editable = YES;
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
			@"time":self.time,
			@"date":self.date};
}

- (void)setStudentID:(NSString *)newStudentID
{
	NSString *newName;

	newName = nil;
	if (![studentID isEqualToString:newStudentID] && [self.delegate respondsToSelector:@selector(nameFromStudentID:)]){
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
	NSString *completed;

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
		if ([self.delegate respondsToSelector:@selector(completeStudentID:)]) {
			completed = [self.delegate completeStudentID:*newStudentID];
			if (completed != nil) {
				*newStudentID = completed;
				return YES;
			}
		}

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
