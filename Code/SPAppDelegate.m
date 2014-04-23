#import "SPAppDelegate.h"
#import "SPStopWatch.h"
#import "SPRecord.h"

@interface SPAppDelegate ()
{
}
@property SPStopWatch *stopWatch;
@property NSDictionary *studentMap;

- (NSURL *)recordURL;

@end

@implementation SPAppDelegate

- (id)init
{
	self = [super init];

	if (self){
		self.stopWatch = [[SPStopWatch alloc] init];
		self.objectController = [[NSObjectController alloc] initWithContent:self.stopWatch];
		self.arrayController = [[SPArrayController alloc] initWithContent:nil];
		self.arrayController.objectClass = [SPRecord class];
		self.arrayController.automaticallyRearrangesObjects = YES;
		self.arrayController.delegate = self;
		self.guiController = nil;
		self.studentMap = nil;
	}

	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSArray *initArray;
	NSBundle *bundle;
	NSString *idPath;
	NSURL *recordURL;

	bundle = [NSBundle mainBundle];
	idPath = [bundle pathForResource:@"studentid" ofType:@"plist"];
	if (idPath) {
		self.studentMap = [NSDictionary dictionaryWithContentsOfFile:idPath];
	}

	recordURL = [self recordURL];
	if (recordURL) {
		initArray = [SPRecord arrayWithContentsOfURL:recordURL];
		for (SPRecord *record in initArray) {
			record.delegate = self;
		}
		[self.arrayController addObjects:initArray];
	}
	self.arrayController.selectionIndexes = nil;
 
	self.guiController = [[SPGUIController alloc] initWithDelegate:self];
	[self.guiController showWindow];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[self save];

	self.guiController = nil;
	self.objectController = nil;
	self.arrayController = nil;
	self.studentMap = nil;
	self.stopWatch = nil;
}

- (void)add
{
	[self.arrayController add:self];
}

- (void)showTimer
{
	[self.guiController showTimerWindow];
}

- (NSString *)completeStudentID:(NSString *)brokenID
{
	NSArray *ids;
	NSString *candidate;
	NSUInteger brokenLength, idLength;

	if (!brokenID || !self.studentMap) {
		return nil;
	}

	brokenLength = [brokenID length];
	candidate = nil;
	ids = [self.studentMap allKeys];

	for (NSString *identifier in ids) {
		idLength = [identifier length];
		if (idLength < brokenLength) {
			continue;
		}
		
		if ([[identifier substringFromIndex:idLength - brokenLength] isEqualToString:brokenID]) {
			if (candidate) {
				return nil;
			}
			candidate = identifier;
		}
	}

	return candidate;
}

- (NSString *)nameFromStudentID:(NSString *)studentID
{
	if (!studentID || !self.studentMap) {
		return nil;
	}

	return self.studentMap[studentID];
}

- (void)importTime
{
	NSArray *selectedObjects;

	selectedObjects = self.arrayController.selectedObjects;
	if (!selectedObjects || ![selectedObjects count]) {
		return;
	}

	if (!self.stopWatch) {
		return;
	}

	[self.arrayController setValue:self.stopWatch.description forKeyPath:@"selection.time"];
}

- (void)start
{
	[self.stopWatch start];
}

- (void)stop
{
	[self.stopWatch stop];
}

- (void)clear
{
	[self.stopWatch clear];
}

- (void)toggle
{
	if (self.stopWatch.isWorking) {
		[self.stopWatch stop];
	}
	else {
		[self.stopWatch start];
	}
}

- (void)save
{
	NSURL *recordURL;
	NSMutableArray *saveArray;
	NSArray *array;

	recordURL = [self recordURL];
	if (!recordURL) {
		return;
	}

	array = self.arrayController.arrangedObjects;
	saveArray = [NSMutableArray array];
	for (SPRecord *record in array) {
		[saveArray addObject:[record dictionary]];
	}

	[saveArray writeToURL:recordURL atomically:YES];
}

- (NSURL *)recordURL
{
	NSFileManager* fm;
	NSURL *dirURL;
	NSArray* appSuppURLs;
	NSError* error;
	NSString *bundleID;

    fm = [NSFileManager defaultManager];
	bundleID = [[NSBundle mainBundle] bundleIdentifier];
    appSuppURLs = [fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    if (![appSuppURLs count]) {
		return nil;
	}

	dirURL = [appSuppURLs[0] URLByAppendingPathComponent:bundleID];
	error = nil;
	if (![fm createDirectoryAtURL:dirURL withIntermediateDirectories:YES attributes:nil error:&error]) {
		return nil;
	}

    return [dirURL URLByAppendingPathComponent:@"data.plist"];
}

@end
