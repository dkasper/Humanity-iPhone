#import <SystemConfiguration/SystemConfiguration.h>

#import <netinet/in.h>

typedef enum {
	NotReachable = 0,
	ReachableViaWiFi,
	ReachableViaWWAN
} NetworkStatus;

extern NSString *const JTVReachabilityChangedNotification;

@interface Reachability : NSObject {
@private
	BOOL _localWiFiRef;
	SCNetworkReachabilityRef _reachabilityRef;

	BOOL _networkStatusNotificationsEnabled;

	NetworkStatus _currentReachabilityStatus;
}

+ (Reachability *) sharedReachability;

//reachabilityWithHostName- Use to check the reachability of a particular host name.
+ (Reachability *) reachabilityWithHostName:(NSString *) hostName;

//reachabilityWithAddress- Use to check the reachability of a particular IP address.
+ (Reachability *) reachabilityWithAddress:(const struct sockaddr_in*) hostAddress;

// reachabilityForInternetConnection- checks whether the default route is available. Should be used by applications that do not connect to a particular host
+ (Reachability *) reachabilityForInternetConnection;

//reachabilityForLocalWiFi- checks whether a local wifi connection is available.
+ (Reachability *) reachabilityForLocalWiFi;

// Start and stop listening for reachability notifications on the current run loop
- (BOOL) startNotifier;
- (void) updateReachabilityStatus;
- (void) stopNotifer;

@property (nonatomic, readonly) NetworkStatus currentReachabilityStatus;
@property (nonatomic) BOOL networkStatusNotificationsEnabled;

// WWAN may be available, but not active until a connection has been established. WiFi may require a connection for VPN on Demand.
- (BOOL) connectionRequired;
@end
