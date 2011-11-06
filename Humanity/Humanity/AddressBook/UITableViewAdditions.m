#import "UITableViewAdditions.h"

@implementation UITableView (Additions)
- (void) hideSeparatorLinesForEmptyCells {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
	headerView.backgroundColor = [UIColor clearColor];
	if (!self.tableHeaderView) self.tableHeaderView = headerView;

	UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
	footerView.backgroundColor = [UIColor clearColor];
	if (!self.tableFooterView) self.tableFooterView = footerView;

	[headerView release];
	[footerView release];
}

- (UITableViewRowAnimation) deleteAnimationForIndexPath:(NSIndexPath *) indexPath {
	if (indexPath.row == 0)
		return UITableViewRowAnimationTop;
	else if ((NSInteger)indexPath.row == ([self numberOfRowsInSection:indexPath.section] - 1))
		return UITableViewRowAnimationBottom;
	return UITableViewRowAnimationMiddle;
}

- (void) setContentInsetByIncrementingWithEdgeInsets:(UIEdgeInsets) edgeInsets {
	UIEdgeInsets contentInset = self.contentInset;
	contentInset.top += edgeInsets.top;
	contentInset.left += edgeInsets.left;
	contentInset.bottom += edgeInsets.bottom;
	contentInset.right += edgeInsets.right;
	self.contentInset = contentInset;
}

- (void) setContentInsetByDecrementingWithEdgeInsets:(UIEdgeInsets) edgeInsets {
	UIEdgeInsets contentInset = self.contentInset;
	contentInset.top -= edgeInsets.top;
	contentInset.left -= edgeInsets.left;
	contentInset.bottom -= edgeInsets.bottom;
	contentInset.right -= edgeInsets.right;
	self.contentInset = contentInset;
}
@end
