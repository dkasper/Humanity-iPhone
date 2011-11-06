//
//  GroupViewController.h
//  Humanity
//
//  Created by David Kasper on 11/5/11.
//

#import <UIKit/UIKit.h>
#import "MessageListViewController.h"
#import "MemberListViewController.h"
#import "MapViewController.h"
#import "GroupSettingsViewController.h"

@interface GroupViewController : UITabBarController

@property (nonatomic, retain) MessageListViewController *messageListViewController;
@property (nonatomic, retain) MemberListViewController *memberListViewController;
@property (nonatomic, retain) MapViewController *mapViewController;
@property (nonatomic, retain) GroupSettingsViewController *settingsViewController;

@end
