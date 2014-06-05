#import "RBSubredditTableViewCell.h"

@implementation RBSubredditTableViewCell

+ (CGFloat)heightForRow {
    return 64.0;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

@end
