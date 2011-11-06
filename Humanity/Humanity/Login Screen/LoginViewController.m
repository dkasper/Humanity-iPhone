//
//  LoginViewController.m
//  Humanity
//
//  Created by Amir Ghazvinian on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import "LoginViewController.h"
#import "GroupListViewController.h"
#import "AccountManager.h"


@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Humanity";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)processLogin
{
    /*
    GroupListViewController *listViewController = [[[GroupListViewController alloc] init] autorelease];
	
    [self.navigationController pushViewController:listViewController animated:YES];
     */
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    int buttonWidth = 176;
    UIButton *fbConnectButton = [[UIButton alloc] 
                                 initWithFrame:CGRectMake(self.view.bounds.origin.x + self.view.bounds.size.width/2 - buttonWidth/2,
                                                          200, buttonWidth, 31)];    
    [fbConnectButton setImage:[UIImage imageNamed:@"login2.png"] forState:UIControlStateNormal];
    [fbConnectButton addTarget:self action:@selector(connectWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fbConnectButton];
                                 
                                 
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) connectWithFacebook:(id)sender {
    [[AccountManager sharedAccountManager] connectToFacebook];
}


@end
