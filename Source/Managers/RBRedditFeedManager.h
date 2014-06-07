#import <Foundation/Foundation.h>
#import "RBNetworkBlocks.h"

@class RBNetworkService;

@protocol RBRedditFeedManagerDelegate <NSObject>

- (void)latestFeedItems:(NSArray *)feedItems;

@end

@interface RBRedditFeedManager : NSObject

- (id)initWithNetworkService:(RBNetworkService *)networkService;

- (void)fetchFeed:(NSString *)feedName completionBlock:(RBJSONCompletionBlock)completionBlock;

@end
