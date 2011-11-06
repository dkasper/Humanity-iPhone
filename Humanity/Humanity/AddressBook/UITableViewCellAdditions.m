#import "UITableViewCellAdditions.h"

@implementation UITableViewCell (Additions)
+ (id) reusableCellForTableView:(UITableView *) tableView style:(UITableViewCellStyle) style {
	Class selfClass = [self class];
	NSString *identifier = [[NSString alloc] initWithFormat:@"%@:%d", NSStringFromClass(selfClass), style];

	id cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell)
		cell = [[[selfClass alloc] initWithStyle:style reuseIdentifier:identifier] autorelease];

	[identifier release];
	
	return cell;
}

+ (id) reusableCellForTableView:(UITableView *) tableView {
	return [self reusableCellForTableView:tableView style:UITableViewCellStyleDefault];
}

#pragma mark -

- (BOOL) isEnabled {
	for (UIView *view in self.subviews)
		return view.alpha != .5;
	return YES;
}

- (void) setEnabled:(BOOL) enabled {
	self.selectionStyle = UITableViewCellSelectionStyleNone;

	for (UIView *view in self.subviews)
		view.alpha = enabled ? 1 : .5;
}
@end
