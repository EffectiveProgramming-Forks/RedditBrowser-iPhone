#import <XCTest/XCTest.h>
#import "RBNetworkService.h"
#import "RBPersistenceServiceFactory.h"
#import "RBPersistenceService.h"
#import "RBSubredditManager.h"
#import "RBRedditItem.h"

@interface RBSubredditManagerTests : XCTestCase

@property (nonatomic) RBSubredditManager *testObject;
@property (nonatomic) RBNetworkService *mockNetworkService;
@property (nonatomic) RBPersistenceServiceFactory *mockPersistenceServiceFactory;
@property (nonatomic) RBPersistenceService *mockPersistenceService;

@end

@implementation RBSubredditManagerTests

static NSString *kLastRefreshKey = @"LastNetworkRefreshDate";

- (void)setUp {
    [super setUp];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastRefreshKey];
    _mockNetworkService = mock([RBNetworkService class]);
    _mockPersistenceServiceFactory = mock([RBPersistenceServiceFactory class]);
    _mockPersistenceService = mock([RBPersistenceService class]);
    [given([_mockPersistenceServiceFactory temporaryPersistenceService]) willReturn:_mockPersistenceService];
    [given([_mockPersistenceServiceFactory mainPersistenceService]) willReturn:_mockPersistenceService];
    _testObject = [[RBSubredditManager alloc] initWithNetworkService:_mockNetworkService
                                            persistenceServiceFactory:_mockPersistenceServiceFactory];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatFetchingAFeedPassesControlToService {
    NSString *subredditName = @"FishingForFun";
    NSString *subreddit = [NSString stringWithFormat:@"/r/%@.json", subredditName];
    NSString *expectedURLAsString = [NSString stringWithFormat:@"http://www.reddit.com%@", subreddit];
    
    [_testObject fetchSubreddit:subredditName force:NO completionBlock:nil];
    
    [verifyCount(_mockNetworkService, times(1)) GET:expectedURLAsString
                                    completionBlock:anything()];
}

- (void)testThatFetchingAFeedSuccessfullyInvokesCompletionBlock {
    NSString *subredditName = @"FishingForFun";
    NSString *subreddit = [NSString stringWithFormat:@"/r/%@.json", subredditName];
    NSString *urlAsString = [NSString stringWithFormat:@"http://www.reddit.com%@", subreddit];
    
    __block BOOL completionBlockFired = NO;
    RBSubredditManagerCompletionBlock completionBlock = ^(NSArray *items) {
        completionBlockFired = YES;
    };
    
    [_testObject fetchSubreddit:subredditName force:NO completionBlock:completionBlock];
    
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
    RBSubredditManagerCompletionBlock completionBlock = ^(NSArray *items) {
        actualCount = [items count];
        item = items[0];
        actualFirstTitle = item.title;
        item = items[1];
        actualSecondTitle = item.title;
    };
    
    NSString *subreddit = @"FishingForFun";
    [_testObject fetchSubreddit:subreddit force:NO completionBlock:completionBlock];
    
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
    NSString *subreddit = @"/anything/non/null";
    
    [_testObject fetchSubreddit:subreddit force:NO completionBlock:^(NSArray *feedItems) { }];
    
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

- (void)testThatAUUIDIsSetOnItemsBeforeTheyAreSaved {
    NSDictionary *exampleJSONDictionary = [self createDictionaryOfRBRedditItem];
    RBRedditItem *item = [[RBRedditItem alloc] init];
    item.title = @"Star Wars";
    NSString *subreddit = @"/anything/non/null";
    
    [_testObject fetchSubreddit:subreddit force:NO completionBlock:^(NSArray *feedItems) { }];
    
    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockNetworkService, times(1)) GET:anything()
                                    completionBlock:[argument capture]];
    void (^actualCompletionBlock)(id response, NSError *error) = [argument value];
    actualCompletionBlock(exampleJSONDictionary, nil);
    
    MKTArgumentCaptor *argument2 = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockPersistenceService, times(1)) saveRedditItem:[argument2 capture]];
    RBRedditItem *item2 = [argument2 value];
    
    XCTAssertNotNil(item2.uuid);
}

