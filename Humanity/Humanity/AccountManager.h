//
//  AccountManager.h
//  Humanity
//
//  Created by Ammon on 11/5/11.
//  Copyright (c) 2011 Yobongo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"


extern NSString *const HumanityUserDidLoginNotification;
extern NSString *const HumanityUserDidLogoutNotification;



@class Facebook;
@class KeychainWrapper;

@interface AccountManager : NSObject <FBSessionDelegate> {
    Facebook *_facebookSession;
    NSString *_facebookID; 
    BOOL _loggedIn;
    BOOL _loggingIn;
}

+ (AccountManager *) sharedAccountManager;

- (BOOL) loginFromKeychain; 
- (void) logout;

@property (nonatomic, readonly) Facebook *facebookSession;
@property (nonatomic, readonly) NSString *facebookID;
@property (nonatomic, readonly) BOOL loggedIn;

@end
