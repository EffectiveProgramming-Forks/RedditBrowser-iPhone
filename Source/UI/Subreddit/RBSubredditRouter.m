#import "RBSubredditRouter.h"
#import "RBSubredditModel.h"
#import "RBSubredditView.h"
#import "RBRedditItem.h"

@interface RBSubredditRouter () <RBSubredditModelDelegate,RBSubredditViewDelegate>

@property (nonatomic, weak) RBSubredditModel *subRedditModel;
@property (nonatomic, weak) id<RBSubredditView> subRedditView;

@end

@implementation RBSubredditRouter

// STORY: eventually comes from user selection!
static NSString *kDefaltSubredditName = @"listentothis";

// STORY: get rid of this!
static NSString *kHostname = @"http://www.reddit.com/";

- (id)initWithModel:(RBSubredditModel *)subRedditModel view:(id<RBSubredditView>)subRedditView {
    self = [super init];
    if (self) {
        subRedditModel.delegateForModel = self;
        subRedditView.delegateForView = self;
        
        _subRedditView = subRedditView;
        _subRedditModel = subRedditModel;
        
        [subRedditModel fetchSubreddit:kDefaltSubredditName force:NO];
    }
    return self;
}

#pragma mark - RBSubredditModelDelegate

- (void)receivedItems:(NSArray *)items forSubreddit:(NSString *)feedName {
    [_subRedditView setItems:items forSubreddit:feedName];
}

#pragma mark - RBSubredditViewDelegate

- (void)itemWasSelected:(RBRedditItem *)item {
    NSString *permalink = item.permalink;
    NSString *urlAsString = [NSString stringWithFormat:@"%@%@", kHostname, permalink];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlAsString]];
}

- (void)refreshButtonWasTapped {
    [_subRedditModel fetchSubreddit:kDefaltSubredditName force:YES];
}

@end
