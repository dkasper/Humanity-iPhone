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
#import "AccountManager.h"

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
	NSString *path = [ASIHTTPRequest pathWithApi:[NSString stringWithFormat:@"users?token=%@", [AccountManager sharedAccountManager].accessToken]];
	[[SCCachedHTTPManager sharedCachedHTTPManager] fetchObjectAtURL:[NSURL URLWithString:path] withCacheTime:5. andDelegate:self userInfo:nil];
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
    NSLog(@"object %@",  object);
    
    if (![object isKindOfClass:[NSArray class]]) {
        return; 
    }
    
    [_shareItems release];
    _shareItems = [[NSMutableArray alloc] init];
    
    for (NSDictionary *person in object) {
        if (![person isKindOfClass:[NSDictionary class]]) {
            return; 
        }
        NSString *fname = nil;
        NSString *lname = nil;
        NSString *name;
        if ([person objectForKey:@"first_name"] && [person objectForKey:@"first_name"] != [NSNull null])
            fname = [person objectForKey:@"first_name"];
        if ([person objectForKey:@"last_name"] && [person objectForKey:@"last_name"] != [NSNull null])
            lname = [person objectForKey:@"last_name"];
        if (fname && lname) {
            name = [NSString stringWithFormat:@"%@ %@", fname, lname];
        } else if (fname) {
            name = fname;
        } else if (lname) {
            name = lname;
        } else {
            continue; 
        }
        
        NSMutableDictionary *item = [NSMutableDictionary dictionary];
        if (fname) [item setObject:fname forKey:@"first_name"];
        if (lname) [item setObject:fname forKey:@"last_name"];
        [item setObject:name forKey:@"display_name"];
        [item setObject:[NSString stringWithFormat:@"%@", [person objectForKey:@"id"]] forKey:@"id"];
        if (lname) {
            [item setObject:[NSArray arrayWithObject:lname] forKey:@"match_keys"];
        }
        [item setObject:@"humanity" forKey:@"type"];
        [_shareItems addObject:item];
        
    }
    
	[_shareItems addObjectsFromArray:addressBookItems];
	
	NSLog(@"_shareItems: %@", _shareItems);
	
    [_delegate contactFetcherDidFetchContacts:self];  
}


- (id) hashObject {
    return [NSNumber numberWithInt:[self hash]];
}

@end
