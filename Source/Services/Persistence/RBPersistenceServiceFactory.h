#import <Foundation/Foundation.h>

@class RBPersistenceService;

@interface RBPersistenceServiceFactory : NSObject

+ (BOOL)setup;
+ (void)teardown;
+ (instancetype)persistenceServiceFactory;

- (RBPersistenceService *)temporaryPersistenceService;
- (RBPersistenceService *)mainPersistenceService;

@end
