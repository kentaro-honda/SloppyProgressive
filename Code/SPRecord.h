#import <Cocoa/Cocoa.h>

#define SPRECORD_ERROR_DOMAIN @"SPRecordError"
#define SPRECORD_INVALID_ID_CHARACTER_CODE 1
#define SPRECORD_INVALID_ID_LENGTH_CODE 2

@protocol SPRecordDelegate <NSObject>

@optional
- (NSString *)nameFromStudentID:(NSString *)studentID;
- (NSString *)completeStudentID:(NSString *)brokenID;

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
@property (readonly) BOOL editable;

+ (NSArray *)arrayWithContentsOfURL:(NSURL *)URL;
- (NSDictionary *)dictionary;

@end
