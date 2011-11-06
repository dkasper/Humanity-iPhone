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
   
    LoginViewController *_loginViewController;
}

@property (strong, nonatomic) UIWindow *window;


@end
