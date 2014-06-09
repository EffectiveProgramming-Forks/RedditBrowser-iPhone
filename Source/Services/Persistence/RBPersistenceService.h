#import <Foundation/Foundation.h>

@class RBRedditItem;

@interface RBPersistenceService : NSObject

+ (instancetype)persistenceService;

- (void)saveRedditItem:(RBRedditItem *)item;
- (NSArray *)findAllItemsForFeed:(NSString *)feedName;

@end
