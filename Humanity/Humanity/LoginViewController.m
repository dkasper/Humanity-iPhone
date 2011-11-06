//
//  LoginViewController.m
//  Humanity
//
//  Created by Ammon on 11/5/11.
//  Copyright (c) 2011 Yobongo. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "AccountManager.h"


@implementation LoginViewController

- (void) loadView {
	UIView *view = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	view.backgroundColor = [UIColor redColor];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Connect with Facebook" forState:UIControlStateNormal];
	[button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(connectWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:16.];
	[button sizeToFit]; 
    CGRect frame = button.frame;
    frame.origin.x = [UIScreen mainScreen].bounds.size.width / 2. - frame.size.width / 2;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height / 2. - frame.size.height / 2;
    button.frame = frame;
    
    [view addSubview:button];
    
    self.view = view;
	[view release];
}


- (void) viewDidLoad {	
	
}

- (void) connectWithFacebook:(id)sender {
    [[AccountManager sharedAccountManager] connectToFacebook];
}


@end
