#import <XCTest/XCTest.h>
#import "RBNetworkService.h"
#import "RBPersistenceService.h"
#import "RBRedditFeedManager.h"
#import "RBRedditItem.h"

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
    NSString *feedName = @"FishingForFun";
    NSString *feed = [NSString stringWithFormat:@"/r/%@.json", feedName];
    NSString *expectedURLAsString = [NSString stringWithFormat:@"http://www.reddit.com%@", feed];
    
    [_testObject fetchFeed:feedName completionBlock:nil];
    
    [verifyCount(_mockNetworkService, times(1)) GET:expectedURLAsString
                                    completionBlock:anything()];
}

- (void)testThatFetchingAFeedSuccessfullyInvokesCompletionBlock {
    NSString *feedName = @"FishingForFun";
    NSString *feed = [NSString stringWithFormat:@"/r/%@.json", feedName];
    NSString *urlAsString = [NSString stringWithFormat:@"http://www.reddit.com%@", feed];
    
    __block BOOL completionBlockFired = NO;
    RBRedditFeedManagerCompletionBlock completionBlock = ^(NSArray *items) {
        completionBlockFired = YES;
    };
    
    [_testObject fetchFeed:feedName completionBlock:completionBlock];
    
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
    NSArray *expectedItems = [RBRedditItem itemsForJSONFeed:jsonFeedAsDictionary];
    NSInteger expectedCount = [expectedItems count];
    __block RBRedditItem *item = expectedItems[0];
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
    
    NSString *feed = @"FishingForFun";
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

- (void)testThatPersistenceManagerIsUsedToSaveItemsFetchedFromNetworkService {
    NSDictionary *exampleJSONDictionary = [self createDictionaryOfRBRedditItem];
    RBRedditItem *item = [[RBRedditItem alloc] init];
    item.title = @"Star Wars";
    NSString *feed = @"/anything/non/null";
    [_testObject fetchFeed:feed completionBlock:^(NSArray *feedItems) { }];
    
    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockNetworkService, times(1)) GET:anything()
                                    completionBlock:[argument capture]];
    void (^actualCompletionBlock)(id response, NSError *error) = [argument value];
    actualCompletionBlock(exampleJSONDictionary, nil);
    
    MKTArgumentCaptor *argument2 = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockPersistenceService, times(1)) saveRedditItem:[argument2 capture]];
    RBRedditItem *item2 = [argument2 value];
    
    XCTAssertEqual(item2.title, @"The Title");
    XCTAssertEqual(item2.permalink, @"The Permalink");
    XCTAssertEqual(item2.author, @"The Author");
    XCTAssertEqual(item2.subreddit, @"The Subreddit");
}

- (void)testThatUserPreferencesIsUpdated {
    NSString *lastRefreshKey = @"LastNetworkRefreshDate";
    NSString *feed = @"/generation/X";
    
    NSDate *lastRefreshDate = [[NSUserDefaults standardUserDefaults] valueForKey:lastRefreshKey];
    XCTAssertNil(lastRefreshDate);

    [_testObject fetchFeed:feed completionBlock:^(NSArray *feedItems) { }];

    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockNetworkService, times(1)) GET:anything()
                                    completionBlock:[argument capture]];
    void (^actualCompletionBlock)(id response, NSError *error) = [argument value];
    actualCompletionBlock(@{ }, nil);
    
    lastRefreshDate = [[NSUserDefaults standardUserDefaults] valueForKey:lastRefreshKey];
    XCTAssertNotNil(lastRefreshDate);
}

- (void)testThatTriadModelIsInformed {
    NSDictionary *exampleJSONDictionary = [self createDictionaryOfRBRedditItem];
    NSString *lastRefreshKey = @"LastNetworkRefreshDate";
    NSString *feed = @"/generation/X";
    id<RBRedditFeedManagerDelegate> delegate = mockProtocol(@protocol(RBRedditFeedManagerDelegate));
    _testObject.delegateForFeedManager = delegate;
    
    NSDate *lastRefreshDate = [[NSUserDefaults standardUserDefaults] valueForKey:lastRefreshKey];
    XCTAssertNil(lastRefreshDate);
    
    [_testObject fetchFeed:feed completionBlock:^(NSArray *feedItems) { }];
    
    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockNetworkService, times(1)) GET:anything()
                                    completionBlock:[argument capture]];
    void (^actualCompletionBlock)(id response, NSError *error) = [argument value];
    actualCompletionBlock(exampleJSONDictionary, nil);
    
    MKTArgumentCaptor *argument2 = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockPersistenceService, times(1)) saveRedditItem:[argument2 capture]];
    RBRedditItem *item2 = [argument2 value];
    
    [verifyCount(delegate, times(1)) latestFeedItems:@[item2]];
}

