#import <Foundation/Foundation.h>

@class RBSubredditManager;

@protocol RBSubredditModelDelegate <NSObject>

- (void)receivedItems:(NSArray *)items forSubreddit:(NSString *)feedName;

@end

@interface RBSubredditModel : NSObject

@property (nonatomic, weak) id<RBSubredditModelDelegate> delegateForModel;

- (id)initWithSubredditManager:(RBSubredditManager *)feedManager;

- (void)fetchSubreddit:(NSString *)subredditName force:(BOOL)force;

@end
