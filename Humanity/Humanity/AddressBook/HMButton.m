#import "HMButton.h"


@implementation HMButton
@synthesize userInfo = _userInfo;

- (void) dealloc {
	[_userInfo release];
	[super dealloc];
}
@end
