#import "RBSubredditRouter.h"
#import "RBSubredditModel.h"
#import "RBSubredditView.h"

@interface RBSubredditRouter () <RBSubredditModelDelegate,RBSubredditViewDelegate>

@property (nonatomic, weak) RBSubredditModel *subredditModel;
@property (nonatomic, weak) id<RBSubredditView> subredditView;

@end

@implementation RBSubredditRouter

- (id)initWithModel:(RBSubredditModel *)model view:(id<RBSubredditView>)view {
    self = [super init];
    if (self) {
        model.delegateForModel = self;
        view.delegateForView = self;
    }
    return self;
}

@end
