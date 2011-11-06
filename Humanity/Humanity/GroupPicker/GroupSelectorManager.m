//
//  GroupSelectorManager.m
//  Social
//
//  Created by Ammon on 11/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GroupSelectorManager.h"

@implementation GroupSelectorManager
@synthesize video = _video;


- (id) init {
	if (!(self = [super init]))
		return nil;
	
	_contactFetcher = [[ContactFetchManager alloc] initWithDelegate:self];	
 	
	return self;		
}

- (void) showGroupView:(UINavigationController *)navCon {
	[_contactFetcher fetchContacts];
	[_shareGroupSelectorController release];
	_shareGroupSelectorController = [[SCGroupSelectorTableViewController alloc] initWithItems:_contactFetcher.shareItems];
	_shareGroupSelectorController.title = NSLocalizedString(@"Create Pod", nil);
	_shareGroupSelectorController.delegate = self;
	[navCon pushViewController:_shareGroupSelectorController animated:YES];	
}

- (void) dealloc {
	[_video release];
	[_contactFetcher release];
	[_shareGroupSelectorController release];
	[super dealloc];
}

- (void) contactFetcherDidFetchContacts:(ContactFetchManager *)fetch {
    if (_shareGroupSelectorController) {
    	_shareGroupSelectorController.items = fetch.shareItems;
    }
}

- (void) groupSelectorDidClose:(SCGroupSelectorTableViewController *)groupSelector doneClicked:(BOOL)done {
	NSLog(@"groupSelectorDidClose");
	if (done) {
		//create pod		
	}
}

@end
