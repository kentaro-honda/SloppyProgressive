#import "SPAppDelegate.h"
#import "SPStopWatch.h"
#import "SPRecord.h"

@interface SPAppDelegate ()
{
}
@property SPStopWatch *stopWatch;
@property NSDictionary *studentMap;

- (NSURL *)recordURL;
- (NSURL *)exportURL;
- (void)filterWithNumber:(NSUInteger)n;
- (NSArray *)sortedPassedStudentIDs;

@end

@implementation SPAppDelegate

- (id)init
{
	self = [super init];

	if (self){
		self.stopWatch = [[SPStopWatch alloc] init];
		self.stopWatch.minute_limit = 0;
		self.stopWatch.second_limit = 3;
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
 
	[self.stopWatch bind:@"description" toObject:self.arrayController withKeyPath:@"selection.time" options:nil];

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

- (NSString *)completeStudentID:(NSString *)brokenIDExp
{
	NSArray *ids, *candidates;
	NSPredicate *predicate;

	if (!brokenIDExp || !self.studentMap) {
		return nil;
	}

	ids = [self.studentMap allKeys];
	predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", brokenIDExp];
	candidates = [ids filteredArrayUsingPredicate:predicate];
	if ([candidates count] == 1) {
		return candidates[0];
	}
	
	return nil;
}

- (NSString *)nameFromStudentID:(NSString *)studentID
{
	if (!studentID || !self.studentMap) {
		return nil;
	}

	return self.studentMap[studentID];
}

- (void)start
{
	if (![[self.arrayController valueForKeyPath:@"selection.editable"] boolValue]) {
		return;
	}
	
	[self.stopWatch start];
}

- (void)stop
{
	if (![[self.arrayController valueForKeyPath:@"selection.editable"] boolValue]) {
		return;
	}
	
	[self.stopWatch stop];
}

- (void)clear
{
	if (![[self.arrayController valueForKeyPath:@"selection.editable"] boolValue]) {
		return;
	}
	
	[self.stopWatch clear];
}

- (void)toggle
{
	if (![[self.arrayController valueForKeyPath:@"selection.editable"] boolValue]) {
		return;
	}
	
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

- (void)export
{
	NSUInteger indices[6] = {0, 1, 2, 4, 5, 3};
	NSUInteger i;
	NSURL *exportURL;
	NSArray *filtered, *sorted;
	NSPredicate *predicate;
	NSMutableString *string;
	NSMutableString *maskedID, *studentID;

	exportURL = [self exportURL];
	if (!exportURL) {
		return;
	}

	predicate = [NSPredicate predicateWithFormat:@"passed == YES"];
	filtered = [self.arrayController.content filteredArrayUsingPredicate:predicate];
	sorted = [filtered sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"question" ascending:YES],
													 [NSSortDescriptor sortDescriptorWithKey:@"studentID" ascending:YES]]];

	string = [NSMutableString string];
	for (SPRecord *record in sorted) {
		maskedID = [NSMutableString stringWithString:record.studentID];
		for (i = 0; i < 6; ++i) {
			studentID = [NSMutableString stringWithString:maskedID];
			[studentID replaceCharactersInRange:NSMakeRange(indices[i], 1) withString:@"*"];
			if (![self completeStudentID:[studentID stringByReplacingOccurrencesOfString:@"*" withString:@"[0-9]"]]){
				break;
			}
			maskedID = studentID;
		}
		if (record.question > 10) {
			[string appendFormat:@"\t\t<li>問題%lu 　%@</li>\n", record.question-1, maskedID];
		}
		else {
			[string appendFormat:@"\t\t<li>問題%lu　　%@</li>\n", record.question-1, maskedID];
		}
	}

	[string writeToURL:exportURL atomically:YES encoding:NSUnicodeStringEncoding error:NULL];
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

- (void)filterUnique
{
	NSArray *records;
	NSArray *sorteds;
	NSMutableSet *tempIDs;
	NSPredicate *predicate;
	NSUInteger i, j;

	records = self.arrayController.arrangedObjects;
	sorteds = [records sortedArrayUsingComparator:^(id obj1, id obj2){
			return [((SPRecord *)obj1).studentID compare:((SPRecord *)obj2).studentID];
		}];
	tempIDs = [NSMutableSet set];
	for (i = 0; i < [sorteds count]; ++i){
		[tempIDs addObject:[NSNumber numberWithUnsignedInteger:((SPRecord *)sorteds[i]).identifier]];
		for (j = i+1; j < [sorteds count]; ++j) {
			if (![((SPRecord *)sorteds[i]).studentID isEqualToString:((SPRecord *)sorteds[j]).studentID]) {
				break;
			}
		}
		i = j-1;
	}

	predicate = [NSPredicate predicateWithFormat:@"identifier in %@", tempIDs];
	if (self.arrayController.filterPredicate){
		self.arrayController.filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate,self.arrayController.filterPredicate]];
	}
	else{
		self.arrayController.filterPredicate = predicate;
	}
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

- (NSURL *)exportURL
{
	NSFileManager* fm;
	NSURL *fileURL;
	NSArray* desktopURLs;
	NSString *bundleID;

    fm = [NSFileManager defaultManager];
	bundleID = [[NSBundle mainBundle] bundleIdentifier];
    desktopURLs = [fm URLsForDirectory:NSDesktopDirectory inDomains:NSUserDomainMask];
    if (![desktopURLs count]) {
		return nil;
	}

	fileURL = [desktopURLs[0] URLByAppendingPathComponent:bundleID];
    return [fileURL URLByAppendingPathExtension:@"txt"];
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
