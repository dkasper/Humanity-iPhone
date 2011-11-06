//
//  SettingsViewController.m
//  Humanity
//
//  Created by Amir Ghazvinian on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import "SettingsViewController.h"
#import "EditProfileViewController.h"
#import "UserProfileView.h"
#import "AccountManager.h"

@implementation SettingsViewController

@synthesize settingsTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"Settings";
        self.navigationItem.hidesBackButton = YES;

        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] 
                                       initWithTitle:@"Done" style:UIBarButtonItemStylePlain 
                                       target:self 
                                       action:@selector(doneWithSettings)];
        self.navigationItem.rightBarButtonItem = doneButton;
        [doneButton release];
        
        listOfSettings = [[NSMutableArray alloc] init ];
        
        NSArray *generalSettings = [NSArray arrayWithObjects:@"Mute All", nil];
        NSArray *accountSettings = [NSArray arrayWithObjects:@"Edit Profile", @"Logout", nil];
        NSArray *supportSettings = [NSArray arrayWithObjects:@"Feedback", nil];
        
        [listOfSettings addObject:generalSettings];
        [listOfSettings addObject:accountSettings];
        [listOfSettings addObject:supportSettings];

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)doneWithSettings
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View Helpers
- (void)setTableHeaderView
{
    
    UserProfileView *profileView = [[UserProfileView alloc] init];
    [profileView loadViewContent];
    
    self.settingsTableView.tableHeaderView = profileView;
    [profileView release];
}

#pragma mark - Settings Functions

-(void)sendFeedback
{
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        [controller setSubject:@"Humanity Feedback"];
        [controller setToRecipients:[NSArray arrayWithObjects:@"humanityapp@gmail.com", nil]];
        controller.mailComposeDelegate = self;
        [self presentModalViewController:controller animated:YES];
        [controller release];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error {
	[self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
    [self.settingsTableView deselectRowAtIndexPath:[self.settingsTableView indexPathForSelectedRow] animated:YES];

}

-(void)logout
{
    [[AccountManager sharedAccountManager] logout];
}

-(void)showProfileEditor
{
    EditProfileViewController *editProfileController = [[[EditProfileViewController alloc] init] autorelease];
	
    [self.navigationController pushViewController:editProfileController animated:YES];
}


#pragma mark - Table View Delegate & Data Source Functions

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 1){
        return @"General";
    } else if (section == 2){
        return @"Account";
    } else {
        return @"Support";
    }
}
 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return [listOfSettings count];
}
 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return [[listOfSettings objectAtIndex:section] count];
}

-(void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self tableView:aTableView cellForRowAtIndexPath:indexPath];
    if([cell.textLabel.text isEqualToString:@"Feedback"]){
        [self sendFeedback];
    } else if([cell.textLabel.text isEqualToString:@"Logout"]){
        [self logout];
    } else if([cell.textLabel.text isEqualToString:@"Edit Profile"]){
        [self showProfileEditor];
    }
}
 
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
     static NSString *CellIdentifier = @"UITableViewCell";
 
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
     if (cell == nil) {
 
         cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
 
     }
 
     cell.textLabel.text = [[listOfSettings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
     if([cell.textLabel.text isEqualToString:@"Logout"]){
         cell.accessoryType = UITableViewCellAccessoryNone;
     } else {
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     }
     return cell;
 
 }
 
#pragma mark - View lifecycle


 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
     [super loadView];
     settingsTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped] autorelease];
     settingsTableView.dataSource = self;
     settingsTableView.delegate = self;
     settingsTableView.backgroundColor = [UIColor colorWithRed:197.0/255 green:203.0/255 blue:213.0/255 alpha:1.0];
     //settingsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.png"]];
     [self setTableHeaderView];
 
     [self.view addSubview:settingsTableView];

     self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
 }
 

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
}
 */


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.settingsTableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) dealloc
{
    [super dealloc];
    
    [settingsTableView release];
    
}

@end
