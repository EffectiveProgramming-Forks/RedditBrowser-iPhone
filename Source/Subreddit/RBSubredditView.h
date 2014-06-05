#import <UIKit/UIKit.h>

@protocol RBSubredditViewDelegate <NSObject>

@end

@protocol RBSubredditView <NSObject>

@property (nonatomic, weak) id<RBSubredditViewDelegate> delegateForView;

@end

@interface RBSubredditView : UIView<RBSubredditView>

@end
