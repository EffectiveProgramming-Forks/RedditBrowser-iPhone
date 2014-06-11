#import "RBRedditFeedManager.h"
#import "RBPersistenceServiceFactory.h"
#import "RBPersistenceService.h"
#import "RBNetworkService.h"
#import "RBReddititem.h"

@interface RBRedditFeedManager ()

@property (nonatomic) RBNetworkService *networkService;
@property (nonatomic) RBPersistenceServiceFactory *persistenceServiceFactory;

@end

@implementation RBRedditFeedManager

static NSString *scheme = @"http://";
static NSString *kHardCodedHostName = @"www.reddit.com";
static NSTimeInterval kRefreshInterval = 60 * 30;
static NSString *kLastNetworkRefreshDate = @"LastNetworkRefreshDate";

- (id)initWithNetworkService:(RBNetworkService *)networkService
          persistenceServiceFactory:(RBPersistenceServiceFactory *)persistenceServiceFactory {
    self = [super init];
    if (self) {
        _networkService = networkService;
        _persistenceServiceFactory = persistenceServiceFactory;
    }
    return self;
}

- (void)fetchFeed:(NSString *)feedName completionBlock:(RBRedditFeedManagerCompletionBlock)completionBlock {
    NSDate *now = [NSDate date];
    BOOL shouldFetchFromNetwork = [self shouldFetchFromNetwork:now];
    if (shouldFetchFromNetwork) {
        NSString *feedNamePath = [NSString stringWithFormat:@"/r/%@.json", feedName];
        NSString *urlAsString = [NSString stringWithFormat:@"%@%@%@", scheme, kHardCodedHostName, feedNamePath];
        [_networkService GET:urlAsString completionBlock:^(NSDictionary *response, NSError *error) {
            RBPersistenceService *persistenceService = [_persistenceServiceFactory temporaryPersistenceService];
            if (response && !error) {
                // 1. Convert items
                NSArray *items = [RBRedditItem itemsForJSONFeed:response];

                // 2. Save to core data
                NSUUID *uuid = [NSUUID UUID];
                for (RBRedditItem *item in items) {
                    item.uuid = [uuid UUIDString];
                    [persistenceService saveRedditItem:item];
                }
                
                // 3. Delete old items - ignoring deletion error for now but would likely want to consider handling this.
                NSArray *oldItems = [persistenceService findAllItemsForFeed:feedName notUUID:[uuid UUIDString]];
                for (RBRedditItem *item in oldItems) {
                    [persistenceService deleteRedditItem:item];
                }
                
                // 4. Update timer
                [[NSUserDefaults standardUserDefaults] setValue:now forKey:kLastNetworkRefreshDate];
                
                // 5. Update model
                [_delegateForFeedManager latestFeedItems:items];
                
                // 6. Check for nil block!
                if (completionBlock) {
                    completionBlock(items);
                }
            } else {
                // 1. Bubble error up to UI?
                if (completionBlock) {
                    NSArray *items = [persistenceService findAllItemsForFeed:feedName];
                    completionBlock(items);
                }
            }
        }];
    } else {
        if (completionBlock) {
            RBPersistenceService *persistenceService = [_persistenceServiceFactory mainPersistenceService];
            NSArray *items = [persistenceService findAllItemsForFeed:feedName];
            completionBlock(items);
        }
    }
}

#pragma mark - Private

- (BOOL)shouldFetchFromNetwork:(NSDate *)now {
    BOOL fetchFromNetwork = YES;
    NSDate *lastNetworkRefreshDate = [[NSUserDefaults standardUserDefaults] valueForKey:kLastNetworkRefreshDate];
    if (lastNetworkRefreshDate) {
        NSDate *nextDate = [NSDate dateWithTimeInterval:kRefreshInterval sinceDate:lastNetworkRefreshDate];
        NSComparisonResult comparisonResult = [now compare:nextDate];
        if (comparisonResult == NSOrderedAscending) {
            fetchFromNetwork = NO;
        }
    }
    return fetchFromNetwork;
}

@end