- (void)testThatPersistenceManagerFetchesOldItems {
    NSDictionary *exampleJSONDictionary = [self createDictionaryOfRBRedditItem];
    RBRedditItem *item = [[RBRedditItem alloc] init];
    item.title = @"Star Wars";
    NSString *subreddit = @"/anything/non/null";
    
    [_testObject fetchSubreddit:subreddit force:NO completionBlock:^(NSArray *feedItems) { }];
    
    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockNetworkService, times(1)) GET:anything()
                                    completionBlock:[argument capture]];
    void (^actualCompletionBlock)(id response, NSError *error) = [argument value];
    actualCompletionBlock(exampleJSONDictionary, nil);
    
    [verifyCount(_mockPersistenceService, times(1)) findAllItemsForSubreddit:subreddit notUUID:anything()];
}

- (void)testThatPersistenceManagerDeletesOldItems {
    NSDictionary *exampleJSONDictionary = [self createDictionaryOfRBRedditItem];
    RBRedditItem *item = [[RBRedditItem alloc] init];
    item.title = @"Star Wars";
    NSString *subreddit = @"/anything/non/null";
    RBRedditItem *deletableItem = [self redditItem];
    [given([_mockPersistenceService findAllItemsForSubreddit:subreddit notUUID:anything()]) willReturn:@[deletableItem]];

    [_testObject fetchSubreddit:subreddit force:NO completionBlock:^(NSArray *feedItems) { }];
    
    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockNetworkService, times(1)) GET:anything()
                                    completionBlock:[argument capture]];
    void (^actualCompletionBlock)(id response, NSError *error) = [argument value];
    actualCompletionBlock(exampleJSONDictionary, nil);
    
    [_mockPersistenceService deleteRedditItem:deletableItem];
}

- (void)testThatUserPreferencesIsUpdated {
    NSString *feed = @"/generation/X";
    
    NSDate *lastRefreshDate = [[NSUserDefaults standardUserDefaults] valueForKey:kLastRefreshKey];
    XCTAssertNil(lastRefreshDate);

    [_testObject fetchSubreddit:feed force:NO completionBlock:^(NSArray *feedItems) { }];

    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockNetworkService, times(1)) GET:anything()
                                    completionBlock:[argument capture]];
    void (^actualCompletionBlock)(id response, NSError *error) = [argument value];
    actualCompletionBlock(@{ }, nil);
    
    lastRefreshDate = [[NSUserDefaults standardUserDefaults] valueForKey:kLastRefreshKey];
    XCTAssertNotNil(lastRefreshDate);
}

- (void)testThatTriadModelIsInformed {
    NSDictionary *exampleJSONDictionary = [self createDictionaryOfRBRedditItem];
    NSString *feed = @"/generation/X";
    id<RBSubredditManagerDelegate> delegate = mockProtocol(@protocol(RBSubredditManagerDelegate));
    _testObject.delegateForFeedManager = delegate;
    
    NSDate *lastRefreshDate = [[NSUserDefaults standardUserDefaults] valueForKey:kLastRefreshKey];
    XCTAssertNil(lastRefreshDate);
    
    [_testObject fetchSubreddit:feed force:NO completionBlock:^(NSArray *feedItems) { }];
    
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
    NSString *feed = @"/generation/X";
    
    NSDate *lastRefreshDate = [[NSUserDefaults standardUserDefaults] valueForKey:kLastRefreshKey];
    XCTAssertNil(lastRefreshDate);
    
    [_testObject fetchSubreddit:feed force:NO completionBlock:nil];
    
    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockNetworkService, times(1)) GET:anything()
                                    completionBlock:[argument capture]];
    void (^actualCompletionBlock)(id response, NSError *error) = [argument value];
    actualCompletionBlock(@{ }, nil);
    
    lastRefreshDate = [[NSUserDefaults standardUserDefaults] valueForKey:kLastRefreshKey];
    XCTAssertNotNil(lastRefreshDate);
}

