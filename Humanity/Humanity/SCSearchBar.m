#import "SCSearchBar.h"

@implementation SCSearchBar
- (void) layoutSubviews {
	for (UIView *subview in self.subviews) {
		if ([subview isKindOfClass:[UITextField class]]) {
			UITextField *textField = (UITextField *)subview;

			textField.keyboardAppearance = UIKeyboardAppearanceAlert;
		}
	}
	[super layoutSubviews];
}

- (void) resignForstResponderKeepCancel {
	for (UIView *subview in self.subviews) {
		if ([subview isKindOfClass:[UITextField class]]) {
            [subview resignFirstResponder];          
		} 
	}
	
	for (UIView *subview in self.subviews) {
		if ([subview isKindOfClass:[UIButton class]]) {
            ((UIButton *)subview).enabled = YES;
	    }    
	}
}

@end
