#import "SPStopWatch.h"

@interface SPStopWatch ()
{
	NSString *description;
}

@property (readwrite) NSUInteger milli;
@property (readwrite) NSUInteger second;
@property (readwrite) NSUInteger minute;
@property NSString *secondString;
@property NSString *minuteString;
@property (readwrite) NSTimer *timer;
@property (readwrite) BOOL isOver;

@property id observedObjectForDescription;
@property NSString *observedKeyPathForDescription;

- (void)count;
- (void)updatedDescription;
- (void)beep;

@end

@implementation SPStopWatch

- (id)init
{
	self = [super init];
	
	if (self) {
		self.timer = nil;
		self.description = @"00:00.0";
		self.milli_limit = self.second_limit = self.minute_limit = NSUIntegerMax;
		self.isOver = NO;
	}

	return self;
}

- (NSString *)description
{
	return description;
}

- (void)setDescription:(NSString *)newDescription
{
	NSCharacterSet *set;
	NSScanner *scanner;
	NSString *string;
	unsigned long long integer;

	description = newDescription;

	if (!newDescription || self.isWorking) {
		return;
	}

	scanner = [NSScanner scannerWithString:newDescription];
	set = [NSCharacterSet characterSetWithCharactersInString:@":."];
	[scanner setCharactersToBeSkipped:set];
	if (![scanner scanUpToCharactersFromSet:set intoString:&string]) {
		return;
	}
	self.minuteString = [NSString stringWithString:string];
	if (![scanner scanUpToCharactersFromSet:set intoString:&string]) {
		return;
	}
	self.secondString = [NSString stringWithString:string];
	if (![scanner scanUnsignedLongLong:&integer]) {
		return;
	}
	self.minute = [self.minuteString integerValue];
	self.second = [self.secondString integerValue];
	self.milli = integer;
}

- (void)start;
{
	if (self.timer) {
		return;
	}

	self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(count) userInfo:nil repeats:YES];
}

- (void)stop
{
	[self.timer invalidate];
	self.timer = nil;

	[self updatedDescription];
}

- (void)updatedDescription
{
	if (self.observedObjectForDescription != nil) {
		[self.observedObjectForDescription setValue:self.description forKeyPath:self.observedKeyPathForDescription];
	}
}

- (void)clear
{
	if ([self.timer isValid]) {
		return;
	}

	self.description = @"00:00.0";
	self.isOver = NO;

	[self updatedDescription];
}

- (BOOL)isWorking
{
	return (self.timer) ? [self.timer isValid] : NO;
}

- (void)beep
{
	[[NSSound soundNamed:@"Glass"] play];
	[[NSSound soundNamed:@"Ping"] play];
}

- (void)count
{
	++self.milli;

	if (self.milli < 10){
		self.description = [NSString stringWithFormat:@"%@:%@.%ld", self.minuteString, self.secondString, self.milli];
		if (!self.isOver && self.minute == self.minute_limit && self.second == self.second_limit && self.milli == self.milli_limit) {
			self.isOver = YES;
			[self beep];
		}
		return;
	}
	self.milli = 0;
	++self.second;

	if (self.second < 60){
		self.secondString = [NSString stringWithFormat:(self.second < 10) ? @"0%ld" : @"%ld", self.second];
		self.description = [NSString stringWithFormat:@"%@:%@.%ld", self.minuteString, self.secondString, self.milli];
		if (!self.isOver && self.minute == self.minute_limit && self.second == self.second_limit && self.milli == self.milli_limit) {
			self.isOver = YES;
			[self beep];
		}
		return;
	}
	self.second = 0;
	self.secondString = @"00";
	++self.minute;

	if (self.minute < 100){
		self.minuteString = [NSString stringWithFormat:(self.minute < 10) ? @"0%ld" : @"%ld", self.minute];
		self.description = [NSString stringWithFormat:@"%@:%@.%ld", self.minuteString, self.secondString, self.milli];
		if (!self.isOver && self.minute == self.minute_limit && self.second == self.second_limit && self.milli == self.milli_limit) {
			self.isOver = YES;
			[self beep];
		}
		return;
	}
	self.minute = 0;
	self.minuteString = @"00";
	self.description = [NSString stringWithFormat:@"%@:%@.%ld", self.minuteString, self.secondString, self.milli];
}

- (void)bind:(NSString *)binding toObject:(id)observableObject withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	if ([binding isEqualToString:@"description"]) {
		self.observedObjectForDescription = observableObject;
		self.observedKeyPathForDescription = keyPath;
	}

	[super bind:binding toObject:observableObject withKeyPath:keyPath options:options];
}
@end
