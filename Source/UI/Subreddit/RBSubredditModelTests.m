#import <XCTest/XCTest.h>
#import "RBSubredditModel.h"
#import "RBRedditFeedManager.h"

@interface RBSubredditModelTests : XCTestCase <RBSubredditModelDelegate>

@property (nonatomic) RBSubredditModel *testObject;
@property (nonatomic) RBRedditFeedManager *mockFeedManager;
@property (nonatomic) NSString *signal;
@property (nonatomic) NSArray *subredditTestItems;

@end

@implementation RBSubredditModelTests

static NSInteger kAsyncSignalTimeOut = 1.0;

- (void)setUp {
    [super setUp];
    _signal = @"AsyncSignal";
    _subredditTestItems = @[@"a", @"b", @"c"];
    _mockFeedManager = mock([RBRedditFeedManager class]);
    _testObject = [[RBSubredditModel alloc] initWithSubredditFeedManager:_mockFeedManager];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testFetchSubredditFeedsPassesRequestToTheRedditFeedManager {
    NSString *feedname = @"/a/b/c";
    [_testObject fetchSubredditFeed:feedname];
    
    [verifyCount(_mockFeedManager, times(1)) fetchFeed:feedname
                                       completionBlock:anything()];
}

- (void)testFetchSubredditFeedsPassesResultsTooDelegate {
    NSString *feedname = @"/1/2/3";
    _testObject.delegateForModel = self;
    
    [_testObject fetchSubredditFeed:feedname];
    
    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockFeedManager, times(1)) fetchFeed:feedname
                                       completionBlock:[argument capture]];
    RBRedditFeedManagerCompletionBlock block = [argument value];
    block(_subredditTestItems);

    BOOL signaled = [self asyWaitForSignal:_signal timeout:kAsyncSignalTimeOut];
    ASYAssertTrue(signaled);
}

#pragma mark - RBSubredditModelDelegate

- (void)receivedSubredditItems:(NSArray *)items forFeedName:(NSString *)feedName {
    XCTAssertTrue(feedName, @"/1/2/3");
    if ([items isEqual:_subredditTestItems]) {
        [self asySignal:_signal];
    }
}

@end
