#import "RBSubredditViewController.h"

#import "RBSubredditRouter.h"
#import "RBSubredditModel.h"
#import "RBSubredditView.h"

@interface RBSubredditViewController ()

@property (nonatomic) RBSubredditRouter *subredditRouter;
@property (nonatomic) RBSubredditModel *subredditModel;
@property (nonatomic) RBSubredditView *subredditView;

@end

@implementation RBSubredditViewController

- (void)loadView {
    [super loadView];
    self.title = NSLocalizedString(@"SubredditViewController.Title", nil);
    
    
}

@end
