#import "UIAlertViewAdditions.h"

@implementation UIAlertView (Additions)
+ (void) presentNoNetworkAlert {
	[[self class] presentAlertWithTitle:NSLocalizedString(@"No Network Connection", @"No Network Connection title") message:NSLocalizedString(@"Please connect to the Internet to continue", @"Please connect to the Internet to continue message")];
}

+ (void) presentAlertWithTitle:(NSString *) title message:(NSString *) message {
	UIAlertView *alert = [[UIAlertView alloc] init];

	alert.title = title;
	alert.message = message;
	alert.cancelButtonIndex = [alert addButtonWithTitle:NSLocalizedString(@"Okay", @"Okay button")];

	[alert show];
	[alert release];
}
@end
