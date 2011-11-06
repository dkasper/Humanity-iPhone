//
//  SCCachedHTTPManager.m
//  Social
//
//  Created by Ammon on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SCCachedHTTPManager.h"
#import "SCCachedHTTPRequestDelegate.h"
#import "SCCacheManager.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequestAdditions.h"
#import "SCAPIRequestController.h"
#import "NSData+JSONKit.h"

#import "UIAlertViewAdditions.h"


@interface SCCachedHTTPManager(Private)
- (void) fetchURL:(NSURL *)url withCacheTime:(double) cacheTime andDelegate:(id <SCCachedHTTPRequestDelegate>) delegate userInfo:(id) userInfo returnType:(NSString *)returnType;
- (void) sendData:(SCCacheData *)cacheData toDelegate:(id)delegate returnType:(NSString *)returnType returnCode:(NSUInteger)returnCode userInfo:(id)userInfo;
@end

@implementation SCCachedHTTPManager

+ (SCCachedHTTPManager *) sharedCachedHTTPManager {
	static BOOL creatingSharedInstance = NO;
	static SCCachedHTTPManager *sharedManager = nil;
	
	if (!creatingSharedInstance && !sharedManager) {
		creatingSharedInstance = YES;
		sharedManager = [[[self class] alloc] init];
	}
	return sharedManager;
}


- (id) init {
	if (!(self = [super init])) 
		return nil;
	
    _urlToDelegates = [[NSMutableDictionary alloc] init];
    _delegateToUrls = [[NSMutableDictionary alloc] init];
    
	return self; 
}

- (void) dealloc {
	[_urlToDelegates release];
	[_delegateToUrls release];
	[super dealloc];	
}

- (void) fetchURL:(NSURL *)url withCacheTime:(double) cacheTime andDelegate:(id <SCCachedHTTPRequestDelegate>) delegate userInfo:(id) userInfo returnType:(NSString *)returnType { 
	SCCacheData *data = [[SCCacheManager sharedCacheManager] getDataForKey:url.absoluteString]; 
	
	if (data) [self sendData:data toDelegate:delegate returnType:returnType returnCode:0 userInfo:userInfo];
		
	if (!data || cacheTime < 0.01 || [NSDate timeIntervalSinceReferenceDate] - data.putTime > cacheTime) {
		NSLog(@"cache is old; re-requesting (%@)", url);
		
        BOOL requestOutstanding = NO;
		if ([_urlToDelegates objectForKey:url]) {
            requestOutstanding = YES;
		    NSLog(@"Request is outstanding, adding to existing");
		} else {
		    [_urlToDelegates setObject:[NSMutableArray array] forKey:url];
		}
        
        if ([[_urlToDelegates objectForKey:url] containsObject:delegate]) {
            NSLog(@"Request not added, this delegate is already in list");
            return; 
        }
        
		[[_urlToDelegates objectForKey:url] addObject:delegate];
		
		if (![_delegateToUrls objectForKey:[delegate hashObject]]) [_delegateToUrls setObject:[NSMutableArray array] forKey:[delegate hashObject]];
        [[_delegateToUrls objectForKey:[delegate hashObject]] addObject:url];
        
        /*
        We can't retain the delegate, or we'll create a retain cycle. But we need to store it in a dict. So we add then release. This is a source of danger      
        */
        [delegate release];
        
        if (!requestOutstanding) {
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    		request.delegate = self;
    		request.didFinishSelector = @selector(requestDidFinish:);
    		request.didFailSelector = @selector(requestDidFail:);
    		
			NSMutableDictionary *d = [NSMutableDictionary dictionary]; 
			if (userInfo) [d setObject:userInfo forKey:@"userInfo"];
            if (returnType) [d setObject:returnType forKey:@"returnType"];
			request.userInfo = d;
			
			[[SCAPIRequestController sharedController] addRequest:request];
        }	
	} else {
		NSLog(@"cache is fresh; no need to re-request (%@)", url); 
	}
}

- (void) fetchURL:(NSURL *)url withCacheTime:(double) cacheTime andDelegate:(id <SCCachedHTTPRequestDelegate>) delegate userInfo:(id) userInfo {
    [self fetchURL:url withCacheTime:cacheTime andDelegate:delegate userInfo:userInfo returnType:@"data"];
} 

- (void) fetchObjectAtURL:(NSURL *)url withCacheTime:(double) cacheTime andDelegate:(id <SCCachedHTTPRequestDelegate>) delegate userInfo:(id) userInfo {
    NSLog(@"fetchObjectAtURL");
    [self fetchURL:url withCacheTime:cacheTime andDelegate:delegate userInfo:userInfo returnType:@"object"];
} 

