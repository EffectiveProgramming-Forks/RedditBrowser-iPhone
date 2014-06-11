#import "RBSubredditManager.h"
#import "RBPersistenceServiceFactory.h"
#import "RBPersistenceService.h"
#import "RBNetworkService.h"
#import "RBReddititem.h"

@interface RBSubredditManager ()

@property (nonatomic) RBNetworkService *networkService;
@property (nonatomic) RBPersistenceServiceFactory *persistenceServiceFactory;

@end

@implementation RBSubredditManager

static NSString *scheme = @"http://";
static NSString *kHardCodedHostName = @"www.reddit.com";
static NSTimeInterval kRefreshInterval = 60 * 30;
static NSString *kLastNetworkRefreshDate = @"RBLastNetworkRefreshDate";
static NSString *kSubredditPathTemplate = @"/r/%@.json";

- (id)initWithNetworkService:(RBNetworkService *)networkService
          persistenceServiceFactory:(RBPersistenceServiceFactory *)persistenceServiceFactory {
    self = [super init];
    if (self) {
        _networkService = networkService;
        _persistenceServiceFactory = persistenceServiceFactory;
    }
    return self;
}

- (void)fetchSubreddit:(NSString *)subreddit
            force:(BOOL)force
  completionBlock:(RBSubredditManagerCompletionBlock)completionBlock {
    NSDate *now = [NSDate date];
    BOOL shouldFetchFromNetwork = (force || [self shouldFetchFromNetwork:now]);
    if (shouldFetchFromNetwork) {
        NSString *subredditPath = [NSString stringWithFormat:kSubredditPathTemplate, subreddit];
        NSString *urlAsString = [NSString stringWithFormat:@"%@%@%@", scheme, kHardCodedHostName, subredditPath];
        [_networkService GET:urlAsString completionBlock:^(NSDictionary *response, NSError *error) {
            RBPersistenceService *persistenceService = [_persistenceServiceFactory temporaryPersistenceService];
            if (response && !error) {
                // 1. Convert items
                NSArray *items = [RBRedditItem itemsForJSONFeed:response];

                // 2. Save to core data
                NSString *uuid = [[NSUUID UUID] UUIDString];
                for (RBRedditItem *item in items) {
                    item.uuid = uuid;
                    [persistenceService saveRedditItem:item];
                }
                
                // 3. Delete old items -
                NSArray *oldItems = [persistenceService findAllItemsForSubreddit:subreddit notUUID:uuid];
                for (RBRedditItem *item in oldItems) {
                    [persistenceService deleteRedditItem:item];
                }

                // STORY: handle save and/or deletion errors
                
                // 4. Update timer
                [[NSUserDefaults standardUserDefaults] setValue:now forKey:kLastNetworkRefreshDate];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // 5. Update model
                [_delegateForFeedManager latestFeedItems:items];
                
                // 6. Check for nil block!
                if (completionBlock) {
                    completionBlock(items);
                }
            } else {
                // STORY: bubble network error up to UI
                if (completionBlock) {
                    NSArray *items = [persistenceService findAllItemsForSubreddit:subreddit];
                    completionBlock(items);
                }
            }
        }];
    } else {
        if (completionBlock) {
            RBPersistenceService *persistenceService = [_persistenceServiceFactory mainPersistenceService];
            NSArray *items = [persistenceService findAllItemsForSubreddit:subreddit];
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
