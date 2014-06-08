#import "RBRedditFeedManager.h"
#import "RBPersistenceService.h"
#import "RBNetworkService.h"
#import "RBSubreddititem.h"

@interface RBRedditFeedManager ()

@property (nonatomic) RBNetworkService *networkService;
@property (nonatomic) RBPersistenceService *dataService;

@end

@implementation RBRedditFeedManager

static NSString *scheme = @"http://";
static NSString *kHardCodedHostName = @"www.reddit.com";

- (id)initWithNetworkService:(RBNetworkService *)networkService
          persistenceService:(RBPersistenceService *)dataService {
    self = [super init];
    if (self) {
        _networkService = networkService;
        _dataService = dataService;
    }
    return self;
}

- (void)fetchFeed:(NSString *)feedName completionBlock:(RBRedditFeedManagerCompletionBlock)completionBlock {
    // use cached version?
    // fetch from database

    // else
    // fetch from network
    NSString *urlAsString = [NSString stringWithFormat:@"%@%@%@", scheme, kHardCodedHostName, feedName];
    [_networkService GET:urlAsString completionBlock:^(NSDictionary *response, NSError *error) {
        if (response && !error) {
            NSArray *items = [RBSubredditItem itemsForJSONFeed:response];
            completionBlock(items);
            // save to data service
            // start cache timer
        } else {
            // Bubble this up to the UI? or/and return cached version is applicable
        }
    }];
}

@end
