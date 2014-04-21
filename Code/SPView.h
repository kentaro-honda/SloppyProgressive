#import <Cocoa/Cocoa.h>

@protocol SPViewDelegate
@property NSObjectController *objectController;

- (void)start;
- (void)stop;
- (void)clear;
- (void)toggle;

@end

@interface SPView : NSView

- (id)initWithDelegate:(id <SPViewDelegate>)delegate;
- (void)enterFullScreenMode:(NSScreen *)screen;

@end
