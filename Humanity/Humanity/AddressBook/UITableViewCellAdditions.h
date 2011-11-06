@interface UITableViewCell (Additions)
+ (id) reusableCellForTableView:(UITableView *) tableView style:(UITableViewCellStyle) style;
+ (id) reusableCellForTableView:(UITableView *) tableView;

@property (nonatomic, getter=isEnabled) BOOL enabled;
@end
