//
//  GroupProfileview.m
//  Humanity
//
//  Created by Amir Ghazvinian on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import "GroupProfileView.h"

@implementation GroupProfileView

- (void) loadViewContent
{
    [super loadViewContent];
    
    UILabel *groupNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 15, 210, 20)];
    groupNameLabel.text = @"Pod Name";
    groupNameLabel.font = [UIFont boldSystemFontOfSize:16.0];
    groupNameLabel.backgroundColor = [UIColor clearColor];
    groupNameLabel.textColor = [UIColor whiteColor];
    [self addSubview:groupNameLabel];
    [groupNameLabel release];
    
    UITextField *groupNameField = [[UITextField alloc] initWithFrame:CGRectMake(100, 40, 210, 30)]; 
	groupNameField.borderStyle = UITextBorderStyleRoundedRect;
	groupNameField.font = [UIFont systemFontOfSize:16.0];
	groupNameField.autocorrectionType = UITextAutocorrectionTypeNo;
	groupNameField.keyboardType = UIKeyboardTypeDefault;
	groupNameField.returnKeyType = UIReturnKeyDone;
	groupNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
	groupNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;    
	groupNameField.delegate = self;
    groupNameField.placeholder = @"Give your pod a title.";
	[self addSubview:groupNameField];
	[groupNameField release];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}


@end
