//
//  MemberListViewController.h
//  Humanity
//
//  Created by David Kasper on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GroupSelectorManager;
@interface MemberListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    UIView *_footerView;
    GroupSelectorManager *_groupSelector;
}


@property (nonatomic, retain) NSMutableArray *members;
@property (nonatomic, retain) UITableView *memberTableView;

@end
