#import <Foundation/Foundation.h>

@class RBRedditItem;

@interface RBPersistenceService : NSObject

+ (instancetype)persistenceService;

- (void)saveRedditItem:(RBRedditItem *)item;
- (void)deleteRedditItem:(RBRedditItem *)item;
- (NSArray *)findAllItemsForFeed:(NSString *)feedName;
- (NSArray *)findAllItemsForFeed:(NSString *)feedName notUUID:(NSString *)uuid;

@end
