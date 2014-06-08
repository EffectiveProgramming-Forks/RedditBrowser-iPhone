#import <Foundation/Foundation.h>

@class RBNetworkService;
@class RBPersistenceService;

typedef void (^RBRedditFeedManagerCompletionBlock)(NSArray *feedItems);

@protocol RBRedditFeedManagerDelegate <NSObject>

- (void)latestFeedItems:(NSArray *)feedItems;

@end

/**
 * Business logic for fetching feeds.
 * Logic for caching between database and network is here.
 */
@interface RBRedditFeedManager : NSObject

- (id)initWithNetworkService:(RBNetworkService *)networkService
          persistenceService:(RBPersistenceService *)dataService;

- (void)fetchFeed:(NSString *)feedName
  completionBlock:(RBRedditFeedManagerCompletionBlock)completionBlock;

@end
