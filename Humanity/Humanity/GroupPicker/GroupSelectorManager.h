//
//  GroupSelectorManager.h
//  Social
//
//  Created by Ammon on 11/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContactFetchManager.h"
#import "SCGroupSelectorTableViewController.h"

@class SCVideo;
@interface GroupSelectorManager : NSObject<SCContactFetcherDelegate, SCGroupSelectorTableViewControllerDelegate> {
	SCVideo *_video;
	ContactFetchManager *_contactFetcher;
	SCGroupSelectorTableViewController *_shareGroupSelectorController;
}

- (void) showGroupView:(UINavigationController *)navCon;

@property (nonatomic, retain) SCVideo *video; 
@end
