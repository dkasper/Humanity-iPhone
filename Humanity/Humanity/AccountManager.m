//
//  AccountManager.m
//  Humanity
//
//  Created by Ammon on 11/5/11.
//  Copyright (c) 2011 Yobongo. All rights reserved.
//

#import "AccountManager.h"
#import "FBConnect.h"
#import "UIAlertViewAdditions.h"

#import "SCAPIRequestController.h"
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequestAdditions.h"
#import "ASIFormDataRequest.h"
#import "KeychainItemWrapper.h"
#import <Security/Security.h>


NSString *const HumanityUserDidLoginNotification = @"HumanityUserDidLoginNotification";
NSString *const HumanityUserDidLogoutNotification = @"HumanityUserDidLogoutNotification";


static NSString *kHMFacebookToken = @"kHMFacebookToken"; 
@implementation AccountManager

@synthesize facebookSession = _facebookSession;
@synthesize facebookID = _facebookID;
@synthesize loggedIn = _loggedIn;

- (id) init {
    if (!(self = [super init]))
        return nil;
    _facebookSession = [[Facebook alloc] initWithAppId:@"260726697307269"];
    _keychain =  [[KeychainItemWrapper alloc] initWithIdentifier:@"gethumanity.com" accessGroup:nil];
    return self;
}

- (void) dealloc {
    [_facebookSession release];
    [_facebookID release];
    [_keychain release];
    [super dealloc];
}

+ (AccountManager *) sharedAccountManager {
    static BOOL creatingSharedInstance = NO;
    static AccountManager *sharedManager = nil;
    if (!creatingSharedInstance && !sharedManager) {
        creatingSharedInstance = YES;
        sharedManager = [[[self class] alloc] init];
    }
    
    return sharedManager;
}

- (BOOL) loginFromKeychain {
    if (_loggingIn || _loggedIn) return NO; 
    NSString *fid = [_keychain objectForKey:kHMFacebookToken];
    if (!fid.length) return NO;
     _facebookID = [fid retain];
     _loggedIn = YES;
     _loggingIn = NO;
     
     [[NSNotificationCenter defaultCenter] postNotificationName:HumanityUserDidLoginNotification object:nil];
     
     return YES;
}

- (void) connectToFacebook {
    if (_loggingIn || _loggedIn) return;     
    _loggingIn = YES;
    NSArray *permissions = [NSArray arrayWithObjects:@"email", @"offline_access", @"publish_stream", @"read_stream", nil];
    [_facebookSession authorize:permissions method:@"fb_app" delegate:self];
}

- (void) fbDidNotLogin:(BOOL) cancelled {
    _loggingIn = NO;
	[UIAlertView presentAlertWithTitle:NSLocalizedString(@"Facebook Error", @"Facebook Error title") message:NSLocalizedString(@"Unable to connect to Facebook.", @"Unable to connect to Facebook. message")];
	
	NSLog(@"failed to login with facebook");
}

- (void) fbDidLogin {
	NSLog(@"Got access token from facebook:%@", _facebookSession.accessToken);
    ASIFormDataRequest *request = [ASIFormDataRequest apiRequestWithAPI:@"user/login" target:self selectorFormat:@"fbSignOnRequest"];
    request.requestMethod = POST;
    [request setPostValue:_facebookSession.accessToken forKey:@"fb_id"];
    [[SCAPIRequestController sharedController] addRequest:request];    
}

- (void) fbSignOnRequestDidFail:(ASIHTTPRequest *) request {
	NSLog(@"fbSignOnRequestDidFail (%d) %@", [request responseStatusCode], [request responseString]);
	if (!shouldRetryFromStatusCode(request.responseStatusCode) || [[request.userInfo objectForKey:@"retry_count"] intValue] >= 3) {
		_loggingIn = NO;
		return;
	}
	[[SCAPIRequestController sharedController] retryRequest:request];
}


- (void) fbSignOnRequestDidFinish:(ASIHTTPRequest *) request {
	NSLog(@"fbSignOnRequestDidFinish (%d) %@", [request responseStatusCode], [request responseString]);
	if (!statusCodeIsSuccess(request.responseStatusCode)) {
		[self fbSignOnRequestDidFail:request];
		return;
	}
    _facebookID = [_facebookSession.accessToken retain];
    _loggedIn = YES;
    _loggingIn = NO;
    
    [_keychain setObject:_facebookID forKey:kHMFacebookToken];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HumanityUserDidLoginNotification object:nil];
        
}

- (void) logout {
    [_keychain resetKeychainItem];
    

    _loggedIn = NO;
    _loggingIn = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:HumanityUserDidLogoutNotification object:nil];
}

@end
