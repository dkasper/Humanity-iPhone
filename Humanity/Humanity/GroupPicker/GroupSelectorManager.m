//
//  GroupSelectorManager.m
//  Social
//
//  Created by Ammon on 11/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GroupSelectorManager.h"
#import "SCAPIRequestController.h"
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequestAdditions.h"
#import "ASIFormDataRequest.h"
#import "AccountManager.h"

@implementation GroupSelectorManager
@synthesize pod = _pod;


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
	if (_pod) {
        _shareGroupSelectorController.displayAddPeopleButton = YES;
	    _shareGroupSelectorController.title = NSLocalizedString(@"Add People", nil);
    } else {
        _shareGroupSelectorController.title = NSLocalizedString(@"Create Pod", nil);    
    }
	
	_shareGroupSelectorController.delegate = self;
	[navCon pushViewController:_shareGroupSelectorController animated:YES];	
}

- (void) dealloc {
	[_pod release];
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
	if (done && groupSelector.selectedItems.count) {
		if (!_pod) {
		    ASIFormDataRequest *request = [ASIFormDataRequest apiRequestWithAPI:@"messages" target:self selectorFormat:@"podCreateRequest"];
            request.requestMethod = POST;
            [request setPostValue:[AccountManager sharedAccountManager].accessToken forKey:@"token"];
            [request setPostValue:groupSelector.message forKey:@"content"];
            [request setPostValue:[groupSelector titleForSelectedGroupWithFont:[UIFont boldSystemFontOfSize:18.0] constrainedToWidth:320.] forKey:@"new_group[name]"];
        
            for (NSDictionary *d in groupSelector.selectedItems) {
                if ([[d objectForKey:@"type"] isEqual:@"humanity"]) {
                    [request setPostValue:[d objectForKey:@"id"] forKey:@"new_group[user_ids][]"];    
                } else if ([[d objectForKey:@"type"] isEqual:@"phone"]) {
                    [request setPostValue:[d objectForKey:@"id"] forKey:@"new_group[phone_numbers][][number]"];
                    if ([d objectForKey:@"first_name"])
                        [request setPostValue:[d objectForKey:@"first_name"] forKey:@"new_group[phone_numbers][][first_name]"];
                    if ([d objectForKey:@"last_name"])
                        [request setPostValue:[d objectForKey:@"last_name"] forKey:@"new_group[phone_numbers][][last_name]"];
                } else if ([[d objectForKey:@"type"] isEqual:@"email"]) {
                    [request setPostValue:[d objectForKey:@"id"] forKey:@"new_group[emails][][email]"];
                    if ([d objectForKey:@"first_name"])
                        [request setPostValue:[d objectForKey:@"first_name"] forKey:@"new_group[emails][][first_name]"];
                    if ([d objectForKey:@"last_name"])
                        [request setPostValue:[d objectForKey:@"last_name"] forKey:@"new_group[emails][][last_name]"];
                }
            }    
            [[SCAPIRequestController sharedController] addRequest:request];
        } else {
            //TODO: add people to pod
            
        }		
	}
}

- (void) podCreateRequestDidFail:(ASIHTTPRequest *) request {
	NSLog(@"podCreateRequestDidFail (%d) %@", [request responseStatusCode], [request responseString]);
	if (!shouldRetryFromStatusCode(request.responseStatusCode) || [[request.userInfo objectForKey:@"retry_count"] intValue] >= 3) {
		return;
	}
	[[SCAPIRequestController sharedController] retryRequest:request];
}


- (void) podCreateRequestDidFinish:(ASIHTTPRequest *) request {
	NSLog(@"podCreateRequestDidFinish (%d) %@", [request responseStatusCode], [request responseString]);
	if (!statusCodeIsSuccess(request.responseStatusCode)) {
		[self podCreateRequestDidFail:request];
		return;
	}
}

@end
