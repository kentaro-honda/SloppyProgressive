#import "SPStopWatch.h"

@interface SPStopWatch ()

@property (readwrite) NSUInteger milli;
@property (readwrite) NSUInteger second;
@property (readwrite) NSUInteger minute;
@property (readwrite) NSString *description;
@property NSString *secondString;
@property NSString *minuteString;
@property (readwrite) NSTimer *timer;
@property (readwrite) BOOL isOver;

- (void)count;

@end

@implementation SPStopWatch

- (id)init
{
	self = [super init];
	
	if (self) {
		self.milli = self.second = self.minute = 0;
		self.timer = nil;
		self.secondString = @"00";
		self.minuteString = @"00";
		self.description = @"00:00.0";
		self.milli_limit = self.second_limit = self.minute_limit = NSUIntegerMax;
		self.isOver = NO;
	}

	return self;
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
}

- (void)clear
{
	if ([self.timer isValid]) {
		return;
	}

	self.milli = self.second = self.minute = 0;
	self.secondString = @"00";
	self.minuteString = @"00";
	self.description = @"00:00.0";
	self.isOver = NO;
}

- (BOOL)isWorking
{
	return (self.timer) ? [self.timer isValid] : NO;
}

- (void)count
{
	++self.milli;

	if (self.milli < 10){
		self.description = [NSString stringWithFormat:@"%@:%@.%ld", self.minuteString, self.secondString, self.milli];
		if (!self.isOver && self.minute == self.minute_limit && self.second == self.second_limit && self.milli == self.milli_limit) {
			self.isOver = YES;
			NSBeep();
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
			NSBeep();
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
			NSBeep();
		}
		return;
	}
	self.minute = 0;
	self.minuteString = @"00";
	self.description = [NSString stringWithFormat:@"%@:%@.%ld", self.minuteString, self.secondString, self.milli];
}

@end
