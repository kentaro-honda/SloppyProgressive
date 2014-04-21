#import <Cocoa/Cocoa.h>

@interface SPStopWatch : NSObject

@property (readonly) NSString *description;
@property (readonly) NSUInteger milli;
@property (readonly) NSUInteger second;
@property (readonly) NSUInteger minute;
@property (readonly) BOOL isWorking;

- (void)start;
- (void)stop;
- (void)clear;

@end
