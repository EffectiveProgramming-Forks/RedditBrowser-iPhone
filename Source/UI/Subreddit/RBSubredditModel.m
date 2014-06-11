#import "RBSubredditModel.h"
#import "RBSubredditManager.h"

@interface RBSubredditModel ()

@property (nonatomic) RBSubredditManager *feedManager;

@end

@implementation RBSubredditModel

@synthesize delegateForModel;

- (id)initWithSubredditManager:(RBSubredditManager *)feedManager {
    self = [super init];
    if (self) {
        _feedManager = feedManager;
    }
    return self;
}

- (void)fetchSubreddit:(NSString *)subredditName force:(BOOL)force {
    __weak RBSubredditModel *wself = self;
    [_feedManager fetchSubreddit:subredditName force:force completionBlock:^(NSArray *subredditItems) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.delegateForModel receivedItems:subredditItems forSubreddit:subredditName];
        });
    }];
}

@end
