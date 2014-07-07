#import <Cocoa/Cocoa.h>
#import "SPView.h"

@protocol SPGUIControllerDelegate <SPViewDelegate>

@property NSArrayController *arrayController;

@end

@interface SPGUIController : NSObject
{
}

- (id)initWithDelegate:(id <SPGUIControllerDelegate>)delegate;
- (void)showWindow;
- (void)showTimerWindow;

@end
