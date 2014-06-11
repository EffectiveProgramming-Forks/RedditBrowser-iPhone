#import "RBPersistenceService.h"
#import <CoreData/CoreData.h>
#import "RBRedditBrowserEntities.h"
#import "RBRedditItem.h"

@interface RBPersistenceService ()

@property (nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation RBPersistenceService

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    self = [super init];
    if (self) {
        _managedObjectContext = managedObjectContext;
    }
    return self;
}

- (void)saveRedditItem:(RBRedditItem *)item {
    RedditItemEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"RedditItem" inManagedObjectContext:_managedObjectContext];
    entity.title = item.title;
    entity.author = item.author;
    entity.permalink = item.permalink;
    entity.uuid = item.uuid;
    entity.subreddit = item.subreddit;
    NSError *error = nil;
    BOOL success = [_managedObjectContext save:&error];
    if (!success) {
        // STORY: handle failure to save - bubble up to business layer
        NSLog(@"Failed to save item.");
    }
}

- (void)deleteRedditItem:(RBRedditItem *)item {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RedditItem"];
    NSString *format = @"title = %@ AND author = %@ AND permalink = %@ AND uuid = %@ AND subreddit = %@";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format,
                              item.title,
                              item.author,
                              item.permalink,
                              item.uuid,
                              item.subreddit];
    fetchRequest.predicate = predicate;
    NSError *error = nil;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if ([items count] == 1) {
            RedditItemEntity *entity = items[0];
            [_managedObjectContext deleteObject:entity];
            BOOL success = [_managedObjectContext save:&error];
            if (!success) {
                // STORY: handle this error - bubble up to management layer
            }
        }
    } else {
        // STORY: handle this error - bubble up to management layer
    }
}

- (NSArray *)findAllItemsForFeed:(NSString *)feedName {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RedditItem"];
    NSString *format = @"subreddit = %@";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format, feedName];
    fetchRequest.predicate = predicate;
    NSError *error = nil;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!items) {
        // STORY: handle this error - bubble up to management layer
        return nil;
    } else {
        return items;
    }
}

- (NSArray *)findAllItemsForFeed:(NSString *)feedName notUUID:(NSString *)uuid {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RedditItem"];
    NSString *format = @"subreddit = %@ && uuid <> %@";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format, feedName, uuid];
    fetchRequest.predicate = predicate;
    NSError *error = nil;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!items) {
        // STORY: handle this error - bubble up to management layer
        return nil;
    } else {
        return items;
    }
}

@end
