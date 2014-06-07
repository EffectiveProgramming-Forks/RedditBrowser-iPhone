#import <Foundation/Foundation.h>

@protocol RBSubredditModelDelegate <NSObject>

@end

@interface RBSubredditModel : NSObject

@property (nonatomic, weak) id<RBSubredditModelDelegate> delegateForModel;

@end
