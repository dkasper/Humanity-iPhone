//
//  ProfileView.m
//  Humanity
//
//  Created by Amir Ghazvinian on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import "ProfileView.h"

@implementation ProfileView

-(void)loadViewContent
{
    self.frame = CGRectMake(0, 0, 320, 100);
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.png"]];
    
    UIImageView *profilePic = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
    [profilePic setImage:[UIImage imageNamed:@"addaphoto.png"]];
    [self addSubview:profilePic];
    [profilePic release];
    
    UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 15, 190, 20)];
    userNameLabel.text = @"Manny Tee";
    userNameLabel.font = [UIFont boldSystemFontOfSize:16.0];
    userNameLabel.backgroundColor = [UIColor clearColor];
    userNameLabel.textColor = [UIColor whiteColor];
    [self addSubview:userNameLabel];
    [userNameLabel release];
    
    UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 35, 190, 15)];
    emailLabel.text = @"mannytee@gmail.com";
    emailLabel.font = [UIFont boldSystemFontOfSize:12.0];
    emailLabel.backgroundColor = [UIColor clearColor];
    emailLabel.textColor = [UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1.0];
    [self addSubview:emailLabel];
    [emailLabel release];
    
}

@end
