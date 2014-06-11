#import <Foundation/Foundation.h>

@class NSManagedObjectContext;
@class RBRedditItem;

@interface RBPersistenceService : NSObject

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (void)saveRedditItem:(RBRedditItem *)item;
- (void)deleteRedditItem:(RBRedditItem *)item;
- (void)save;

- (NSArray *)findAllItemsForSubreddit:(NSString *)feedName;
- (NSArray *)findAllItemsForSubreddit:(NSString *)feedName notUUID:(NSString *)uuid;

@end
