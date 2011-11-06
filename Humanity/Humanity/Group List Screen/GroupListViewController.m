//
//  GroupListViewController.m
//  Humanity
//
//  Created by Amir Ghazvinian on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import "GroupListViewController.h"
#import "GroupViewController.h"

@implementation GroupListViewController

@synthesize groupListTableView;
@synthesize temp;

- (id)init
{
	self = [super initWithNibName:nil bundle:nil];
	
	if(self){
		self.title = @"Humanity";
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                      target:self 
                                      action:@selector(addPod)];
        self.navigationItem.rightBarButtonItem = addButton;
        [addButton release];
        
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
                                           target:self 
                                           action:@selector(addPod)];
        self.navigationItem.leftBarButtonItem = settingsButton;
        [settingsButton release];
        
        temp = [[NSMutableArray alloc] init];
        [temp addObject:@"Object 1"];
        [temp addObject:@"Object 2"];
	}
    
	return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)addPod
{
    NSLog(@"Hello");
}

#pragma mark - Table View Delegate & Data Source Functions

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Pods";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [temp count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"GroupListMessageCell";
    
    GroupListMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[[GroupListMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
    }
    
    [cell setMessageCellGroup:@"Some Pod" message:@"Hello"];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupViewController *vc = [[GroupViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

#pragma mark - View Helpers

- (void)setTableHeaderView
{
    UILabel *startConvoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 20)];
    
    startConvoLabel.textColor = [UIColor whiteColor];
    
    startConvoLabel.backgroundColor = [UIColor clearColor];
    startConvoLabel.font = [UIFont systemFontOfSize:14.0];
    startConvoLabel.textAlignment = UITextAlignmentCenter;
    
    startConvoLabel.text = @"Start a conversation.";
    
    UIView *listHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    listHeaderView.backgroundColor = [UIColor blackColor];
    
    [listHeaderView addSubview:startConvoLabel];
    [startConvoLabel release];
    
    self.groupListTableView.tableHeaderView = listHeaderView;
    [listHeaderView release];
}

-(void)setFooterView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 370, 320, 50)];
    
    footerView.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:footerView];
    [footerView release];
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
    
    groupListTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 370) style:UITableViewStylePlain] autorelease];
    groupListTableView.dataSource = self;
    groupListTableView.delegate = self;
    
    [self setTableHeaderView];
    
    [self.view addSubview:groupListTableView];
    
    [self setFooterView];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.groupListTableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) dealloc
{
    [super dealloc];
    
    [groupListTableView release];
    [temp release];
    
}

@end