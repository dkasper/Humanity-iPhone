//
//  GroupListMessageCell.m
//  Humanity
//
//  Created by Amir Ghazvinian on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import "GroupListMessageCell.h"

@implementation GroupListMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        groupNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:groupNameLabel];
		[groupNameLabel release];
		
		messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:messageLabel];
		[messageLabel release];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:timeLabel];
        [timeLabel release];

    }
    return self;
}

-(void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect groupNameFrame = CGRectMake(50, 8, 195, 15);
	groupNameLabel.frame = groupNameFrame;
	groupNameLabel.font = [UIFont boldSystemFontOfSize:14.0];
	groupNameLabel.numberOfLines = 0;
	groupNameLabel.lineBreakMode = UILineBreakModeWordWrap;
	groupNameLabel.backgroundColor = [UIColor clearColor];
	
    CGRect messageFrame = CGRectMake(50, 25, 195, 13);
    
	messageLabel.frame = messageFrame;
	messageLabel.font = [UIFont boldSystemFontOfSize:12.0];
	messageLabel.backgroundColor = [UIColor clearColor];
	messageLabel.textAlignment = UITextAlignmentLeft;
	
}

-(void)setMessageCellGroup:(NSString *)groupName 
                   message:(NSString *)message
{
    groupNameLabel.text = groupName;
    messageLabel.text = message;
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
