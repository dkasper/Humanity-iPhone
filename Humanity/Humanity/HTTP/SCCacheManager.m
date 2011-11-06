//
//  SCCacheManager.m
//  Social
//
//  Created by Ammon on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*
 Raw cache managment.  
 
 */
#import "SCCacheManager.h"

#include <stdio.h>
#include <stdlib.h>

@implementation SCCacheData 
@synthesize payloadOffset = _payloadOffset;
@synthesize putTime = _putTime;


+ (NSString *) pathToDirectoryOfType:(NSSearchPathDirectory) directoryType {
	NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(directoryType, NSUserDomainMask, YES);
	if (!searchPaths.count) {
		NSLog(@"No paths found for %@ directories", directoryType);
        
		return nil;
	}
    
	return [searchPaths objectAtIndex:0];
}

+ (NSString *) pathToDocument:(NSString *) document {
	static NSString *path = nil;
	if (!path)
		path = [[self pathToDirectoryOfType:NSDocumentDirectory] copy];
    
    if (!document.length) return nil;
    
	return [path stringByAppendingString:document];
}

+ (NSString *) pathToCache:(NSString *) cache {
	static NSString *path = nil;
	if (!path)
		path = [[self pathToDirectoryOfType:NSCachesDirectory] copy];
    
    if (!cache.length) return nil;
    
	return [path stringByAppendingString:cache];
}

- (id) initWithData:(NSData *)data {
	if (!(self = [super init])) 
		return nil;
	_data = [data retain];
	return self;
}

- (void) dealloc {
	[_data release];
	[super dealloc];
}

- (const void *)bytes {
	return [_data bytes];
}

- (NSUInteger) length {
	return _data.length;
}
@end


static NSString *databasePath;

@interface  SCCacheManager (Private)
- (void) resetStore;
@end


@implementation SCCacheManager

+ (void) initialize {
	static BOOL initialized = NO;
		
	if (initialized)
		return;
	
	initialized = YES;
	
	databasePath = [[[self class] pathToCache:@"/http_cache_1"] retain]; 

    if(![[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        NSLog(@"Cache dir does not exist");
        if(![[NSFileManager defaultManager] createDirectoryAtPath:databasePath attributes:nil])
            NSLog(@"Error: Create folder failed");
    }    
}


+ (SCCacheManager *) sharedCacheManager {
	static BOOL creatingSharedInstance = NO;
	static SCCacheManager *sharedManager = nil;
	
	if (!creatingSharedInstance && !sharedManager) {
		creatingSharedInstance = YES;
		sharedManager = [[[self class] alloc] init];
	}
	return sharedManager;
}


- (void) test {
	[self openStore];
	NSData *d = [@"Hello world!" dataUsingEncoding:NSUTF8StringEncoding];
	
	if ([self putData:d forKey:@"key"]) {
		NSLog(@"Put data");
	}
	
	SCCacheData *d2 = [self getDataForKey:@"key"];
	//NSString *s = [[NSString alloc] initWithData:d2 encoding:NSUTF8StringEncoding];
	NSLog(@"Read %@", d2);
	//[s release];
	[self closeStore];
}


- (id) init {
	if (!(self = [super init]))
		return nil;
	
	
	return self; 
}

- (void) dealloc {
	[self closeStore];
	[super dealloc];
}


- (void) fatalDatabaseError {
	NSLog(@"\n\n\n\n\nFatal DB Error! Deleting Database!\n\n\n\n\n\n\n");   
	[self resetStore];
}

- (void) resetStore {
	[self closeStore];
	NSLog(@"Deleting cache file %@", databasePath); 
	[[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
	[self openStore];
}

- (BOOL) openStore {
	return YES;
}


- (void) closeStore {
	
}

- (BOOL) putData:(NSData *)data forKey:(NSString *)key {
    NSString *path = [databasePath stringByAppendingFormat:@"/%x", [key hash]];
	FILE *fp =  fopen([path UTF8String], "w");    
    if (!fp) {
       NSLog(@"Can't open %@", path);
        return NO;
    }
    NSTimeInterval t = [NSDate timeIntervalSinceReferenceDate];
    NSMutableData *writeData = [[NSMutableData alloc] initWithLength:data.length + sizeof(NSTimeInterval)];
    memcpy([writeData mutableBytes], &t, sizeof(NSTimeInterval));
    memcpy(((char *)[writeData mutableBytes]) + sizeof(NSTimeInterval), [data bytes], data.length);
    
    if(fwrite([writeData bytes], writeData.length, 1, fp) != 1) {
       NSLog(@"Unable to write all bytes");
        [writeData release];
		return NO;
    }
    
    [writeData release];
        
    fclose(fp);
	return YES;
}

- (SCCacheData *) getDataForKey:(NSString *) key {
	NSString *path = [databasePath stringByAppendingFormat:@"/%x", [key hash]];
	FILE *fp =  fopen([path UTF8String], "r");    
	if (!fp) {
        return nil;
	}
	
	fseek(fp, 0, SEEK_END);
	size_t len = ftell(fp); 
    if (len <= 0) {
       NSLog(@"len <= 0");
        fclose(fp);
        return nil;
    }
    
    fseek(fp, 0, SEEK_SET);
    NSMutableData *data = [[NSMutableData alloc] initWithLength:len];
    if(fread([data mutableBytes], len, 1, fp) != 1) {
       NSLog(@"Could not read len bytes");
        fclose(fp);
        [data release];
		return nil;
    }
    fclose(fp);
    
    NSTimeInterval t;
	memcpy(&t, [data bytes], sizeof(NSTimeInterval));
	
	SCCacheData *cdata = [[SCCacheData alloc] initWithData:data];
	[data release];
	
	cdata.putTime = t;
    cdata.payloadOffset = sizeof(NSTimeInterval);
	
	return [cdata autorelease];
}

- (BOOL) removeDataForKey:(NSString *)key {
	NSString *path = [databasePath stringByAppendingFormat:@"/%x", [key hash]];
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	return YES;
}

@end
