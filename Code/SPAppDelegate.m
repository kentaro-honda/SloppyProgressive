#import "SPAppDelegate.h"
#import "SPStopWatch.h"
#import "SPRecord.h"

@interface SPAppDelegate ()
{
}
@property SPStopWatch *stopWatch;
@property NSDictionary *studentMap;

- (NSURL *)recordURL;
- (void)filterWithNumber:(NSUInteger)n;
- (NSArray *)sortedPassedStudentIDs;

@end

@implementation SPAppDelegate

- (id)init
{
	self = [super init];

	if (self){
		self.stopWatch = [[SPStopWatch alloc] init];
		self.stopWatch.minute_limit = 15;
		self.stopWatch.second_limit = 0;
		self.stopWatch.milli_limit = 0;
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

	array = self.arrayController.content;
	saveArray = [NSMutableArray array];
	for (SPRecord *record in array) {
		[saveArray addObject:[record dictionary]];
	}

	[saveArray writeToURL:recordURL atomically:YES];
}

- (void)unfilter
{
	self.arrayController.filterPredicate = nil;
}

- (void)filterPassed
{
	NSPredicate *predicate;

	predicate = [NSPredicate predicateWithFormat:@"passed == YES"];
	self.arrayController.filterPredicate = predicate;
}

- (void)filterOne
{
	NSArray *sortedIDs;
	NSMutableSet *tempIDs;
	NSPredicate *predicate;
	NSUInteger i, j;

	sortedIDs = [self sortedPassedStudentIDs];
	tempIDs = [NSMutableSet set];
	for (i = 0; i < [sortedIDs count]-1; ++i){
		if ([sortedIDs[i] isEqualToString:sortedIDs[i+1]]) {
			for (j = i+2; j < [sortedIDs count]; ++j) {
				if (![sortedIDs[i] isEqualToString:sortedIDs[j]]) {
					break;
				}
			}
			i = j-1;
		}
		else {
			[tempIDs addObject:sortedIDs[i]];
		}
	}

	predicate = [NSPredicate predicateWithFormat:@"passed == YES && studentID in %@", tempIDs];
	self.arrayController.filterPredicate = predicate;
}

- (void)filterTwo
{
	[self filterWithNumber:2];
}

- (void)filterFour
{
	[self filterWithNumber:4];
}


- (void)filterWithNumber:(NSUInteger)n
{
	NSArray *sortedIDs;
	NSMutableSet *tempIDs;
	NSPredicate *predicate;
	NSUInteger i, j;

	sortedIDs = [self sortedPassedStudentIDs];
	tempIDs = [NSMutableSet set];
	for (i = 0; i < [sortedIDs count]-(n-1); ++i){
		if ([sortedIDs[i] isEqualToString:sortedIDs[i+(n-1)]]) {
			[tempIDs addObject:sortedIDs[i]];
			for (j = i+n; j < [sortedIDs count]; ++j) {
				if (![sortedIDs[i] isEqualToString:sortedIDs[j]]) {
					break;
				}
			}
			i = j-1;
		}
	}

	predicate = [NSPredicate predicateWithFormat:@"passed == YES && studentID in %@", tempIDs];
	self.arrayController.filterPredicate = predicate;
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

- (NSArray *)sortedPassedStudentIDs
{
	NSArray *filtered;
	NSArray *studentIDs;
	NSPredicate *predicate;

	predicate = [NSPredicate predicateWithFormat:@"passed == YES"];
	filtered = [self.arrayController.content filteredArrayUsingPredicate:predicate];
	studentIDs = [filtered valueForKey:@"studentID"];
	return [studentIDs sortedArrayUsingComparator:^(id obj1, id obj2){
			return [(NSString *)obj1 compare:(NSString *)obj2];
		}];
}

@end
