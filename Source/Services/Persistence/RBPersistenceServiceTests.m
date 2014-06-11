#import <XCTest/XCTest.h>
#import "RBPersistenceService.h"
#import "RBRedditItem.h"
#import "RBRedditBrowserEntities.h"
#import <CoreData/CoreData.h>

@interface RBPersistenceServiceTests : XCTestCase

@property (nonatomic) RBPersistenceService *testObject;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation RBPersistenceServiceTests

- (void)setUp {
    [super setUp];
    _managedObjectContext = [self inMemoryManagedObjectContext];
    _testObject = [[RBPersistenceService alloc] initWithManagedObjectContext:_managedObjectContext];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Tests

- (void)testSaveRedditItem {
    RBRedditItem *item = [[RBRedditItem alloc] init];
    item.title = @"White Desk";
    item.permalink = @"http://furniture.com/desk/white";
    item.author = @"John Doe";
    item.subreddit = @"Furniture";
    item.uuid = @"64DigitNumber";
    
    [_testObject saveRedditItem:item];

    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RedditItem"];
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    XCTAssertEqual([items count], 1);
    if ([items count] == 1) {
        RedditItemEntity *entity = items[0];
        XCTAssertEqualObjects(item.title, entity.title);
        XCTAssertEqualObjects(item.permalink, entity.permalink);
        XCTAssertEqualObjects(item.author, entity.author);
        XCTAssertEqualObjects(item.subreddit, entity.subreddit);
        XCTAssertEqualObjects(item.uuid, entity.uuid);
    }
}

- (void)testDeleteRedditItem {
    RBRedditItem *item = [[RBRedditItem alloc] init];
    item.title = @"White Desk";
    item.permalink = @"http://furniture.com/desk/white";
    item.author = @"John Doe";
    item.subreddit = @"Furniture";
    item.uuid = @"64DigitNumber";
    
    [_testObject saveRedditItem:item];
    
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RedditItem"];
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    RedditItemEntity *entity = items[0];
    [_managedObjectContext deleteObject:entity];

    error = nil;
    fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RedditItem"];
    items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    XCTAssertEqual([items count], 0);
}

- (void)testFindAllItemsForFeed {
    RBRedditItem *item1 = [[RBRedditItem alloc] init];
    item1.title = @"White Desk";
    item1.permalink = @"http://furniture.com/desk/white/john";
    item1.author = @"John Doe";
    item1.subreddit = @"Furniture";
    item1.uuid = @"64DigitNumber";
    RBRedditItem *item2 = [[RBRedditItem alloc] init];
    item2.title = @"White Desk";
    item2.permalink = @"http://furniture.com/desk/white/jane";
    item2.author = @"Jane Doe";
    item2.subreddit = @"Furniture";
    item2.uuid = @"64DigitNumber";
    
    [_testObject saveRedditItem:item1];
    [_testObject saveRedditItem:item2];
    
    NSArray *items = [_testObject findAllItemsForSubreddit:@"Furniture"];
    
    XCTAssertEqual([items count], 2);
}

- (void)testFindAllItemsForFeednotUUID {
    RBRedditItem *item1 = [[RBRedditItem alloc] init];
    item1.title = @"White Desk";
    item1.permalink = @"http://furniture.com/desk/white/john";
    item1.author = @"John Doe";
    item1.subreddit = @"Furniture";
    item1.uuid = @"64DigitNumber";
    RBRedditItem *item2 = [[RBRedditItem alloc] init];
    item2.title = @"White Desk";
    item2.permalink = @"http://furniture.com/desk/white/jane";
    item2.author = @"Jane Doe";
    item2.subreddit = @"Furniture";
    item2.uuid = @"64DigitNumber";
    RBRedditItem *item3 = [[RBRedditItem alloc] init];
    item3.title = @"White Desk";
    item3.permalink = @"http://furniture.com/desk/white/john";
    item3.author = @"John Doe";
    item3.subreddit = @"Furniture";
    item3.uuid = @"64DigitNumber";
    RBRedditItem *item4 = [[RBRedditItem alloc] init];
    item4.title = @"Green Chair";
    item4.permalink = @"http://furniture.com/chair/green/jill";
    item4.author = @"Jill Doe";
    item4.subreddit = @"Furniture";
    item4.uuid = @"64DigitNumberFromLongTimeAgo";
    [_testObject saveRedditItem:item1];
    [_testObject saveRedditItem:item2];
    [_testObject saveRedditItem:item3];
    [_testObject saveRedditItem:item4];
    
    NSArray *items = [_testObject findAllItemsForSubreddit:@"Furniture" notUUID:@"64DigitNumberFromLongTimeAgo"];
    
    XCTAssertEqual([items count], 3);
    RedditItemEntity *entity = items[0];
    XCTAssertEqualObjects(entity.title, @"White Desk");
    XCTAssertEqualObjects(entity.uuid, @"64DigitNumber");
    entity = items[1];
    XCTAssertEqualObjects(entity.title, @"White Desk");
    XCTAssertEqualObjects(entity.uuid, @"64DigitNumber");
    entity = items[2];
    XCTAssertEqualObjects(entity.title, @"White Desk");
    XCTAssertEqualObjects(entity.uuid, @"64DigitNumber");
}

#pragma mark - Private

- (NSManagedObjectContext *)inMemoryManagedObjectContext {
    // data model
    NSURL *dataModelURL = [[NSBundle mainBundle] URLForResource:@"RedditBrowserDataModel" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:dataModelURL];
    
    // persistent store
    NSError *error = nil;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                                        configuration:nil
                                                                                  URL:nil
                                                                              options:nil
                                                                                error:&error];
    if (!persistentStore) {
        // STORY: handle this error in the app ...
        NSLog(@"ERROR - could not init database: %@", error);
        return nil;
    } else {
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
        return managedObjectContext;
    }
}

- (RBRedditItem *)redditItem {
    RBRedditItem *item = [[RBRedditItem alloc] init];
    item.title = @"White Desk";
    item.permalink = @"http://furniture.com/desk/white";
    item.author = @"John Doe";
    item.subreddit = @"Furniture";
    item.uuid = @"64DigitNumber";
    return item;
}

@end
