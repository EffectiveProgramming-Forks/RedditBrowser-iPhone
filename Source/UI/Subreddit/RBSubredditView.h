#import <UIKit/UIKit.h>

@class RBRedditItem;

@protocol RBSubredditViewDelegate <NSObject>

- (void)itemWasSelected:(RBRedditItem *)item;
- (void)refreshButtonWasTapped;

@end

@protocol RBSubredditView <NSObject>

@property (nonatomic, weak) id<RBSubredditViewDelegate> delegateForView;

- (void)setItems:(NSArray *)items forSubreddit:(NSString *)feedName;

@end

@interface RBSubredditView : UIView<RBSubredditView>

- (id)initWithFrame:(CGRect)frame navigationItem:(UINavigationItem *)navigationItem;

@end
