#import "RBSubredditView.h"
#import "RBSubredditTableViewCell.h"
#import "RBRedditItem.h"

@interface RBSubredditView () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *subRedditItems;
@property (nonatomic) NSString *feedName;

@end

@implementation RBSubredditView

@synthesize delegateForView;

static NSString *kRBSubredditViewCellReuseIdentifier = @"RBSubredditViewCellReuseIdentifier";

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        _tableView.rowHeight = [RBSubredditTableViewCell heightForRow];
        _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [_tableView registerClass:[RBSubredditTableViewCell class] forCellReuseIdentifier:kRBSubredditViewCellReuseIdentifier];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
    }
    return self;
}

#pragma mark - API

- (void)setItems:(NSArray *)items forFeedName:(NSString *)feedName {
    _feedName = feedName;
    _subRedditItems = items;
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource/UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Listen To This";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_subRedditItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:kRBSubredditViewCellReuseIdentifier];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    RBRedditItem *item = _subRedditItems[indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = @"It's all about the little things";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
