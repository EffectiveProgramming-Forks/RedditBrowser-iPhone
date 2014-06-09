#import "RBPersistenceService.h"

@implementation RBPersistenceService

+ (instancetype)persistenceService {
    return [[RBPersistenceService alloc] init];
}

- (void)saveRedditItem:(RBRedditItem *)item {
    
}

- (NSArray *)findAllItemsForFeed:(NSString *)feedName {
    return @[];
}

@end
