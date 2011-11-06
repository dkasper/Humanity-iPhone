//
//  AppDelegate.h
//  Humanity
//
//  Created by David Kasper on 11/5/11.
//

#import <UIKit/UIKit.h>

@class Facebook;
@class LoginViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UINavigationController *_rootNavController;  
    LoginViewController *_loginViewController;

}

@property (strong, nonatomic) UIWindow *window;


@end
