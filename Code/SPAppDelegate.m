#import "SPAppDelegate.h"
#import "SPStopWatch.h"

@interface SPAppDelegate ()
{
}
@property (strong) SPStopWatch *stopWatch;
@end

@implementation SPAppDelegate

- (id)init
{
	self = [super init];

	if (self){
		self.stopWatch = [[SPStopWatch alloc] init];
		self.objectController = [[NSObjectController alloc] initWithContent:self.stopWatch];
		self.guicontroller = [[SPGUIController alloc] initWithDelegate:self];
	}

	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self.guicontroller showWindow];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	self.guicontroller = nil;
}

- (void)buttonClicked:(id)sender
{
	[self.guicontroller showTimerWindow];
	[self.stopWatch start];
}

@end
