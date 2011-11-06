#import <UIKit/UIKit.h>

#import <Security/Security.h>



//Define an Objective-C wrapper class to hold Keychain Services code.

@interface KeychainWrapper : NSObject {
    
    NSMutableDictionary        *keychainData;
    
    NSMutableDictionary        *genericPasswordQuery;
    
}



@property (nonatomic, retain) NSMutableDictionary *keychainData;

@property (nonatomic, retain) NSMutableDictionary *genericPasswordQuery;



- (void)mySetObject:(id)inObject forKey:(id)key;

- (id)myObjectForKey:(id)key;

- (void)resetKeychainItem;



@end