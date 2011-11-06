#import "SCReachability.h"

NSString *const JTVReachabilityChangedNotification = @"JTVReachabilityChangedNotification";

@interface Reachability ()
@property (nonatomic) BOOL localWiFiRef;
@property (nonatomic) SCNetworkReachabilityRef reachabilityRef;
@end

#pragma mark -

@implementation Reachability
@synthesize localWiFiRef = _localWiFiRef;
@synthesize reachabilityRef = _reachabilityRef;
@synthesize networkStatusNotificationsEnabled = _networkStatusNotificationsEnabled;

#pragma mark -

+ (Reachability *) sharedReachability {
	static BOOL creatingSharedInstance = NO;
	static Reachability *sharedInstance = nil;

	if (!sharedInstance && !creatingSharedInstance) {
		creatingSharedInstance = YES;
		sharedInstance = [[Reachability reachabilityWithHostName:@"socialcam.com"] retain];
	}

	return sharedInstance;
}

- (void) dealloc {
	[self stopNotifer];

	if (_reachabilityRef)
		CFRelease(_reachabilityRef);

	[[NSNotificationCenter defaultCenter] removeObserver:self name:JTVReachabilityChangedNotification object:nil];

	[super dealloc];
}

#pragma mark -

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *context) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[(Reachability *)context updateReachabilityStatus];

	[pool release];
}

#pragma mark -

- (BOOL) startNotifier {
	SCNetworkReachabilityContext context = { 0, self, NULL, NULL, NULL };
	if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context))
		return SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	return NO;
}

- (void) stopNotifer {
	if (_reachabilityRef)
		SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
}

#pragma mark -

// common initialization for Reachability, given a SCNetworkReachabilityRef
+ (Reachability *) reachabilityWithNetworkReachability:(SCNetworkReachabilityRef) reachability {
	if (!reachability)
		return nil;

	Reachability *networkReachability = [[[self class] alloc] init];
	networkReachability.reachabilityRef = reachability;
	networkReachability.networkStatusNotificationsEnabled = YES;

	[networkReachability updateReachabilityStatus];

	return [networkReachability autorelease];
}

+ (Reachability *) reachabilityWithHostName:(NSString*) hostName {
	return [self reachabilityWithNetworkReachability:SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String])];
}

+ (Reachability *) reachabilityWithAddress:(const struct sockaddr_in*) hostAddress {
	return [self reachabilityWithNetworkReachability:SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress)];
}

#pragma mark -

// common initialization for struct sockaddr_in
+ (struct sockaddr_in) sockaddrForReachability {
	struct sockaddr_in sockaddr;

	bzero(&sockaddr, sizeof(sockaddr));

	sockaddr.sin_len = sizeof(sockaddr);
	sockaddr.sin_family = AF_INET;

	return sockaddr;
}

+ (Reachability *) reachabilityForInternetConnection {
	struct sockaddr_in sockaddr = [self sockaddrForReachability];

	return [self reachabilityWithAddress:&sockaddr];
}

+ (Reachability *) reachabilityForLocalWiFi {
	struct sockaddr_in sockaddr = [self sockaddrForReachability];

	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
	sockaddr.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);

	Reachability *networkReachability = [self reachabilityWithAddress:&sockaddr];

	if (!networkReachability)
		return nil;

	networkReachability.localWiFiRef = YES;

	return networkReachability;
}

#pragma mark -

- (NetworkStatus) localWiFiStatusForFlags: (SCNetworkReachabilityFlags) flags {
	if ((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect))
		return ReachableViaWiFi;
	return NotReachable;
}

- (NetworkStatus) networkStatusForFlags:(SCNetworkReachabilityFlags) flags {
	// if target host is not reachable
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
		return NotReachable;

	BOOL reachable = NotReachable;

	// if target host is reachable and no connection is required
	// then we'll assume (for now) that you're on wifi
	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
		reachable = ReachableViaWiFi;

	// ... and the connection is on - demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs
	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
		// ... and no [user] intervention is needed
		if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
			reachable = ReachableViaWiFi;

	// ... but WWAN connections are OK if the calling application is using the CFNetwork (CFSocketStream?) APIs.
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
		reachable = ReachableViaWWAN;

	return reachable;
}

- (BOOL) connectionRequired {
	NSAssert(_reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");

	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
		return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
	return NO;
}

#pragma mark -

- (void) updateReachabilityStatus {
	SCNetworkReachabilityFlags flags;
	NetworkStatus currentStatus = NotReachable;

	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
		currentStatus = _localWiFiRef ? [self localWiFiStatusForFlags:flags] : [self networkStatusForFlags:flags];
	else currentStatus = NotReachable;

	if (currentStatus != _currentReachabilityStatus) {
		_currentReachabilityStatus = currentStatus;

		if (_networkStatusNotificationsEnabled)
			[[NSNotificationCenter defaultCenter] postNotificationName:JTVReachabilityChangedNotification object:self];
	}
}

- (NetworkStatus) currentReachabilityStatus {
#if TARGET_IPHONE_SIMULATOR
	return ReachableViaWiFi;
#else
	NSAssert(_reachabilityRef != NULL, @"currentReachable called with NULL reachabilityRef");

	return _currentReachabilityStatus;
#endif
}
@end
