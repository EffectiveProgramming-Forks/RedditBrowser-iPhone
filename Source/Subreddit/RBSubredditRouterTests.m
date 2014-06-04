#import <XCTest/XCTest.h>
#import "RBSubredditRouter.h"
#import "RBSubredditModel.h"
#import "RBSubredditView.h"

@interface RBSubredditRouterTests : XCTestCase

@end

@implementation RBSubredditRouterTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testRouterConstruction {
    id<RBSubredditView> mockView = mockProtocol(@protocol(RBSubredditView));
    RBSubredditModel *mockModel = mock([RBSubredditModel class]);
    
    RBSubredditRouter *testObject = [[RBSubredditRouter alloc] initWithModel:mockModel view:mockView];
    
    XCTAssertNotNil(testObject);
}

@end
