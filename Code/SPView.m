#import "SPView.h"

#define OFFSET 30

@interface SPView ()
{
}
@property (weak) id <SPViewDelegate> delegate;

@property NSTextField *time;

- (NSTextField *)textField;
@end

@implementation SPView

- (id)initWithDelegate:(id <SPViewDelegate>)delegate
{
	self = [super initWithFrame:NSMakeRect(0, 0, 0, 0)];
	
	if (self) {
		self.delegate = delegate;

		self.time = [self textField];
		[self.time bind:@"value" toObject:self.delegate.objectController withKeyPath:@"selection.description" options:nil];
		[self addSubview:self.time];
	}

	return self;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)enterFullScreenMode:(NSScreen *)screen
{
	NSRect frame;
	NSDictionary *options;
	NSUInteger i;
	CGSize size;

	options = [NSDictionary dictionaryWithObjectsAndKeys:
								@NO, NSFullScreenModeAllScreens,
							// NSFullScreenModeSetting,
					 [NSNumber numberWithUnsignedInteger:NSScreenSaverWindowLevel],
							NSFullScreenModeWindowLevel,
					 [NSNumber numberWithUnsignedInteger:NSApplicationPresentationDefault],
							NSFullScreenModeApplicationPresentationOptions,
							nil];
	[super enterFullScreenMode:screen withOptions:options];

	frame = self.frame;

	for (i = 100; ; ++i) {
		size = [@"00:00.0" sizeWithAttributes:@{NSFontAttributeName:[NSFont systemFontOfSize:i]}];
		if (size.width >= frame.size.width-OFFSET || size.height >= frame.size.height-OFFSET) {
			break;
		}
	}
	self.time.font = [NSFont systemFontOfSize:i-1];
	size = [@"00:00.0" sizeWithAttributes:@{NSFontAttributeName:[NSFont systemFontOfSize:i-1]}];
	self.time.frame = NSMakeRect(0, (frame.size.height-size.height-OFFSET)/2, frame.size.width, size.height+OFFSET);
}

- (void)cancelOperation:(id)sender
{
	if (![[self.delegate.objectController valueForKeyPath:@"selection.isWorking"] boolValue]) {
		[self exitFullScreenModeWithOptions:nil];
	}
}

- (void)keyDown:(NSEvent *)theEvent
{
	NSString *character;
	character = [theEvent characters];

	if ([character isEqualToString:@"s"]) {
		[self.delegate start];
	}
	else if ([character isEqualToString:@"e"]) {
		[self.delegate stop];
	}
	else if ([character isEqualToString:@"c"]) {
		[self.delegate clear];
	}
	else if ([character isEqualToString:@" "]) {
		[self.delegate toggle];
	}
	else {
		[self interpretKeyEvents:@[theEvent]];
	}
}

- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor blackColor] setFill];
	NSRectFill(dirtyRect);
	[super drawRect:dirtyRect];
}

- (NSTextField *)textField
{
	NSTextField *textField;
	
	textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
	textField.editable = NO;
	textField.selectable = NO;
	textField.font = [NSFont systemFontOfSize:300];
	textField.drawsBackground = NO;
	textField.bordered = NO;
	textField.textColor = [NSColor whiteColor];
	textField.alignment = NSCenterTextAlignment;
	return textField;
}
@end
