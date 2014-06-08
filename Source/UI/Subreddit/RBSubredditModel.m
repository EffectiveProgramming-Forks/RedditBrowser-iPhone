#import "RBSubredditModel.h"
#import "RBRedditFeedManager.h"

@interface RBSubredditModel ()

@property (nonatomic) RBRedditFeedManager *feedManager;

@end

@implementation RBSubredditModel

@synthesize delegateForModel;

- (id)initWithSubredditFeedManager:(RBRedditFeedManager *)feedManager {
    self = [super init];
    if (self) {
        _feedManager = feedManager;
    }
    return self;
}

- (void)fetchSubredditFeed:(NSString *)feedName {
    __weak RBSubredditModel *wself = self;
    [_feedManager fetchFeed:feedName completionBlock:^(NSArray *feedItems) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.delegateForModel receivedSubredditItems:feedItems forFeedName:feedName];
        });
    }];
}

@end
