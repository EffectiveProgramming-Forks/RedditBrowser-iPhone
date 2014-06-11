#import <Foundation/Foundation.h>

typedef void (^RBSubredditManagerCompletionBlock)(NSArray *feedItems);

@class RBNetworkService;
@class RBPersistenceServiceFactory;

@protocol RBSubredditManagerDelegate <NSObject>

- (void)latestFeedItems:(NSArray *)feedItems;

@end

/**
 * Business logic for fetching feeds includes:
 * - logic for fetching from network
 * - logic for fetching and caching to local database
 */
@interface RBSubredditManager : NSObject

@property (nonatomic) id<RBSubredditManagerDelegate> delegateForFeedManager;

- (id)initWithNetworkService:(RBNetworkService *)networkService
   persistenceServiceFactory:(RBPersistenceServiceFactory *)persistenceServiceFactory;

- (void)fetchSubreddit:(NSString *)feedName
            force:(BOOL)force
  completionBlock:(RBSubredditManagerCompletionBlock)completionBlock;

@end
