@class ASIHTTPRequest;
@class ASINetworkQueue;

@interface SCAPIRequestController : NSObject {
@private
    NSMutableSet *_waitingRequests;   
}
+ (SCAPIRequestController *) sharedController;


- (void) addRequest:(ASIHTTPRequest *) request;

- (void) cancelRequestsOnTarget: (id) target clearDelegates: (BOOL) clearDelegates;  


- (void) retryRequest:(ASIHTTPRequest *) request; 
- (void) retryRequest:(ASIHTTPRequest *) request afterDelay:(NSTimeInterval) delay;

- (NSString *) errorStringForAPIRequest:(ASIHTTPRequest *) request;
 
- (void) presentLoginErrorWithRequest:(ASIHTTPRequest *) request;
- (void) presentNetworkErrorWithRequest:(ASIHTTPRequest *) request;
- (void) presentErrorWithRequest:(ASIHTTPRequest *) request defaultMessage:(NSString *) defaultMessage title:(NSString *) title;

    
@end
