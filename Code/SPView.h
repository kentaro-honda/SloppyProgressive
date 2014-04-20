#import <Cocoa/Cocoa.h>

@protocol SPViewDelegate
@property NSObjectController *objectController;
@end

@interface SPView : NSView

- (id)initWithDelegate:(id <SPViewDelegate>)delegate;
- (void)enterFullScreenMode:(NSScreen *)screen;

@end
