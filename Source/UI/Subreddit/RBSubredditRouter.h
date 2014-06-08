#import <Foundation/Foundation.h>

@class RBSubredditModel;
@protocol RBSubredditView;

@interface RBSubredditRouter : NSObject

- (id)initWithModel:(RBSubredditModel *)model view:(id<RBSubredditView>)subRedditView;

@end
