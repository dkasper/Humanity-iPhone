#import "JTVButton.h"


@implementation JTVButton
@synthesize userInfo = _userInfo;

- (void) dealloc {
	[_userInfo release];
	[super dealloc];
}
@end
