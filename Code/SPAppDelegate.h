#import <Cocoa/Cocoa.h>
#import "SPGUIController.h"

@interface SPAppDelegate : NSObject <NSApplicationDelegate, SPGUIControllerDelegate>
{
}

@property SPGUIController *guicontroller;
@property NSObjectController *objectController;

- (void)buttonClicked:(id)sender;

@end
