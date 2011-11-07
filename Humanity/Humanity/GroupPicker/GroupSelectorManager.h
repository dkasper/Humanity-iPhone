//
//  GroupSelectorManager.h
//  Social
//
//  Created by Ammon on 11/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContactFetchManager.h"
#import "SCGroupSelectorTableViewController.h"

@interface GroupSelectorManager : NSObject<SCContactFetcherDelegate, SCGroupSelectorTableViewControllerDelegate> {
	ContactFetchManager *_contactFetcher;
	SCGroupSelectorTableViewController *_shareGroupSelectorController;
    NSDictionary *_pod;
}

- (void) showGroupView:(UINavigationController *)navCon;
@property(nonatomic, retain) NSDictionary *pod;

@end
