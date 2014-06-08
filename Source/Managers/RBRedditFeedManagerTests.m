#import <XCTest/XCTest.h>
#import "RBNetworkService.h"
#import "RBPersistenceService.h"
#import "RBRedditFeedManager.h"
#import "RBSubredditItem.h"

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

- (void)testThatFetchingAFeedCreatesCorrectSubredditItems {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ListenToThis" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *jsonFeedAsDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSArray *expectedItems = [RBSubredditItem itemsForJSONFeed:jsonFeedAsDictionary];
    NSInteger expectedCount = [expectedItems count];
    __block RBSubredditItem *item = expectedItems[0];
    NSString *expectedFirstTitle = item.title;
    item = expectedItems[1];
    NSString *expectedSecondTitle = item.title;
    
    __block NSInteger actualCount = 0;
    __block NSString *actualFirstTitle = @"";
    __block NSString *actualSecondTitle = @"";
    RBRedditFeedManagerCompletionBlock completionBlock = ^(NSArray *items) {
        actualCount = [items count];
        item = items[0];
        actualFirstTitle = item.title;
        item = items[1];
        actualSecondTitle = item.title;
    };
    
    NSString *feed = @"/r/ListenToThis";
    [_testObject fetchFeed:feed completionBlock:completionBlock];
    
    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockNetworkService, times(1)) GET:anything()
                                    completionBlock:[argument capture]];
    void (^actualCompletionBlock)(id response, NSError *error) = [argument value];
    actualCompletionBlock(jsonFeedAsDictionary, nil);
    
    XCTAssertEqual(actualCount, expectedCount);
    XCTAssertEqualObjects(actualFirstTitle, expectedFirstTitle);
    XCTAssertEqualObjects(actualSecondTitle, expectedSecondTitle);
}

@end
