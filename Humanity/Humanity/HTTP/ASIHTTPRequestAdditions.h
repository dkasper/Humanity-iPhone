#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

extern NSString *const DELETE;
extern NSString *const PUT;
extern NSString *const GET;
extern NSString *const POST;

// [ASIHTTPRequest apiRequestWithAPI:@"user/following.json" target:self selectorFormat:@"followingRequest"] will return an autoreleased ASIHTTPRequest with the following:
// url - [NSString stringWithFormat:SCAPIRootURLFormat, @"user/following.json"];,  which expands to @"http://api.socialcam.com/api/%@"
// target - self
// didFinishSelector - followingRequestDidFinish:
// didFailSelector - followingRequestDidFail:


BOOL statusCodeIsSuccess(NSUInteger statusCode);

BOOL shouldRetryFromStatusCode(NSUInteger statusCode);


@interface ASIHTTPRequest (Additions)
+ (NSString *) pathWithApi:(NSString *)api;
+ (ASIHTTPRequest *) apiRequestWithAPI:(NSString *) api target:(id) target selectorFormat:(NSString *) format;
@end

@interface ASIFormDataRequest (Additions)
+ (ASIFormDataRequest *) apiRequestWithAPI:(NSString *) api target:(id) target selectorFormat:(NSString *) format;
@end
