#import "RBPersistenceService.h"
#import <CoreData/CoreData.h>

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
    
}

- (void)deleteRedditItem:(RBRedditItem *)item {
    
}

- (NSArray *)findAllItemsForFeed:(NSString *)feedName {
    return @[];
}

- (NSArray *)findAllItemsForFeed:(NSString *)feedName notUUID:(NSString *)uuid {
    return @[];
}

@end
