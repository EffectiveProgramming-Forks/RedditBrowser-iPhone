#import "RedditItemEntity+RBExtensions.h"

@implementation RedditItemEntity (RBExtensions)

- (NSString *)description {
    return [NSString stringWithFormat:@"{ title: %@, author: %@, permalink: %@, subreddit: %@, uuid: %@ }",
            self.title,
            self.author,
            self.permalink,
            self.subreddit,
            self.uuid];
}

@end
