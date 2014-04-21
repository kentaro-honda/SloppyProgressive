#import <Cocoa/Cocoa.h>

#define SPRECORD_ERROR_DOMAIN @"SPRecordError"
#define SPRECORD_INVALID_ID_CHARACTER_CODE 1
#define SPRECORD_INVALID_ID_LENGTH_CODE 2

@protocol SPRecordDelegate

- (NSString *)nameFromStudentID:(NSString *)studentID;

@end

@interface SPRecord : NSObject

@property (weak) id <SPRecordDelegate> delegate;

@property NSUInteger identifier;
@property NSUInteger question;
@property NSString *studentID;
@property NSString *name;
@property NSString *time;
@property BOOL passed;
@property NSDate *date;

+ (NSArray *)arrayWithContentsOfURL:(NSURL *)URL;
- (NSDictionary *)dictionary;

@end
