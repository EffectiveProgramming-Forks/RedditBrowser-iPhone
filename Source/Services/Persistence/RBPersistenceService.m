#import "RBPersistenceService.h"

@implementation RBPersistenceService

+ (instancetype)persistenceService {
    return [[RBPersistenceService alloc] init];
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
