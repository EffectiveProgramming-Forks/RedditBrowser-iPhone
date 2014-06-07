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
    [self setupNavigationBar];
    
    _subredditModel = [[RBSubredditModel alloc] init];
    _subredditView = [[RBSubredditView alloc] initWithFrame:self.view.bounds];
    _subredditRouter = [[RBSubredditRouter alloc] initWithModel:_subredditModel view:_subredditView];
    
    [self.view addSubview:_subredditView];
}

#pragma mark - Actions

- (void)refreshButtonWasTapped:(UIBarButtonItem *)refreshButton {
    NSLog(@"Refresh button was tapped.");
}

#pragma mark - Private

- (void)setupNavigationBar {
    self.title = NSLocalizedString(@"SubredditViewController.Title", nil);
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(refreshButtonWasTapped:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
}

@end
