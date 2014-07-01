#import <Cocoa/Cocoa.h>
#import "SPGUIController.h"
#import "SPArrayController.h"

@interface SPAppDelegate : NSObject <NSApplicationDelegate, SPGUIControllerDelegate, SPRecordDelegate>
{
}

@property SPGUIController *guiController;
@property NSObjectController *objectController;
@property SPArrayController *arrayController;

- (void)importTime;
- (void)start;
- (void)stop;
- (void)clear;
- (void)toggle;

- (void)save;
- (void)export;
- (NSString *)nameFromStudentID:(NSString *)studentID;
- (NSString *)completeStudentID:(NSString *)brokenIDExp;
- (void)add;
- (void)showTimer;

- (void)unfilter;
- (void)filterPassed;
- (void)filterOne;
- (void)filterTwo;
- (void)filterFour;
- (void)filterUnique;

@end
