//
//  MemberListViewController.h
//  Humanity
//
//  Created by David Kasper on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSMutableArray *members;
@property (nonatomic, retain) UITableView *memberTableView;

@end
