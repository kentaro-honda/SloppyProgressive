#import "SPGUIController.h"
#import "SPQuestionTransformer.h"
#import "SPDateTransformer.h"
#import "SPPassedValueTransformer.h"
#import "SPPassedColorTransformer.h"
#import "SPView.h"

@interface SPGUIController ()
{
}
@property (weak) id <SPGUIControllerDelegate> delegate;

@property NSWindow *window;
@property SPView *timerView;

- (NSTableColumn *)newTableColumnWithIdentifier:(NSString *)identifier;
- (NSTextField *)newLabelWithValue:(NSString *)value withFrame:(NSRect)frame;

@end

@implementation SPGUIController

- (id)initWithDelegate:(id <SPGUIControllerDelegate>)delegate;
{
	NSScrollView *scrollView;
	NSTableView *tableView;
	NSTableColumn *questionColumn, *passedColumn, *dateColumn;
	NSPopUpButton *question;
	NSTextField *qLabel, *idLabel, *nameLabel, *timeLabel;
	NSTextField *studentID, *name, *time;
	NSButton *passed;
	NSButton *import, *add, *screen;
	NSUInteger i;
	self = [super init];

	if (self) {
		self.delegate = delegate;

		self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(350.0, 300.0, 643.0, 480.0) 
												  styleMask:NSTitledWindowMask|NSMiniaturizableWindowMask
													backing:NSBackingStoreBuffered 
													  defer:NO];

		scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0.0, 60.0, 643.0, 420.0)];
		scrollView.borderType = NSBezelBorder;
		tableView = [[NSTableView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 643.0, 420.0)];
		[tableView bind:@"content" toObject:self.delegate.arrayController withKeyPath:@"arrangedObjects" options:nil];
		[tableView bind:@"selectionIndexes" toObject:self.delegate.arrayController withKeyPath:@"selectionIndexes" options:nil];
		[tableView bind:@"sortDescriptors" toObject:self.delegate.arrayController withKeyPath:@"sortDescriptors" options:nil];
		[tableView addTableColumn:[self newTableColumnWithIdentifier:@"identifier"]];
		questionColumn = [[NSTableColumn alloc] initWithIdentifier:@"question"];
		[questionColumn.headerCell setStringValue:@"question"];
		questionColumn.editable = NO;
		[questionColumn bind:@"value" toObject:self.delegate.arrayController withKeyPath:@"arrangedObjects.question" options:@{NSValueTransformerBindingOption:[[SPQuestionTransformer alloc] init]}];
		[questionColumn sizeToFit];
		[tableView addTableColumn:questionColumn];
		[tableView addTableColumn:[self newTableColumnWithIdentifier:@"studentID"]];
		[tableView addTableColumn:[self newTableColumnWithIdentifier:@"name"]];
		[tableView addTableColumn:[self newTableColumnWithIdentifier:@"time"]];
		passedColumn = [[NSTableColumn alloc] initWithIdentifier:@"passed"];
		[passedColumn.headerCell setStringValue:@"passed"];
		passedColumn.editable = NO;
		[passedColumn bind:@"value" toObject:self.delegate.arrayController withKeyPath:@"arrangedObjects.passed" options:@{NSValueTransformerBindingOption:[[SPPassedValueTransformer alloc] init]}];
		[passedColumn bind:@"textColor" toObject:self.delegate.arrayController withKeyPath:@"arrangedObjects.passed" options:@{NSValueTransformerBindingOption:[[SPPassedColorTransformer alloc] init]}];
		[passedColumn sizeToFit];
		[tableView addTableColumn:passedColumn];
		dateColumn = [[NSTableColumn alloc] initWithIdentifier:@"date"];
		[dateColumn.headerCell setStringValue:@"date"];
		dateColumn.editable = NO;
		[dateColumn bind:@"value" toObject:self.delegate.arrayController withKeyPath:@"arrangedObjects.date" options:@{NSValueTransformerBindingOption:[[SPDateTransformer alloc] init]}];
		dateColumn.width = 80.0;
		[tableView addTableColumn:dateColumn];
		scrollView.documentView = tableView;
		[self.window.contentView addSubview:scrollView];

		add = [[NSButton alloc] initWithFrame:NSMakeRect(19.0, 20.0, 20.0, 20.0)];
		[add setTitle:@"+"];
		[add setBezelStyle:NSShadowlessSquareBezelStyle];
		[add setTarget:self.delegate.arrayController];
		[add setAction:@selector(add:)];
		add.keyEquivalent = @"n";
		add.keyEquivalentModifierMask = NSCommandKeyMask;
		[add bind:@"enabled" toObject:self.delegate.arrayController withKeyPath:@"canAdd" options:nil];
		[self.window.contentView addSubview:add];

		qLabel = [self newLabelWithValue:@"Q" withFrame:NSMakeRect(49.0, 22.0, 19.0, 17.0)];
		[self.window.contentView addSubview:qLabel];
		question = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(65.0, 17.0, 66.0, 26.0) pullsDown:NO];
		[question addItemWithTitle:@"none"];
		for (i = 0; i < 10; ++i) {
			[question addItemWithTitle:[NSString stringWithFormat:@"0%lu", i]];
		}
		for (i = 10; i < 100; ++i) {
			[question addItemWithTitle:[NSString stringWithFormat:@"%lu", i]];
		}
		[question bind:@"selectedIndex" toObject:self.delegate.arrayController withKeyPath:@"selection.question" options:nil];
		[self.window.contentView addSubview:question];

		idLabel = [self newLabelWithValue:@"ID" withFrame:NSMakeRect(134.0, 22.0, 18.0, 17.0)];
		[self.window.contentView addSubview:idLabel];
		studentID = [[NSTextField alloc] initWithFrame:NSMakeRect(158.0, 19.0, 74.0, 22.0)];
		[studentID bind:@"value" toObject:self.delegate.arrayController withKeyPath:@"selection.studentID" options:@{NSValidatesImmediatelyBindingOption:@YES}];
		[self.window.contentView addSubview:studentID];
		
		nameLabel = [self newLabelWithValue:@"Name" withFrame:NSMakeRect(240.0, 22.0, 41.0, 17.0)];
		[self.window.contentView addSubview:nameLabel];
		name = [[NSTextField alloc] initWithFrame:NSMakeRect(283.0, 19.0, 118.0, 22.0)];
		[name bind:@"value" toObject:self.delegate.arrayController withKeyPath:@"selection.name" options:nil];
		[self.window.contentView addSubview:name];

		timeLabel = [self newLabelWithValue:@"Time" withFrame:NSMakeRect(405.0, 22.0, 35.0, 17.0)];
		[self.window.contentView addSubview:timeLabel];
		time = [[NSTextField alloc] initWithFrame:NSMakeRect(445.0, 21.0, 54.0, 18.0)];
		time.editable = NO;
		time.drawsBackground = NO;
		time.bordered = NO;
		[time bind:@"value" toObject:self.delegate.arrayController withKeyPath:@"selection.time" options:nil];
		[self.window.contentView addSubview:time];

		passed = [[NSButton alloc] initWithFrame:NSMakeRect(503, 21.0, 65.0, 18.0)];
		[passed setTitle:@"passed"];
		[passed setButtonType:NSSwitchButton];
		[passed bind:@"value" toObject:self.delegate.arrayController withKeyPath:@"selection.passed" options:nil];
		[self.window.contentView addSubview:passed];

		import = [[NSButton alloc] initWithFrame:NSMakeRect(574.0, 20.0, 20.0, 20.0)];
		[import setTitle:@"i"];
		[import setBezelStyle:NSShadowlessSquareBezelStyle];
		[import setTarget:self.delegate];
		[import setAction:@selector(importTime)];
		import.keyEquivalent = @"i";
		import.keyEquivalentModifierMask = NSCommandKeyMask;
		[import bind:@"enabled" toObject:self.delegate.arrayController withKeyPath:@"canRemove" options:nil];
		[self.window.contentView addSubview:import];

		screen = [[NSButton alloc] initWithFrame:NSMakeRect(604.0, 20.0, 20.0, 20.0)];
		[screen setTitle:@">"];
		[screen setBezelStyle:NSShadowlessSquareBezelStyle];
		[screen setTarget:self];
		screen.keyEquivalent = @"2";
		screen.keyEquivalentModifierMask = NSCommandKeyMask;
		[screen setAction:@selector(showTimerWindow)];
		[self.window.contentView addSubview:screen];

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

	screen = ([[NSScreen screens] count] > 1) ? [NSScreen screens][1] : [NSScreen mainScreen];
	[self.timerView enterFullScreenMode:screen];
}

- (NSTableColumn *)newTableColumnWithIdentifier:(NSString *)identifier
{
	NSTableColumn *tableColumn;

	tableColumn = [[NSTableColumn alloc] initWithIdentifier:identifier];
	[tableColumn.headerCell setStringValue:identifier];
	tableColumn.editable = NO;
	tableColumn.width = 80.0;
	[tableColumn bind:@"value" toObject:self.delegate.arrayController withKeyPath:[NSString stringWithFormat:@"arrangedObjects.%@", identifier] options:nil];

	return tableColumn;
}

- (NSTextField *)newLabelWithValue:(NSString *)value withFrame:(NSRect)frame
{
	NSTextField *textField;
	
	textField = [[NSTextField alloc] initWithFrame:frame];
	textField.editable = NO;
	textField.selectable = NO;
	textField.drawsBackground = NO;
	textField.bordered = NO;
	[textField setStringValue:value];
	return textField;
}

@end
