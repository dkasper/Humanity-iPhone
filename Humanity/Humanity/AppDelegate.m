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
    [_loginViewController release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    LoginViewController *loginController = [[LoginViewController alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
    [loginController release];
    
    [self.window setRootViewController:navController];
    [navController release];
                                                
    //IF user logged in already, go directly to the GroupListViewController
    /*
    GroupListViewController *listController = [[GroupListViewController alloc] init];
    
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:listController];
    
	[listController release];
    
    [self.window setRootViewController:navController];
	[navController release];
     */
     
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    _loginViewController = [[LoginViewController alloc] init];
    
    
    [AccountManager sharedAccountManager];
    
    [self.window addSubview:_loginViewController.view];
    [self.window makeKeyAndVisible];
    return YES;
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
