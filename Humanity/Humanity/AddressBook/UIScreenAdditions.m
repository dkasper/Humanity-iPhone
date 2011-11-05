#import "UIScreenAdditions.h"

@implementation UIScreen (Additions)
- (CGFloat) screenMin {
	CGSize screenSize = self.bounds.size;
	return fmin(screenSize.height, screenSize.width);
}

- (CGFloat) screenMax {
	CGSize screenSize = self.bounds.size;
	return fmax(screenSize.height, screenSize.width);
}

@end
