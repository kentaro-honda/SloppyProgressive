#import <Cocoa/Cocoa.h>
#import "SPAppDelegate.h"

NSMenu *newMainMenu(void);

int main(int argc, char *argv[])
{
	SPAppDelegate *c;

	@autoreleasepool{
		[NSApplication sharedApplication];
		c = [[SPAppDelegate alloc] init];
		[NSApp setDelegate:c];
		[NSApp setMainMenu:newMainMenu()];
		[NSApp run];
	}
	return 0;
}

NSMenu *newMainMenu(void)
{
	NSMenu *menu;
	NSMenu *applicationMenu;
	NSMenu *fileMenu;
	NSMenu *windowMenu;
	NSMenuItem *applicationMenuItem;
	NSMenuItem *fileMenuItem;
	NSMenuItem *windowMenuItem;
	NSString *name;
	
	name = [[NSProcessInfo processInfo] processName];
	menu = [[NSMenu alloc] init];

	applicationMenuItem = [[NSMenuItem alloc] init];
	applicationMenu = [[NSMenu alloc] init];
	[applicationMenu addItemWithTitle:[@"About " stringByAppendingString:name]
							   action:@selector(orderFrontStandardAboutPanel:)
						keyEquivalent:@""];
	[applicationMenu addItem:[NSMenuItem separatorItem]];
	[applicationMenu addItemWithTitle:[@"Hide " stringByAppendingString:name]
							   action:@selector(hide:)
						keyEquivalent:@"h"];
	[applicationMenu addItemWithTitle:@"Hide Others"
							   action:@selector(hideOtherApplications:)
						keyEquivalent:@"h"];
	[[applicationMenu itemWithTitle:@"Hide Others"] setKeyEquivalentModifierMask:NSAlternateKeyMask|NSCommandKeyMask];
	[applicationMenu addItemWithTitle:@"Show All"
							   action:@selector(unhideAllApplications:)
						keyEquivalent:@""];
	[applicationMenu addItem:[NSMenuItem separatorItem]];
	[applicationMenu addItemWithTitle:[@"Quit " stringByAppendingString:name]
					   action:@selector(terminate:)
				keyEquivalent:@"q"];
	[applicationMenuItem setSubmenu:applicationMenu];
	applicationMenu = nil;
	[menu addItem:applicationMenuItem];
	applicationMenuItem = nil;

	fileMenuItem = [[NSMenuItem alloc] init];
	fileMenu = [[NSMenu alloc] initWithTitle:@"File"];
	[fileMenu addItemWithTitle:@"Close Window"
						action:@selector(performClose:)
				 keyEquivalent:@"w"];
	[fileMenuItem setSubmenu:fileMenu];
	fileMenu = nil;
	[menu addItem:fileMenuItem];
	fileMenuItem = nil;
	
	windowMenuItem = [[NSMenuItem alloc] init];
	windowMenu = [[NSMenu alloc] initWithTitle:@"Window"];
	[windowMenu addItemWithTitle:@"Minimize"
						  action:@selector(performMiniaturize:)
				   keyEquivalent:@"m"];
	[windowMenu addItem:[NSMenuItem separatorItem]];
	[windowMenu addItemWithTitle:@"Bring All to Front"
						  action:@selector(arrangeInFront:)
				   keyEquivalent:@""];
	[windowMenuItem setSubmenu:windowMenu];
	windowMenu = nil;
	[menu addItem:windowMenuItem];
	windowMenuItem = nil;

	return menu;
}
