#import "SPArrayController.h"

@implementation SPArrayController

- (id)newObject
{
	SPRecord *record;

	record = [super newObject];
	record.delegate = self.delegate;

	return record;
}

@end
