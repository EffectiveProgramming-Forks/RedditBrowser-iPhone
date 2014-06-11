#import "RBRedditItem.h"

@implementation RBRedditItem

+ (NSArray *)itemsForJSONFeed:(NSDictionary *)jsonDictionary {
    NSMutableArray *items = [NSMutableArray array];
    NSDictionary *data = jsonDictionary[@"data"];
    NSArray *children = data[@"children"];
    for (NSDictionary *child in children) {
        RBRedditItem *item = [[RBRedditItem alloc] init];
        NSDictionary *childData = child[@"data"];
        item.title = childData[@"title"];
        item.permalink = childData[@"permalink"];
        item.author = childData[@"author"];
        item.subreddit = childData[@"subreddit"];
        [items addObject:item];
    }
    return [NSArray arrayWithArray:items];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{ title: %@, author: %@, permalink: %@, subreddit: %@, uuid: %@ }",
            self.title,
            self.author,
            self.permalink,
            self.subreddit,
            self.uuid];
}

@end
