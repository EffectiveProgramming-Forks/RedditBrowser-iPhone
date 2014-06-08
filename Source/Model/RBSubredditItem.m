#import "RBSubredditItem.h"

@implementation RBSubredditItem

+ (NSArray *)itemsForJSONFeed:(NSDictionary *)jsonDictionary {
    NSMutableArray *items = [NSMutableArray array];
    NSDictionary *data = jsonDictionary[@"data"];
    NSArray *children = data[@"children"];
    for (NSDictionary *child in children) {
        RBSubredditItem *item = [[RBSubredditItem alloc] init];
        NSDictionary *childData = child[@"data"];
        NSString *title = childData[@"title"];
        item.title = title;
        [items addObject:item];
    }
    return [NSArray arrayWithArray:items];
}

@end
