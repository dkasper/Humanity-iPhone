@class SCSearchBar;

typedef enum {
	SCAlternateViewPositionNone,
	SCAlternateViewPositionTop,
	SCAlternateViewPositionBottom
} SCAlternateViewPosition;

@protocol SCTableViewDelegate <UITableViewDelegate>
@optional
- (CGFloat) heightForAlternateView:(UIView *) alternateView;
@end

@interface SCTableViewController : UIViewController {
@private
	SCAlternateViewPosition _alternateViewPosition;

	UITableView *_tableView;
	UIView *_alternateView;
    CGFloat _alternateViewHeight; 
    
	BOOL _showsSearchBar;
	BOOL _searchImmediately;
	SCSearchBar *_searchBar;

	BOOL _unloaded;
    BOOL _hasTabbar;
    BOOL _keyboardUp;       
}
@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) SCAlternateViewPosition alternateViewPosition;

@property (nonatomic, retain) UIView *alternateView;

@property (nonatomic, assign) BOOL showsSearchBar;
@property (nonatomic, assign) BOOL searchImmediately;
@property (nonatomic, readonly) SCSearchBar *searchBar;
@property (nonatomic, assign) BOOL hasTabbar;

- (id) initWithStyle:(UITableViewStyle) style position:(SCAlternateViewPosition) position;

- (void) resizeAlternateView;
- (void) resizeAlternateViewAnimated:(BOOL)animated; 
@end
