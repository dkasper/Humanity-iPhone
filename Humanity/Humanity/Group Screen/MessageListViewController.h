//
//  MessageListViewController.h
//  Humanity
//
//  Created by David Kasper on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageTextView.h"

@interface MessageListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) MessageTextView *messageTextView;
@property (nonatomic, retain) UITableView *messageTableView;
@property (nonatomic, retain) UIButton *toggleTextViewButton;
@property (nonatomic, retain) NSMutableArray *messages;

@end
