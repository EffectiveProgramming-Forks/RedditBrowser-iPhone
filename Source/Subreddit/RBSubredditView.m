#import "RBSubredditView.h"
#import "RBSubredditTableViewCell.h"

@interface RBSubredditView () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) UITableView *tableView;

@end

@implementation RBSubredditView

@synthesize delegateForView;

static NSString *kRBSubredditViewCellReuseIdentifier = @"RBSubredditViewCellReuseIdentifier";

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:frame];
        _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [_tableView registerClass:[RBSubredditTableViewCell class] forCellReuseIdentifier:kRBSubredditViewCellReuseIdentifier];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return self;
}

#pragma mark - UITableViewDataSource/UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:kRBSubredditViewCellReuseIdentifier];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = @"Funny Pictures";
    cell.detailTextLabel.text = @"Playing music";
}

@end