- (void)testThatShouldFetchFromDatabaseWhenRefreshTimeHasntPassed {
    NSString *subreddit = @"/generation/X";
    
    NSDate *lastRefreshDate = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setValue:lastRefreshDate forKey:kLastRefreshKey];
    
    [_testObject fetchSubreddit:subreddit force:NO completionBlock:^(NSArray *feedItems) { }];
    
    [verifyCount(_mockPersistenceService, times(1)) findAllItemsForSubreddit:subreddit];
}

- (void)testThatShouldFetchFromNetworkIfForceEqualsYES {
    NSString *subreddit = @"/generation/X";
    
    NSDate *lastRefreshDate = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setValue:lastRefreshDate forKey:kLastRefreshKey];
    
    [_testObject fetchSubreddit:subreddit force:YES completionBlock:^(NSArray *feedItems) { }];
    
    [verifyCount(_mockNetworkService, times(1)) GET:anything() completionBlock:anything()];
}

- (void)testThatShouldCheckForNilBlock {
    NSString *subreddit = @"/generation/X";
    
    NSDate *lastRefreshDate = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setValue:lastRefreshDate forKey:kLastRefreshKey];
    
    [_testObject fetchSubreddit:subreddit force:NO completionBlock:nil];
    
    [verifyCount(_mockPersistenceService, times(0)) findAllItemsForSubreddit:subreddit];
}

- (void)testThatWhenNetworkFetchFailsThenRetrieveDataFromCacheDatabase {
    NSString *subreddit = @"/generation/X";
    id<RBSubredditManagerDelegate> delegate = mockProtocol(@protocol(RBSubredditManagerDelegate));
    _testObject.delegateForFeedManager = delegate;
    
    NSDate *lastRefreshDate = [[NSUserDefaults standardUserDefaults] valueForKey:kLastRefreshKey];
    XCTAssertNil(lastRefreshDate);
    
    [_testObject fetchSubreddit:subreddit force:NO completionBlock:^(NSArray *feedItems) { }];
    
    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockNetworkService, times(1)) GET:anything()
                                    completionBlock:[argument capture]];
    void (^actualCompletionBlock)(id response, NSError *error) = [argument value];
    actualCompletionBlock(nil, [NSError errorWithDomain:@"domain" code:123 userInfo:@{}]);
    
    [verifyCount(_mockPersistenceService, times(1)) findAllItemsForSubreddit:subreddit];
}

- (void)testThatWhenNetworkFetchFailsThenRetrieveDataFromCacheDatabaseUnlessNilCompletionBlockWasPassedIn {
    NSString *feedName = @"/generation/X";
    id<RBSubredditManagerDelegate> delegate = mockProtocol(@protocol(RBSubredditManagerDelegate));
    _testObject.delegateForFeedManager = delegate;
    
    NSDate *lastRefreshDate = [[NSUserDefaults standardUserDefaults] valueForKey:kLastRefreshKey];
    XCTAssertNil(lastRefreshDate);
    
    [_testObject fetchSubreddit:feedName force:NO completionBlock:nil];
    
    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verifyCount(_mockNetworkService, times(1)) GET:anything()
                                    completionBlock:[argument capture]];
    void (^actualCompletionBlock)(id response, NSError *error) = [argument value];
    actualCompletionBlock(nil, [NSError errorWithDomain:@"domain" code:123 userInfo:@{}]);
    
    [verifyCount(_mockPersistenceService, times(0)) findAllItemsForSubreddit:feedName];
}

#pragma mark - Private

- (RBRedditItem *)redditItem {
    RBRedditItem *item = [[RBRedditItem alloc] init];
    item.title = @"The Old Title";
    item.permalink = @"The Old Permalink";
    item.author = @"The Old Author";
    item.subreddit = @"The Old Subreddit";
    return item;
}

- (NSDictionary *)createDictionaryOfRBRedditItem {
    NSDictionary *childData = @{ @"title" : @"The Title",
                                 @"permalink" : @"The Permalink",
                                 @"author" : @"The Author",
                                 @"subreddit" : @"The Subreddit" };
    return @{ @"data" : @{ @"children" : @[@{ @"data" : childData }] } };
}

@end
