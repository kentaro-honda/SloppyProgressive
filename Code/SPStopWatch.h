#import <Cocoa/Cocoa.h>

@interface SPStopWatch : NSObject

@property (readonly) NSString *description;
@property (readonly) NSUInteger milli;
@property (readonly) NSUInteger second;
@property (readonly) NSUInteger minute;

- (void)start;
- (void)stop;
- (void)clear;

@end
