//
//  SettingsViewController.h
//  Humanity
//
//  Created by Amir Ghazvinian on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate> {
    UITableView *settingsTableView;
    NSMutableArray *listOfSettings;
}

@property (retain, nonatomic) UITableView *settingsTableView;


@end