- (void)testThatNilBlocksAreNotAttempted {
    NSString *lastRefreshKey = @"LastNetworkRefreshDate";
    NSString *feed = @"/generation/X";
    
    NSDate *lastRefreshDate = [[NSUserDefaults standardUserDefaults] valueForKey:lastRefreshKey];
    XCTAssertNil(lastRefreshDate);
    
    [_testObject fetchFeed:feed completionBlock:nil];
    
    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockNetworkService, times(1)) GET:anything()
                                    completionBlock:[argument capture]];
    void (^actualCompletionBlock)(id response, NSError *error) = [argument value];
    actualCompletionBlock(@{ }, nil);
    
    lastRefreshDate = [[NSUserDefaults standardUserDefaults] valueForKey:lastRefreshKey];
    XCTAssertNotNil(lastRefreshDate);
}

- (void)testThatShouldFetchFromDatabaseWhenRefreshTimeHasntPassed {
    NSString *lastRefreshKey = @"LastNetworkRefreshDate";
    NSString *feed = @"/generation/X";
    
    NSDate *lastRefreshDate = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setValue:lastRefreshDate forKey:lastRefreshKey];
    
    [_testObject fetchFeed:feed completionBlock:^(NSArray *feedItems) { }];
    
    [verifyCount(_mockPersistenceService, times(1)) findAllItemsForFeed:feed];
}

- (void)testThatShouldCheckForNilBlock {
    NSString *lastRefreshKey = @"LastNetworkRefreshDate";
    NSString *feed = @"/generation/X";
    
    NSDate *lastRefreshDate = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setValue:lastRefreshDate forKey:lastRefreshKey];
    
    [_testObject fetchFeed:feed completionBlock:nil];
    
    [verifyCount(_mockPersistenceService, times(0)) findAllItemsForFeed:feed];
}

- (void)testThatWhenNetworkFetchFailsThenRetrieveDataFromCacheDatabase {
    NSString *lastRefreshKey = @"LastNetworkRefreshDate";
    NSString *feedName = @"/generation/X";
    id<RBRedditFeedManagerDelegate> delegate = mockProtocol(@protocol(RBRedditFeedManagerDelegate));
    _testObject.delegateForFeedManager = delegate;
    
    NSDate *lastRefreshDate = [[NSUserDefaults standardUserDefaults] valueForKey:lastRefreshKey];
    XCTAssertNil(lastRefreshDate);
    
    [_testObject fetchFeed:feedName completionBlock:^(NSArray *feedItems) { }];
    
    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockNetworkService, times(1)) GET:anything()
                                    completionBlock:[argument capture]];
    void (^actualCompletionBlock)(id response, NSError *error) = [argument value];
    actualCompletionBlock(nil, [NSError errorWithDomain:@"domain" code:123 userInfo:@{}]);
    
    [verifyCount(_mockPersistenceService, times(1)) findAllItemsForFeed:feedName];
}

- (void)testThatWhenNetworkFetchFailsThenRetrieveDataFromCacheDatabaseUnlessNilCompletionBlockWasPassedIn {
    NSString *lastRefreshKey = @"LastNetworkRefreshDate";
    NSString *feedName = @"/generation/X";
    id<RBRedditFeedManagerDelegate> delegate = mockProtocol(@protocol(RBRedditFeedManagerDelegate));
    _testObject.delegateForFeedManager = delegate;
    
    NSDate *lastRefreshDate = [[NSUserDefaults standardUserDefaults] valueForKey:lastRefreshKey];
    XCTAssertNil(lastRefreshDate);
    
    [_testObject fetchFeed:feedName completionBlock:nil];
    
    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockNetworkService, times(1)) GET:anything()
                                    completionBlock:[argument capture]];
    void (^actualCompletionBlock)(id response, NSError *error) = [argument value];
    actualCompletionBlock(nil, [NSError errorWithDomain:@"domain" code:123 userInfo:@{}]);
    
    [verifyCount(_mockPersistenceService, times(0)) findAllItemsForFeed:feedName];
}

#pragma mark - Private

- (NSDictionary *)createDictionaryOfRBRedditItem {
    NSDictionary *childData = @{ @"title" : @"The Title",
                                 @"permalink" : @"The Permalink",
                                 @"author" : @"The Author",
                                 @"subreddit" : @"The Subreddit" };
    return @{ @"data" : @{ @"children" : @[@{ @"data" : childData }] } };
}

@end
