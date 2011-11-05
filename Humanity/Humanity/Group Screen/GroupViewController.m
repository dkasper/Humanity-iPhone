//
//  GroupViewController.m
//  Humanity
//
//  Created by David Kasper on 11/5/11.
//

#import "GroupViewController.h"

@implementation GroupViewController

@synthesize messageListViewController = _messageListViewController;
@synthesize memberListViewController = _memberListViewController;
@synthesize mapViewController = _mapViewController;
@synthesize settingsViewController = _settingsViewController;

-(id) init {
    self = [super init];
    if(self) {
        self.memberListViewController = [[MemberListViewController alloc] init];
        self.messageListViewController = [[MessageListViewController alloc] init];
        self.mapViewController = [[MapViewController alloc] init];
        self.settingsViewController = [[SettingsViewController alloc] init];
    }
    return self;
}

-(NSArray *)viewControllers {
    return [NSArray arrayWithObjects:self.messageListViewController, self.memberListViewController, self.mapViewController, self.settingsViewController, nil];
}

@end
