#import "RBAppDelegate.h"
#import "RBSubredditViewController.h"
#import "RBPersistenceServiceFactory.h"

@implementation RBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [RBPersistenceServiceFactory setup];
    RBSubredditViewController *subredditViewController = [[RBSubredditViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:subredditViewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [RBPersistenceServiceFactory teardown];
}

@end
