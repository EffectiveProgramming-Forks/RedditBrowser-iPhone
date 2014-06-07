#import "RBRedditFeedManager.h"
#import "RBNetworkService.h"
#import "RBURLValidator.h"

@interface RBRedditFeedManager ()

@property (nonatomic) RBNetworkService *networkService;

@end

@implementation RBRedditFeedManager

//
// This isn't necessarily required - but was agreed upon early in the project
// as not to demonstrate how to inject this information.
//
static NSString *kHardCodedHostName = @"www.reddit.com";

- (id)initWithNetworkService:(RBNetworkService *)networkService {
    self = [super init];
    if (self) {
        _networkService = networkService;
    }
    return self;
}

- (void)fetchFeed:(NSString *)feedName completionBlock:(RBJSONCompletionBlock)completionBlock {
    NSString *urlAsString = [NSString stringWithFormat:@"http://%@%@", kHardCodedHostName, feedName];
    [_networkService GET:urlAsString completionBlock:completionBlock];
}

@end
