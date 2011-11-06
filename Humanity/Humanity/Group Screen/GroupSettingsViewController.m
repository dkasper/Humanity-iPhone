//
//  SettingsViewController.m
//  Humanity
//
//  Created by David Kasper on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import "GroupSettingsViewController.h"
#import "GroupProfileView.h"

@implementation GroupSettingsViewController

@synthesize settingsTableView;

-(id)init {
    self = [super init];
    if(self) {
        self.title = @"More";
        self.tabBarItem.image = [UIImage imageNamed:@"settings.png"];
                
        listOfSettings = [[NSMutableArray alloc] init ];
        
        NSArray *alertSettings = [NSArray arrayWithObjects:@"Alerts", nil];
        NSArray *leaveSettings = [NSArray arrayWithObjects:@"Leave Pod", nil];
        
        [listOfSettings addObject:alertSettings];
        [listOfSettings addObject:leaveSettings];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View Helpers
- (void)setTableHeaderView
{
    
    GroupProfileView *profileView = [[GroupProfileView alloc] init];
    [profileView loadViewContent];
    
    self.settingsTableView.tableHeaderView = profileView;
    [profileView release];
}


#pragma mark - Table View Delegate & Data Source Functions


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [listOfSettings count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[listOfSettings objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        
    }
    
    cell.textLabel.text = [[listOfSettings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if([cell.textLabel.text isEqualToString:@"Time"]){
        cell.detailTextLabel.text = @"Set event time";
    } else if ([cell.textLabel.text isEqualToString:@"Location"]){
        cell.detailTextLabel.text = @"Set event location";
    } else if ([cell.textLabel.text isEqualToString:@"Alerts"]){
        cell.detailTextLabel.text = @"On";
    } else {
        cell.detailTextLabel.text = @"";
    }
    if(indexPath.section == 0){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
    
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
    
    settingsTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped] autorelease];
    settingsTableView.dataSource = self;
    settingsTableView.delegate = self;
    settingsTableView.backgroundColor = [UIColor colorWithRed:197.0/255 green:203.0/255 blue:213.0/255 alpha:1.0];
    //settingsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.png"]];
    [self setTableHeaderView];
    
    [self.view addSubview:settingsTableView];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    
}


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