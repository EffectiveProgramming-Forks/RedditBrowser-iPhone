#import <UIKit/UIKit.h>

@class RBRedditItem;

@protocol RBSubredditViewDelegate <NSObject>

- (void)itemWasSelected:(RBRedditItem *)item;

@end

@protocol RBSubredditView <NSObject>

@property (nonatomic, weak) id<RBSubredditViewDelegate> delegateForView;

- (void)setItems:(NSArray *)items forFeedName:(NSString *)feedName;

@end

@interface RBSubredditView : UIView<RBSubredditView>

@end
