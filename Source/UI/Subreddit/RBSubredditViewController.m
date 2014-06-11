#import "RBSubredditViewController.h"

#import "RBSubredditRouter.h"
#import "RBSubredditModel.h"
#import "RBSubredditView.h"
#import "RBRedditFeedManager.h"
#import "RBNetworkService.h"
#import "RBPersistenceService.h"
#import "RBPersistenceServiceFactory.h"

@interface RBSubredditViewController ()

@property (nonatomic) RBSubredditRouter *subredditRouter;
@property (nonatomic) RBSubredditModel *subredditModel;
@property (nonatomic) RBSubredditView *subredditView;

@end

@implementation RBSubredditViewController

- (void)loadView {
    [super loadView];
    
    RBPersistenceServiceFactory *persistenceServiceFactory = [RBPersistenceServiceFactory persistenceServiceFactory];
    RBNetworkService *networkService = [RBNetworkService networkService];
    RBRedditFeedManager *feedManager = [[RBRedditFeedManager alloc] initWithNetworkService:networkService
                                                                 persistenceServiceFactory:persistenceServiceFactory];
    _subredditModel = [[RBSubredditModel alloc] initWithSubredditFeedManager:feedManager];
    _subredditView = [[RBSubredditView alloc] initWithFrame:self.view.bounds navigationItem:self.navigationItem];
    _subredditRouter = [[RBSubredditRouter alloc] initWithModel:_subredditModel view:_subredditView];
    
    [self.view addSubview:_subredditView];
}

@end
