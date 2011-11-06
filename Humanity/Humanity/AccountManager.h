//
//  AccountManager.h
//  Humanity
//
//  Created by Ammon on 11/5/11.
//  Copyright (c) 2011 Yobongo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

@class Facebook;

@interface AccountManager : NSObject <FBSessionDelegate> {
    Facebook *_facebookSession;
}
+ (AccountManager *) sharedAccountManager;
@property (nonatomic, readonly) Facebook *facebookSession;
@end