- (void) fetchImageAtURL:(NSURL *)url withCacheTime:(double) cacheTime andDelegate:(id <SCCachedHTTPRequestDelegate>) delegate userInfo:(id) userInfo {
    [self fetchURL:url withCacheTime:cacheTime andDelegate:delegate userInfo:userInfo returnType:@"image"];
} 


- (void) removeDelegate:(id <SCCachedHTTPRequestDelegate>) delegate {
    NSLog(@"removeDelegate");
    NSArray *urls = [_delegateToUrls objectForKey:[delegate hashObject]];
    for (NSURL *url in urls) {
        NSMutableArray *a = [_urlToDelegates objectForKey:url];
        if ([a containsObject:delegate]) {
            /*HACK! We released the delegate after we added it to the dict, so we have to retain here*/
            [delegate retain];
            [a removeObject:delegate]; 
        }
    }
    [_delegateToUrls removeObjectForKey:[delegate hashObject]];	
}

- (void) removeUrl:(NSURL *)url{
    for (id delegate in [_urlToDelegates objectForKey:url]) {
        NSMutableArray *a = [_delegateToUrls objectForKey:[delegate hashObject]];
        [a removeObject:url];
        /*HACK! We released the delegate after we added it to the dict, so we have to retain here*/
        [delegate retain];
    }
    [_urlToDelegates removeObjectForKey:url];
}

- (void) requestDidFail:(ASIHTTPRequest *) request {
	NSLog(@"requestDidFail");
    NSArray *delegates = [_urlToDelegates objectForKey:request.originalURL];
    if (![delegates count]) {
		NSLog(@"Dellegate has been removed. Halting");
		return; 
	}
    
    id delegate = [delegates lastObject];
	
	if ([delegate respondsToSelector:@selector(timeToRetryWithCount:returnCode:userInfo:)]) {
		float retryTime = [delegate timeToRetryWithCount:[[request.userInfo objectForKey:@"retry_count"] intValue] returnCode:[request responseStatusCode] userInfo:[request.userInfo objectForKey:@"userInfo"]];
		if (retryTime >= 0.0) {
			[[SCAPIRequestController sharedController] retryRequest:request afterDelay:retryTime];
			return; 
		} else {
            [self removeUrl:request.originalURL];    
		}
	} else {
		if (shouldRetryFromStatusCode(request.responseStatusCode) && [[request.userInfo objectForKey:@"retry_count"] intValue] < 3) {
			[[SCAPIRequestController sharedController] retryRequest:request];
			return;
		} else {
		    [self removeUrl:request.originalURL];    
		}
	}
}

- (void) sendData:(SCCacheData *)cacheData toDelegate:(id)delegate returnType:(NSString *)returnType returnCode:(NSUInteger)returnCode userInfo:(id)userInfo {   
    
    if ([returnType isEqual:@"data"]) {
        [delegate cachedHTTPRequestDataAvailable:cacheData returnCode:returnCode userInfo:userInfo];        
    } else {
        NSData *d = [NSData dataWithBytesNoCopy:(void *)cacheData.bytes + cacheData.payloadOffset length:cacheData.length - cacheData.payloadOffset freeWhenDone:NO];
        if ([returnType isEqual:@"object"]) {
            id object = [d objectFromJSONData];
    	    [delegate cachedHTTPJSONObjectAvailable:object returnCode:returnCode userInfo:userInfo];
    	} else if ([returnType isEqual:@"image"]) {
            UIImage *image = [UIImage imageWithData:d];
            [delegate cachedHTTPImageAvailable:image returnCode:returnCode userInfo:userInfo];    
        }    
    }
} 

- (void) requestDidFinish:(ASIHTTPRequest *) request {	
	NSLog(@"requestDidFinish (%d) wth %d bytes type %@", [request responseStatusCode], [[request responseData] length], [request.userInfo objectForKey:@"returnType"]);
	if (!statusCodeIsSuccess(request.responseStatusCode)) {
		[self requestDidFail:request];
		return;
	}
	
	
	NSArray *delegates = [_urlToDelegates objectForKey:request.originalURL];

	if (![delegates count]) {
		NSLog(@"Dellegate has been removed. Halting");
		return; 
	}
	
	[[SCCacheManager sharedCacheManager] putData:request.responseData forKey:request.originalURL.absoluteString]; 
	
	SCCacheData *cacheData = [[SCCacheData alloc] initWithData:request.responseData]; 
    
    for (id delegate in delegates) {
        [self sendData:cacheData toDelegate:delegate returnType:[request.userInfo objectForKey:@"returnType"] returnCode:request.responseStatusCode userInfo:[request.userInfo objectForKey:@"userInfo"]];
    }
    
    [self removeUrl:request.originalURL];   
        
	[cacheData release]; 
}

@end