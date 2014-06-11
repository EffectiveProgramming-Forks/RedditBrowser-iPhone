#import "RBPersistenceServiceFactory.h"
#import "RBPersistenceService.h"
#import <CoreData/CoreData.h>

@interface RBPersistenceServiceFactory ()

@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) RBPersistenceService *mainPersistenceService;

@end

@implementation RBPersistenceServiceFactory

static RBPersistenceServiceFactory *persistenceServiceFactory;
static NSPersistentStoreCoordinator *persistentStoreCoordinator;
//static NSManagedObjectContext *mainManagedObjectContext;

+ (BOOL)setup {
    // data model
    NSURL *dataModelURL = [[NSBundle mainBundle] URLForResource:@"RedditBrowserDataModel" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:dataModelURL];
    
    // disk location
    NSURL *documentsURL = [self localDocumentsURL];
    NSURL *dataStoreURL = [documentsURL URLByAppendingPathComponent:@"RedditBrowserDatabase"];
    dataStoreURL = [dataStoreURL URLByAppendingPathExtension:@"sqlite"];
    
    // persistent store
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                        configuration:nil
                                                                                  URL:dataStoreURL
                                                                              options:nil
                                                                                error:&error];
    if (!store) {
        // STORY: handle this error in the app ...
        NSLog(@"ERROR - could not init database: %@", error);
    }
    return (store != nil);
}

+ (void)teardown {
    persistentStoreCoordinator = nil;
}

+ (instancetype)persistenceServiceFactory {
    static dispatch_once_t onceToken;
    static RBPersistenceServiceFactory *factory = nil;
    dispatch_once(&onceToken, ^{
        factory = [[self alloc] initWithPersistentStoreCoordinator:persistentStoreCoordinator];
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
        factory.mainPersistenceService = [[RBPersistenceService alloc] initWithManagedObjectContext:managedObjectContext];
    });
    return factory;
}

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    self = [super init];
    if (self) {
        _persistentStoreCoordinator = persistentStoreCoordinator;
    }
    return self;
}

- (RBPersistenceService *)mainPersistenceService {
    return _mainPersistenceService;
}

- (RBPersistenceService *)temporaryPersistenceService {
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    RBPersistenceService *persistenceService = [[RBPersistenceService alloc] initWithManagedObjectContext:managedObjectContext];
    return persistenceService;
}

#pragma mark - Private

+ (NSURL*)localDocumentsURL {
    NSURL *directory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	return directory;
}

@end
