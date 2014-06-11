#import <Foundation/Foundation.h>

@class NSManagedObjectContext;
@class RBRedditItem;

@interface RBPersistenceService : NSObject

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (void)saveRedditItem:(RBRedditItem *)item;
- (void)deleteRedditItem:(RBRedditItem *)item;
- (NSArray *)findAllItemsForFeed:(NSString *)feedName;
- (NSArray *)findAllItemsForFeed:(NSString *)feedName notUUID:(NSString *)uuid;

@end
