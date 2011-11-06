@class SCCacheData; 
@protocol SCCachedHTTPRequestDelegate <NSObject>
- (id) hashObject;
@optional
- (float) timeToRetryWithCount:(NSUInteger)retryCount returnCode:(NSUInteger)returnCode userInfo:(id)userInfo;
- (void) cachedHTTPJSONObjectAvailable:(id)object returnCode:(NSUInteger)returnCode userInfo:(id)userInfo;
- (void) cachedHTTPImageAvailable:(UIImage *)image returnCode:(NSUInteger)returnCode userInfo:(id)userInfo; 
- (void) cachedHTTPRequestDataAvailable:(SCCacheData *)data returnCode:(NSUInteger)returnCode userInfo:(id)userInfo; 
@end


 