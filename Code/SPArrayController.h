#import <Cocoa/Cocoa.h>
#import "SPRecord.h"

@interface SPArrayController : NSArrayController

@property (weak) id <SPRecordDelegate> delegate;

@end
