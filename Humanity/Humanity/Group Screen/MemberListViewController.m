//
//  MemberListViewController.m
//  Humanity
//
//  Created by David Kasper on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import "MemberListViewController.h"
#import "GroupSelectorManager.h"

@implementation MemberListViewController

@synthesize members = _members;
@synthesize memberTableView = _memberTableView;

-(id)init {
    self = [super init];
    if(self) {
        self.title = @"Members";
                self.tabBarItem.image = [UIImage imageNamed:@"members.png"];
        self.members = [[NSMutableArray alloc] init];
        [self.members addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"David Kasper", @"name", @"dkasper@gmail.com", @"email", nil]];
        [self.members addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Joe NoEmail", @"name", nil]];
    }
    return self;
}

- (void) dealloc {
    [_footerView release];
    [_groupSelector release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.memberTableView = [[UITableView alloc] initWithFrame:view.bounds style:UITableViewStylePlain];
    self.memberTableView.delegate = self;
    self.memberTableView.dataSource = self;
    
    [view addSubview:self.memberTableView];
    
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, view.bounds.size.height - 44. - 20. - 44. - 49., 320, 44.)];
    _footerView.backgroundColor = [UIColor grayColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Add People" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    button.backgroundColor = [UIColor colorWithRed:30./255.0 green:128/255.0 blue:20/255.0 alpha:1.0];
    [button addTarget:self action:@selector(addPeople:) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:button];
    button.frame = CGRectMake(0, 0, 200, 35);
    CGRect frame = button.frame;
    frame.origin.x = _footerView.frame.size.width / 2. - frame.size.width / 2.;
    frame.origin.y = _footerView.frame.size.height / 2. - frame.size.height / 2.;
    button.frame = frame;
    
    [view addSubview:_footerView];
    
    self.view = view;
    [view release];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

}

- (void) addPeople:(id)sender{
    if (!_groupSelector) {
        _groupSelector = [[GroupSelectorManager alloc] init];
        //TODO: set a dictionary with info on the pod
        _groupSelector.pod = [NSDictionary dictionary];
    }
    [_groupSelector showGroupView:self.navigationController]; 
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table View methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.members count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"memberCell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"memberCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [[self.members objectAtIndex:indexPath.row] objectForKey:@"name"];
    NSString *email = [[self.members objectAtIndex:indexPath.row] objectForKey:@"email"];
    if(email) {
        cell.detailTextLabel.text = email;
    }
    
    return cell;
}

@end
