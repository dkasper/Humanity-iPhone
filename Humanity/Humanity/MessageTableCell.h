//
//  MessageTableCell.h
//  Humanity
//
//  Created by David Kasper on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageTableCellContentView.h"

@interface MessageTableCell : UITableViewCell

@property (nonatomic, retain) MessageTableCellContentView *messageContentView;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSString *time;

@end
