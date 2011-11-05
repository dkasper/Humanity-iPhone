//
//  MessageListViewController.m
//  Humanity
//
//  Created by David Kasper on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import "MessageListViewController.h"
#import "MessageTableCell.h"

#define MESSAGE_VIEW_HEIGHT 65

@implementation MessageListViewController

@synthesize messageTextView = _messageTextView;
@synthesize messageTableView = _messageTableView;
@synthesize toggleTextViewButton = _toggleTextViewButton;
@synthesize messages = _messages;

static NSString *cellIdentifier = @"MessageCell";

-(id)init {
    self = [super init];
    if(self) {
        self.title = @"Messages";
        self.tabBarItem.image = [UIImage imageNamed:@"messages.png"];
        self.messages = [[NSMutableArray alloc] init];
        [self.messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"David Kasper", @"name", @"Hello World Hello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello World", @"body", nil]];
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
    
    self.messageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, MESSAGE_VIEW_HEIGHT, view.bounds.size.width, view.bounds.size.height - MESSAGE_VIEW_HEIGHT) style:UITableViewStylePlain];
    self.messageTableView.delegate = self;
    self.messageTableView.dataSource = self;
    [view addSubview:self.messageTableView];
    
    self.messageTextView = [[MessageTextView alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, MESSAGE_VIEW_HEIGHT)];
    [view addSubview:self.messageTextView];
    
    self.toggleTextViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.toggleTextViewButton.frame = self.messageTextView.frame;
    [self.toggleTextViewButton addTarget:self action:@selector(toggleTextView:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.toggleTextViewButton];
    
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
    return [self.messages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[[self.messages objectAtIndex:indexPath.row] objectForKey:@"body"] sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(280, 9999) lineBreakMode:UILineBreakModeWordWrap].height + 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageTableCell *cell = (MessageTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[MessageTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.name = [[self.messages objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.body = [[self.messages objectAtIndex:indexPath.row] objectForKey:@"body"];

    return cell;
}

-(void)toggleTextView:(id)sender {
    if(self.messageTextView.enabled) {
        [self.messageTextView contract];
        CGRect newFrame = self.toggleTextViewButton.frame;
        newFrame.origin.y = newFrame.origin.y - MESSAGE_VIEW_HEIGHT;
        self.toggleTextViewButton.frame = newFrame;
    } else {
        [self.messageTextView expand];
        CGRect newFrame = self.toggleTextViewButton.frame;
        newFrame.origin.y = newFrame.origin.y + MESSAGE_VIEW_HEIGHT;
        self.toggleTextViewButton.frame = newFrame;
    }
}

@end
