#import "NSData+JSONKit.h"

#import "JSONKit.h"

@implementation NSData (JSONKitAdditions)
- (id) objectFromJSONData {
	if (![self isKindOfClass:[NSData class]])
		return nil;

	JSONDecoder *decoder = [[[NSThread currentThread].threadDictionary objectForKey:@"JSONDecoder"] retain];
	if (!decoder) {
		decoder = [[JSONDecoder decoder] retain];
		[[NSThread currentThread].threadDictionary setObject:decoder forKey:@"JSONDecoder"];
	}

	id data = [decoder objectWithData:self];
	[decoder release];
	return data;
}
@end
