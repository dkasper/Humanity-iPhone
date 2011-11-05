#import "UIDevice+Hardware.h"
#import "ASIHTTPRequestAdditions.h"

NSString *const DELETE = @"DELETE";
NSString *const PUT = @"PUT";
NSString *const GET = @"GET";
NSString *const POST = @"POST";

NSString *const APIRootURLFormat =   @"https://api.socialcam.com/api/v4/%@";


static NSString *localeIdentifier = nil;
static NSString *versionIdentifier = nil;

@implementation ASIHTTPRequest (Additions)
+ (void) currentLocaleDidChange:(NSNotification *) notification {
	[localeIdentifier release], localeIdentifier = nil;
}

 + (NSString *) pathWithApi:(NSString *)api {
    return [NSString stringWithFormat:APIRootURLFormat, api];   
}
 


+ (id) _apiRequestWithAPI:(NSString *) api target:(id) target selectorFormat:(NSString *) format {
    NSString *string = [ASIHTTPRequest pathWithApi:api];
    
	NSURL *url = [[NSURL alloc] initWithString:string];

	ASIHTTPRequest *request = [[[self class] alloc] initWithURL:url];
	[request addRequestHeader:@"X-Apple-model" value:[UIDevice currentDevice].platformString];
	[request addRequestHeader:@"X-Apple-os-version" value:[UIDevice currentDevice].systemVersion];

	if (!localeIdentifier.length) {
		NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
		NSString *country = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode];

		if (language.length && country.length)
			localeIdentifier = [[NSString alloc] initWithFormat:@"%@-%@", language, country];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLocaleDidChange:) name:NSCurrentLocaleDidChangeNotification object:nil];
	}

	[request addRequestHeader:@"X-Locale" value:localeIdentifier];

	if (!versionIdentifier.length)
		versionIdentifier = [[[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"] copy];

	// This one has all words starting with caps, unlike the rest, per an email with Gullaume and Alex
	[request addRequestHeader:@"X-App-Version" value:versionIdentifier];

	request.downloadCache = nil;
	request.cachePolicy = ASIDoNotWriteToCacheCachePolicy;
	request.delegate = target;
	request.shouldContinueWhenAppEntersBackground = NO;

	if (target && format.length) {
		NSString *didFinishSelectorString = [[NSString alloc] initWithFormat:@"%@DidFinish:", format];
		request.didFinishSelector = NSSelectorFromString(didFinishSelectorString);

		NSString *didFailSelectorString = [[NSString alloc] initWithFormat:@"%@DidFail:", format];
		request.didFailSelector = NSSelectorFromString(didFailSelectorString);

		[didFinishSelectorString release];
		[didFailSelectorString release];
	}

	[url release];

	return [request autorelease];
}

+ (ASIHTTPRequest *) apiRequestWithAPI:(NSString *) api target:(id) target selectorFormat:(NSString *) format {
	return [self _apiRequestWithAPI:api target:target selectorFormat:format];
}
@end

@implementation ASIFormDataRequest (Additions)
+ (ASIFormDataRequest *) apiRequestWithAPI:(NSString *) api target:(id) target selectorFormat:(NSString *) format {
	return [self _apiRequestWithAPI:api target:target selectorFormat:format];
}
@end
