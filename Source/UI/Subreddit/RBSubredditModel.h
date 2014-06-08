#import <Foundation/Foundation.h>

@class RBRedditFeedManager;

@protocol RBSubredditModelDelegate <NSObject>

- (void)receivedSubredditItems:(NSArray *)items forFeedName:(NSString *)feedName;

@end

@interface RBSubredditModel : NSObject

@property (nonatomic, weak) id<RBSubredditModelDelegate> delegateForModel;

- (id)initWithSubredditFeedManager:(RBRedditFeedManager *)feedManager;

- (void)fetchSubredditFeed:(NSString *)feedName;

@end
