#import "RBRedditItem.h"

@implementation RBRedditItem

+ (NSArray *)itemsForJSONFeed:(NSDictionary *)jsonDictionary {
    NSMutableArray *items = [NSMutableArray array];
    NSDictionary *data = jsonDictionary[@"data"];
    NSArray *children = data[@"children"];
    for (NSDictionary *child in children) {
        RBRedditItem *item = [[RBRedditItem alloc] init];
        NSDictionary *childData = child[@"data"];
        NSString *title = childData[@"title"];
        item.title = title;
        [items addObject:item];
    }
    return [NSArray arrayWithArray:items];
}

@end
