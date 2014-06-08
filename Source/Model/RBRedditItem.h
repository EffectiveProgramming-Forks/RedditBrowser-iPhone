#import <Foundation/Foundation.h>

@interface RBRedditItem : NSObject

@property (nonatomic) NSString *subreddit;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *URIAsString;

+ (NSArray *)itemsForJSONFeed:(NSDictionary *)jsonDictionary;

@end
