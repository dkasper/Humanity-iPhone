//
//  ContactFetchManager.h
//  Social
//
//  Created by Ammon on 11/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SCCachedHTTPRequestDelegate.h"

@class ContactFetchManager;

@protocol SCContactFetcherDelegate <NSObject>
- (void) contactFetcherDidFetchContacts:(ContactFetchManager *)fetch;
@end


@interface ContactFetchManager : NSObject <SCCachedHTTPRequestDelegate> {
	id<SCContactFetcherDelegate> _delegate; 
	NSMutableArray *_shareItems;
}

- (id) initWithDelegate:(id<SCContactFetcherDelegate>)delegate;
- (void) fetchContacts;   

@property (nonatomic, readonly) NSArray *shareItems;

@end
