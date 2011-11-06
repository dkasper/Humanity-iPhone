//
//  ContactFetchManager.m
//  Social
//
//  Created by Ammon on 11/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContactFetchManager.h"
#import "SCCachedHTTPManager.h"
#import "SCAddressBook.h"
#import "ASIHTTPRequestAdditions.h"

static NSMutableArray *addressBookItems = nil;

@implementation ContactFetchManager
@synthesize shareItems = _shareItems;

- (id) initWithDelegate:(id<SCContactFetcherDelegate>)delegate {
	if (!(self = [super init]))
		return nil;
	
    _delegate = delegate;
    if (!addressBookItems) {
	    addressBookItems = [[NSMutableArray alloc] init];
    	for (NSDictionary *person in [[SCAddressBook sharedAddressBook] people]) {
    		NSString *fname = [[person objectForKey:@"name"] objectForKey:@"first"];
    		NSString *lname = [[person objectForKey:@"name"] objectForKey:@"last"];
    		NSString *name = nil;
    		if (fname.length && lname.length) {
                name = [NSString stringWithFormat:@"%@ %@", fname, lname];
    		} else if (fname.length) {
                name = fname;
    		} else if (lname.length) {
    	        name = lname;
    	    } else {
                continue; 
    	    }
			
    		for (NSString *number in [[person objectForKey:@"phone_number"] allValues]) {
    			NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    			[item setObject:name forKey:@"display_name"];
                if (fname.length) [item setObject:fname forKey:@"first_name"];
    			if (lname.length) [item setObject:lname forKey:@"last_name"];
                [item setObject:number forKey:@"id"];
    			[item setObject:@"phone" forKey:@"type"];
    			[item setObject:[NSArray arrayWithObjects:number, lname, nil] forKey:@"match_keys"];
    			[addressBookItems addObject:item];
    			[item release];
			
    		}
		
    		for (NSString *email in [[person objectForKey:@"email"] allValues]) {
    			NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    			[item setObject:name forKey:@"display_name"];
    			if (fname.length) [item setObject:fname forKey:@"first_name"];
    			if (lname.length) [item setObject:lname forKey:@"last_name"];	
    			[item setObject:email forKey:@"id"];
    			[item setObject:@"email" forKey:@"type"];
    			[item setObject:[NSArray arrayWithObjects:email, lname, nil] forKey:@"match_keys"];
    			[addressBookItems addObject:item];
    			[item release];
    		}
			 
    	}
	}
	_shareItems = [addressBookItems retain];
	
	return self; 
}

- (void) dealloc {
	[[SCCachedHTTPManager sharedCachedHTTPManager] removeDelegate:self];
	[super dealloc];
}

- (void) fetchContacts {
	//NSString *path = [ASIHTTPRequest pathWithApi:[NSString stringWithFormat:@"contacts.json?auth_token=%@", [AccountManager sharedAccountManager].railsToken]];
	//[[SCCachedHTTPManager sharedCachedHTTPManager] fetchObjectAtURL:[NSURL URLWithString:path] withCacheTime:5. andDelegate:self userInfo:nil];
}

- (NSMutableDictionary *) nameDictionaryFromName:(NSString *)name {
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    [item setObject:name forKey:@"display_name"];
    NSRange r = [name rangeOfString:@" "];
    if (r.location == NSNotFound) return item;
    [item setObject:[name substringToIndex:r.location] forKey:@"first_name"];
    [item setObject:[name substringFromIndex:r.location + 1] forKey:@"last_name"];
    return item;
}

- (void) cachedHTTPJSONObjectAvailable:(id)object returnCode:(NSUInteger)returnCode userInfo:(id)userInfo {
    /*
    if (![object isKindOfClass:[NSDictionary class]]) {
        return; 
    }
    
	[_shareItems release];
	_shareItems = [[NSMutableArray alloc] init];
	
    [_tagItems release];
    _tagItems = [[NSMutableArray alloc] init];
	
    BOOL tagFB = [[object safeObjectForKey:@"tag_system"] containsObject:@"facebook"];
	BOOL shareFB = [[object safeObjectForKey:@"share_system"] containsObject:@"facebook"];
	
	for (NSArray *namevalue in [object safeObjectForKey:@"facebook"]) {
		if (namevalue.count != 2) continue;
		NSMutableDictionary *item = [self nameDictionaryFromName:[namevalue objectAtIndex:1]];
		[item setObject:[namevalue objectAtIndex:0] forKey:@"id"];	
		[item setObject:@"facebook" forKey:@"type"];
		NSArray *parts = [[namevalue objectAtIndex:1] componentsSeparatedByString:@" "];
		if (parts.count) {
			[item setObject:[NSArray arrayWithObject:[parts objectAtIndex:parts.count - 1]] forKey:@"match_keys"];
		}
		if(shareFB) [_shareItems addObject:item];
        if(tagFB) [_tagItems addObject:item];
	}
	
	BOOL tagTwitter = [[object safeObjectForKey:@"tag_system"] containsObject:@"twitter"];
	BOOL shareTwitter = [[object safeObjectForKey:@"share_system"] containsObject:@"twitter"];
	for (NSArray *namevalue in [object safeObjectForKey:@"twitter"]) {
		if (namevalue.count != 2) continue;
		NSMutableDictionary *item = [self nameDictionaryFromName:[namevalue objectAtIndex:1]];
		[item setObject:[namevalue objectAtIndex:0] forKey:@"id"];
		[item setObject:[namevalue objectAtIndex:1] forKey:@"display_name"];
		[item setObject:@"twitter" forKey:@"type"];
		NSMutableArray *matchKeys = [NSMutableArray arrayWithObject:[namevalue objectAtIndex:0]];
		NSArray *parts = [[namevalue objectAtIndex:1] componentsSeparatedByString:@" "];
		if (parts.count) {
			[matchKeys addObject:[parts objectAtIndex:parts.count - 1]];
		}
		[item setObject:matchKeys forKey:@"match_keys"];
		if(shareTwitter) [_shareItems addObject:item];
		if(tagTwitter) [_tagItems addObject:item];
	}
	
	BOOL tagSocialcam = [[object objectForKey:@"tag_system"] containsObject:@"socialcam"];
	BOOL shareSocialcam = [[object safeObjectForKey:@"share_system"] containsObject:@"socialcam"];
	for (NSArray *namevalue in [object safeObjectForKey:@"socialcam"]) {
		if (namevalue.count != 2) continue;
		NSMutableDictionary *item = [self nameDictionaryFromName:[namevalue objectAtIndex:1]];
		[item setObject:[namevalue objectAtIndex:0] forKey:@"id"];
		[item setObject:[namevalue objectAtIndex:1] forKey:@"display_name"];
		[item setObject:@"socialcam" forKey:@"type"];
		NSArray *parts = [[namevalue objectAtIndex:1] componentsSeparatedByString:@" "];
		if (parts.count) {
			[item setObject:[NSArray arrayWithObject:[parts objectAtIndex:parts.count - 1]] forKey:@"match_keys"];
		}
		if(shareSocialcam) [_shareItems addObject:item];
		if(tagSocialcam) [_tagItems addObject:item];
	}
	
	[_shareItems addObjectsFromArray:addressBookItems];
	
    [_delegate contactFetcherDidFetchContacts:self];  
     */
}


- (id) hashObject {
    return [NSNumber numberWithInt:[self hash]];
}

@end
