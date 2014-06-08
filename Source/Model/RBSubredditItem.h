#import <Foundation/Foundation.h>

@interface RBSubredditItem : NSObject

@property (nonatomic) NSString *subreddit;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *URIAsString;

+ (NSArray *)itemsForJSONFeed:(NSDictionary *)jsonDictionary;

@end
