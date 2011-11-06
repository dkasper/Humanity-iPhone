//
//  MemberListViewController.m
//  Humanity
//
//  Created by David Kasper on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import "MemberListViewController.h"

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
    
    self.view = view;
    [view release];
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
