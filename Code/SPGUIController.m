#import "SPGUIController.h"
#import "SPView.h"

@interface SPGUIController ()
{
}
@property (weak) id <SPGUIControllerDelegate> delegate;

@property NSWindow *window;
@property SPView *timerView;

@end

@implementation SPGUIController

- (id)initWithDelegate:(id <SPGUIControllerDelegate>)delegate;
{
	self = [super init];

	if (self) {
		self.delegate = delegate;
		self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(350.0, 300.0, 480.0, 480.0) 
												  styleMask:NSTitledWindowMask|NSMiniaturizableWindowMask 
													backing:NSBackingStoreBuffered 
													  defer:NO];

		self.timerView = [[SPView alloc] initWithDelegate:self.delegate];
	}

	return self;
}

- (void)showWindow
{
	[self.window makeKeyAndOrderFront:self];
}

- (void)showTimerWindow
{
	NSScreen *screen;

	if ([self.timerView isInFullScreenMode]) {
		[self.timerView exitFullScreenModeWithOptions:nil];
	}
	else{
		screen = ([[NSScreen screens] count] > 1) ? [NSScreen screens][1] : [NSScreen mainScreen];
		[self.timerView enterFullScreenMode:screen];
	}
}

@end
