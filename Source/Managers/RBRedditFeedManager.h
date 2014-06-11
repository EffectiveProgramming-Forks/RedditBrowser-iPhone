#import <Foundation/Foundation.h>

typedef void (^RBRedditFeedManagerCompletionBlock)(NSArray *feedItems);

@class RBNetworkService;
@class RBPersistenceServiceFactory;

@protocol RBRedditFeedManagerDelegate <NSObject>

- (void)latestFeedItems:(NSArray *)feedItems;

@end

/**
 * Business logic for fetching feeds includes:
 * - logic for fetching from network
 * - logic for fetching and caching to local database
 */
@interface RBRedditFeedManager : NSObject

@property (nonatomic) id<RBRedditFeedManagerDelegate> delegateForFeedManager;

- (id)initWithNetworkService:(RBNetworkService *)networkService
   persistenceServiceFactory:(RBPersistenceServiceFactory *)persistenceServiceFactory;

- (void)fetchFeed:(NSString *)feedName
  completionBlock:(RBRedditFeedManagerCompletionBlock)completionBlock;

@end
