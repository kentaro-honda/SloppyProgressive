#import <Cocoa/Cocoa.h>

@interface SPStopWatch : NSObject

@property (readonly) NSString *description;
@property (readonly) NSUInteger milli;
@property (readonly) NSUInteger second;
@property (readonly) NSUInteger minute;
@property (readonly) BOOL isWorking;

@property NSUInteger milli_limit;
@property NSUInteger second_limit;
@property NSUInteger minute_limit;
@property (readonly) BOOL isOver;

- (void)start;
- (void)stop;
- (void)clear;

@end
