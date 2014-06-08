#import "RBSubredditRouter.h"
#import "RBSubredditModel.h"
#import "RBSubredditView.h"
#import "RBRedditItem.h"

@interface RBSubredditRouter () <RBSubredditModelDelegate,RBSubredditViewDelegate>

@property (nonatomic, weak) RBSubredditModel *subRedditModel;
@property (nonatomic, weak) id<RBSubredditView> subRedditView;

@end

@implementation RBSubredditRouter

// Eventually comes from user selection!
static NSString *kDefaltFeedName = @"ListenToThis";

// Get rid of this!
static NSString *kHostname = @"http://www.reddit.com/";

- (id)initWithModel:(RBSubredditModel *)subRedditModel view:(id<RBSubredditView>)subRedditView {
    self = [super init];
    if (self) {
        subRedditModel.delegateForModel = self;
        subRedditView.delegateForView = self;
        
        _subRedditView = subRedditView;
        _subRedditModel = subRedditModel;
        
        [subRedditModel fetchSubredditFeed:kDefaltFeedName];
    }
    return self;
}

#pragma mark - RBSubredditModelDelegate

- (void)receivedSubredditItems:(NSArray *)items forFeedName:(NSString *)feedName {
    [_subRedditView setItems:items forFeedName:feedName];
}

#pragma mark - RBSubredditViewDelegate

- (void)itemWasSelected:(RBRedditItem *)item {
    NSString *permalink = item.permalink;
    NSString *urlAsString = [NSString stringWithFormat:@"%@%@", kHostname, permalink];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlAsString]];
}

@end
