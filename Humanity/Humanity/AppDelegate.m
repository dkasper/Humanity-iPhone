//
//  AppDelegate.m
//  Humanity
//
//  Created by David Kasper on 11/5/11.

#import "AppDelegate.h"
#import "FBConnect.h"
#import "LoginViewController.h"
#import "AccountManager.h"
#import "GroupListViewController.h"
#import "LoginViewController.h"
#import "GroupViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_rootNavController release];
    [_loginViewController release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[AccountManager sharedAccountManager] loginFromKeychain];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    // Override point for customization after application launch.
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    GroupListViewController *listController = [[GroupListViewController alloc] init];
    _rootNavController = [[UINavigationController alloc] initWithRootViewController:listController];    
    [listController release];    
    [self.window setRootViewController:_rootNavController];
    
    
    if (![AccountManager sharedAccountManager].loggedIn) {    
        [self showLoginViewAnimated:NO];
    }
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) showLoginViewAnimated:(BOOL)animated {
    if (_loginViewController) return; 
    _loginViewController = [[LoginViewController alloc] init];
    UINavigationController *loginNavController = [[LoginViewController alloc] initWithRootViewController:_loginViewController];
    [_rootNavController presentModalViewController:loginNavController animated:animated];
    [loginNavController release];
}

- (void) removeLoginViewAnimated:(BOOL)animated {
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}
     

- (BOOL) application:(UIApplication *) application handleOpenURL:(NSURL *) url {
	NSLog(@"App opened with url %@", url.absoluteString);
	if ([url.scheme hasPrefix:@"fb"]) {
		
		[[AccountManager sharedAccountManager].facebookSession handleOpenURL:url];
    }
    return YES;
}

@end
