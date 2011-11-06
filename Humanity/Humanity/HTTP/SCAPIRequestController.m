#import "SCAPIRequestController.h"

#import "ASIHTTPRequest.h"
#import "ASIHTTPRequestAdditions.h"

#import "SCReachability.h"

#import "NSStringAdditions.h"
#import "NSData+JSONKit.h"
#import "UIAlertViewAdditions.h"

@implementation SCAPIRequestController
+ (SCAPIRequestController *) sharedController {
	static SCAPIRequestController *sharedController = nil;
	static BOOL creatingRequestManager = NO;

	if (!creatingRequestManager && !sharedController) {
		creatingRequestManager = YES;
		sharedController = [[SCAPIRequestController alloc] init];
	}

	return sharedController;
}

- (id) init {
	if (!(self = [super init]))
		return nil;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusDidChange:) name:JTVReachabilityChangedNotification object:nil];

    _waitingRequests = [[NSMutableSet alloc] init]; 
    
	return self;
}

- (void) dealloc {
    [_waitingRequests release];
	[super dealloc];
}

#pragma mark -


- (void) addRequest:(ASIHTTPRequest *) request {
	[request startAsynchronous];
}

/*
Cancel all non-saved requests with a given target
*/
- (void) cancelRequestsOnTarget: (id) target clearDelegates: (BOOL) clearDelegates {
    for (ASIHTTPRequest *request in [ASIHTTPRequest sharedQueue].operations) {
        if (request.delegate == target) {
            if (clearDelegates)
                [request clearDelegatesAndCancel];
            else
                [request cancel];
        }
    }
}

- (void) _retryRequest:(ASIHTTPRequest *) request {
	[_waitingRequests removeObject:request];
	
	ASIFormDataRequest *newRequest = [ASIFormDataRequest requestWithURL:request.originalURL];
	newRequest.delegate = request.delegate;
	newRequest.didFinishSelector = request.didFinishSelector;
	newRequest.didFailSelector = request.didFailSelector;
	newRequest.postBody = request.postBody;
	newRequest.requestMethod = request.requestMethod;

	NSMutableDictionary *userInfo =  [request.userInfo mutableCopy];
    if (!userInfo)
		userInfo = [[NSMutableDictionary dictionary] retain];

	int retryCount = [[userInfo objectForKey:@"retry_count"] intValue];

	[userInfo setObject:[NSNumber numberWithInt:retryCount + 1] forKey:@"retry_count"];

	newRequest.userInfo = userInfo;

	[[SCAPIRequestController sharedController] addRequest:newRequest];

    NSLog(@"Retry %d on (%@) %@", retryCount, request.requestMethod, request.url);

	[userInfo release];
}


- (void) retryRequest:(ASIHTTPRequest *) request afterDelay:(NSTimeInterval) delay {
    [_waitingRequests addObject:request];
    [self performSelector:@selector(_retryRequest:) withObject:request afterDelay:delay];
}
    
- (void) retryRequest:(ASIHTTPRequest *) request {
	int retryCount = [[request.userInfo objectForKey:@"retry_count"] intValue];
	[self retryRequest:request afterDelay:MIN(2. * retryCount, 30.)];
}

- (NSString *) _displayKeyForKey: (NSString *) key {
    if ([key isEqual:@"login"])
        return @"Email";
         
    return [[key stringByReplacingOccurrencesOfString:@"_" withString:@" "] stringByCapitalizingString];
}

- (NSString *) errorStringForAPIRequest:(ASIHTTPRequest *) request { 
	id requestBodyError = [[request.responseData objectFromJSONData] objectForKey:@"errors"];
	if (requestBodyError) {
		if ([requestBodyError isKindOfClass:[NSString class]]) {
            return requestBodyError;
        } else if ([requestBodyError isKindOfClass:[NSArray class]]) {
            if ([[requestBodyError lastObject] isKindOfClass:[NSString class]]) return [requestBodyError lastObject]; 
        } else if  ([requestBodyError isKindOfClass:[NSDictionary class]]) {
            NSString *key = [[requestBodyError allKeys] lastObject];
            id val = [requestBodyError objectForKey:key];
            if ([val isKindOfClass:[NSString class]]) {
                val = [NSArray arrayWithObject:val];
            }
            if ([val isKindOfClass:[NSArray class]]) {
            	NSString *displayKey = [self _displayKeyForKey:key];
            	return [NSString stringWithFormat:@"%@ %@.", displayKey, [val lastObject]];
            }
        }
    }
	return nil;
}

- (void) presentLoginErrorWithRequest:(ASIHTTPRequest *) request {
	[self presentErrorWithRequest:request  defaultMessage:NSLocalizedString(@"An error occurred when logging in. Please try again.", @"An error occurred when logging in. Please try again. alert message") title:NSLocalizedString(@"Login Error", @"Login Error alert title")]; 
}
- (void) presentNetworkErrorWithRequest:(ASIHTTPRequest *) request {
	[self presentErrorWithRequest:request  defaultMessage:NSLocalizedString(@"A network error occurred. Please try again.", @"A network error occurred. Please try again. alert message") title:NSLocalizedString(@"Network Error", @"Network Error alert title")];	
}

- (void) presentErrorWithRequest:(ASIHTTPRequest *) request defaultMessage:(NSString *) defaultMessage title:(NSString *) title{
	NSString *message = defaultMessage;
	NSString *e = [self errorStringForAPIRequest:request];
	if (e.length)
		message = e;
	
	[UIAlertView presentAlertWithTitle:title message:message];
}


@end
