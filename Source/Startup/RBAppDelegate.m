#import "RBAppDelegate.h"
#import "RBSubredditViewController.h"

@implementation RBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    RBSubredditViewController *subredditViewController = [[RBSubredditViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:subredditViewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
