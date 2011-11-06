//
//  SCCacheManager.h
//  Social
//
//  Created by Ammon on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class LevelDB;


@interface SCCacheData : NSObject {
	NSUInteger _payloadOffset;   	
	double _putTime;
	NSData *_data;
}

@property (assign) NSUInteger payloadOffset;
@property (assign) double putTime;


@property (readonly) NSUInteger length;
- (id) initWithData:(NSData *)data;
- (const void *)bytes;
@end



@interface SCCacheManager : NSObject {

}
- (void) test;
- (BOOL) openStore;
- (void) closeStore;
- (SCCacheData *) getDataForKey:(NSString *) key;
- (BOOL) putData:(NSData *)data forKey:(NSString *)key;
+ (SCCacheManager *) sharedCacheManager;
@end
