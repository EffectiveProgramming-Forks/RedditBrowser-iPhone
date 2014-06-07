#import <XCTest/XCTest.h>
#import "RBNetworkService.h"
#import "RBRedditFeedManager.h"

@interface RBRedditFeedManagerTests : XCTestCase

@property (nonatomic) RBRedditFeedManager *testObject;
@property (nonatomic) RBNetworkService *mockNetworkService;

@end

@implementation RBRedditFeedManagerTests

- (void)setUp {
    [super setUp];
    _mockNetworkService = mock([RBNetworkService class]);
    _testObject = [[RBRedditFeedManager alloc] initWithNetworkService:_mockNetworkService];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatFetchingAFeedPassesCallToService {
    NSString *feed = @"/r/ListenToThis";
    NSString *expectedURLAsString = [NSString stringWithFormat:@"http://www.reddit.com%@", feed];
    
    [_testObject fetchFeed:feed completionBlock:nil];
    
    [verifyCount(_mockNetworkService, times(1)) GET:expectedURLAsString
                                    completionBlock:anything()];
}

@end
