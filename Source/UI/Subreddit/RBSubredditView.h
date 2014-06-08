#import <UIKit/UIKit.h>

@protocol RBSubredditViewDelegate <NSObject>

@end

@protocol RBSubredditView <NSObject>

@property (nonatomic, weak) id<RBSubredditViewDelegate> delegateForView;

- (void)setItems:(NSArray *)items forFeedName:(NSString *)feedName;

@end

@interface RBSubredditView : UIView<RBSubredditView>

@end
