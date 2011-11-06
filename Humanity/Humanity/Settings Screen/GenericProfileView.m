//
//  ProfileView.m
//  Humanity
//
//  Created by Amir Ghazvinian on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import "GenericProfileView.h"

@implementation GenericProfileView

-(void)loadViewContent
{
    self.frame = CGRectMake(0, 0, 320, 96);
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.png"]];
    
    UIImageView *profilePic = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 80, 80)];
    [profilePic setImage:[UIImage imageNamed:@"addaphoto.png"]];
    [self addSubview:profilePic];
    [profilePic release];
    

    
}

@end
