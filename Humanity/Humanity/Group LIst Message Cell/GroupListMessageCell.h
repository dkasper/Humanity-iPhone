//
//  GroupListMessageCell.h
//  Humanity
//
//  Created by Amir Ghazvinian on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupListMessageCell : UITableViewCell {
    UILabel *groupNameLabel;
    UILabel *messageLabel;
    UILabel *timeLabel;
    //UIImage *userImage;
}

-(void)setMessageCellGroup:(NSString *)groupName 
                message:(NSString *)message;

@end
