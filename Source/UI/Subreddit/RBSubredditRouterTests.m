#import <XCTest/XCTest.h>
#import "RBSubredditRouter.h"
#import "RBSubredditModel.h"
#import "RBSubredditView.h"

@interface RBSubredditRouter (TestExposure) <RBSubredditModelDelegate, RBSubredditViewDelegate>

- (void)refreshButtonWasTapped;

@end

@interface RBSubredditRouterTests : XCTestCase

@property (nonatomic) id<RBSubredditView> mockView;
@property (nonatomic) RBSubredditModel *mockModel;
@property (nonatomic) RBSubredditRouter *testObject;

@end

@implementation RBSubredditRouterTests

static NSString *kSubredditName = @"listentothis";

- (void)setUp {
    [super setUp];
    _mockView = mockProtocol(@protocol(RBSubredditView));
    _mockModel = mock([RBSubredditModel class]);
    _testObject = [[RBSubredditRouter alloc] initWithModel:_mockModel view:_mockView];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testRouterConstruction {
    XCTAssertNotNil(_testObject);
}

- (void)testRouterRegistersForViewEvents {
    [verifyCount(_mockView, times(1)) setDelegateForView:_testObject];
}

- (void)testRouterRegistersForModelEvents {
    [verifyCount(_mockModel, times(1)) setDelegateForModel:_testObject];
}

- (void)testRouterRequestsFeedsFromModel {
    [verifyCount(_mockModel, times(1)) fetchSubreddit:kSubredditName force:NO];
}

- (void)testThatRouterRequestsFeedsFromModelWhenRefreshButtonIsTapped {
    [_testObject refreshButtonWasTapped];
    
    [verifyCount(_mockModel, times(1)) fetchSubreddit:kSubredditName force:YES];
}

- (void)testRouterUpdatesViewUponReceivingData {
    NSArray *items = @[@"a", @"b", @"c"];
    [_testObject receivedItems:items forSubreddit:kSubredditName];
    
    [verifyCount(_mockView, times(1)) setItems:items forSubreddit:kSubredditName];
}

- (void)testThatRouterIsHardcodedToRetrieveListenToThis {
    [verifyCount(_mockModel, times(1)) fetchSubreddit:kSubredditName force:NO];
}

@end
