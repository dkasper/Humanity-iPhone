///
//  SettingsViewController.h
//  Humanity
//
//  Created by Amir Ghazvinian on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *settingsTableView;
    NSMutableArray *listOfSettings;
}

@property (retain, nonatomic) UITableView *settingsTableView;


@end
