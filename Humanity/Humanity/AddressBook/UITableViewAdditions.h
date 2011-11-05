@interface UITableView (Additions)
- (void) hideSeparatorLinesForEmptyCells;
- (UITableViewRowAnimation) deleteAnimationForIndexPath:(NSIndexPath *) indexPath;

- (void) setContentInsetByIncrementingWithEdgeInsets:(UIEdgeInsets) edgeInsets;
- (void) setContentInsetByDecrementingWithEdgeInsets:(UIEdgeInsets) edgeInsets;
@end
