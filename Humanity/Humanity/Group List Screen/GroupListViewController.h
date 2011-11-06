//
//  GroupListViewController.h
//  Humanity
//
//  Created by Amir Ghazvinian on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupListMessageCell.h"

@interface GroupListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *groupListTableView;
    NSMutableArray *temp;
}

@property (retain, nonatomic) UITableView *groupListTableView;

@property (retain) NSArray *temp;

@end
