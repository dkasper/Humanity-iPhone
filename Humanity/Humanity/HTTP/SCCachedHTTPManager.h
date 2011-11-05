//
//  SCCachedHTTPManager.h
//  Social
//
//  Created by Ammon on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SCCachedHTTPRequestDelegate.h"

@interface SCCachedHTTPManager : NSObject { 
    NSMutableDictionary *_urlToDelegates; 
    NSMutableDictionary *_delegateToUrls; 
}

- (void) fetchURL:(NSURL *)url withCacheTime:(double) cacheTime andDelegate:(id <SCCachedHTTPRequestDelegate>) delegate userInfo:(id) userInfo;
- (void) fetchObjectAtURL:(NSURL *)url withCacheTime:(double) cacheTime andDelegate:(id <SCCachedHTTPRequestDelegate>) delegate userInfo:(id) userInfo;
- (void) fetchImageAtURL:(NSURL *)url withCacheTime:(double) cacheTime andDelegate:(id <SCCachedHTTPRequestDelegate>) delegate userInfo:(id) userInfo;
     
- (void) removeDelegate:(id <SCCachedHTTPRequestDelegate>) delegate;
+ (SCCachedHTTPManager *) sharedCachedHTTPManager;
@end
