#import <XCTest/XCTest.h>
#import "RBSubredditModel.h"
#import "RBSubredditManager.h"

@interface RBSubredditModelTests : XCTestCase <RBSubredditModelDelegate>

@property (nonatomic) RBSubredditModel *testObject;
@property (nonatomic) RBSubredditManager *mockFeedManager;
@property (nonatomic) NSString *signal;
@property (nonatomic) NSArray *subredditTestItems;

@end

@implementation RBSubredditModelTests

static NSInteger kAsyncSignalTimeOut = 1.0;

- (void)setUp {
    [super setUp];
    _signal = @"AsyncSignal";
    _subredditTestItems = @[@"a", @"b", @"c"];
    _mockFeedManager = mock([RBSubredditManager class]);
    _testObject = [[RBSubredditModel alloc] initWithSubredditManager:_mockFeedManager];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testFetchSubredditPassesRequestToTheSubredditManager {
    NSString *feedname = @"/a/b/c";
    [_testObject fetchSubreddit:feedname force:NO];
    
    [verifyCount(_mockFeedManager, times(1)) fetchSubreddit:feedname
                                                 force:NO
                                       completionBlock:anything()];
}

- (void)testFetchSubredditPassesResultsToDelegate {
    NSString *feedname = @"/1/2/3";
    _testObject.delegateForModel = self;
    
    [_testObject fetchSubreddit:feedname force:YES];
    
    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockFeedManager, times(1)) fetchSubreddit:feedname
                                                 force:YES
                                       completionBlock:[argument capture]];
    RBSubredditManagerCompletionBlock block = [argument value];
    block(_subredditTestItems);

    BOOL signaled = [self asyWaitForSignal:_signal timeout:kAsyncSignalTimeOut];
    ASYAssertTrue(signaled);
}

#pragma mark - RBSubredditModelDelegate

- (void)receivedItems:(NSArray *)items forSubreddit:(NSString *)feedName {
    XCTAssertTrue(feedName, @"/1/2/3");
    if ([items isEqual:_subredditTestItems]) {
        [self asySignal:_signal];
    }
}

@end
