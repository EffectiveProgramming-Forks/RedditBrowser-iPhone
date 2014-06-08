#import <XCTest/XCTest.h>
#import "RBNetworkService.h"
#import "RBPersistenceService.h"
#import "RBRedditFeedManager.h"

@interface RBRedditFeedManagerTests : XCTestCase

@property (nonatomic) RBRedditFeedManager *testObject;
@property (nonatomic) RBNetworkService *mockNetworkService;
@property (nonatomic) RBPersistenceService *mockPersistenceService;

@end

@implementation RBRedditFeedManagerTests

- (void)setUp {
    [super setUp];
    _mockNetworkService = mock([RBNetworkService class]);
    _mockPersistenceService = mock([RBPersistenceService class]);
    _testObject = [[RBRedditFeedManager alloc] initWithNetworkService:_mockNetworkService
                                                   persistenceService:_mockPersistenceService];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatFetchingAFeedPassesControlToService {
    NSString *feed = @"/r/ListenToThis";
    NSString *expectedURLAsString = [NSString stringWithFormat:@"http://www.reddit.com%@", feed];
    
    [_testObject fetchFeed:feed completionBlock:nil];
    
    [verifyCount(_mockNetworkService, times(1)) GET:expectedURLAsString
                                    completionBlock:anything()];
}

- (void)testThatFetchingAFeedSuccessfullyInvokesCompletionBlock {
    NSString *feed = @"/r/ListenToThis";
    NSString *urlAsString = [NSString stringWithFormat:@"http://www.reddit.com%@", feed];
    __block BOOL completionBlockFired = NO;
    RBRedditFeedManagerCompletionBlock completionBlock = ^(NSArray *items) {
        completionBlockFired = YES;
    };
    
    [_testObject fetchFeed:feed completionBlock:completionBlock];
    
    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockNetworkService, times(1)) GET:urlAsString
                                    completionBlock:[argument capture]];
    void (^actualCompletionBlock)(id response, NSError *error) = [argument value];
    actualCompletionBlock(@{}, nil);
    
    XCTAssertTrue(completionBlockFired);
}

@end
