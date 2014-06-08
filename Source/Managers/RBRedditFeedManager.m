#import "RBRedditFeedManager.h"
#import "RBPersistenceService.h"
#import "RBNetworkService.h"

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
    // fetch from network
    NSString *urlAsString = [NSString stringWithFormat:@"%@%@%@", scheme, kHardCodedHostName, feedName];
    [_networkService GET:urlAsString completionBlock:^(NSDictionary *response, NSError *error) {
        if (response && !error) {
            // NSArray *jsonItems = response[@"items"];
            NSArray *items = [NSArray array];
            completionBlock(items);
            // save to data service
        } else {
            // Bubble this up to the UI? or/and return cached version is applicable
        }
    }];
}

@end
