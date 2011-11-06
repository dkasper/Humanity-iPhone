#import "SCTableViewController.h"

#import "SCSearchBar.h"

#import "UIScreenAdditions.h"
#import "UITableViewAdditions.h"

@implementation SCTableViewController
@synthesize tableView = _tableView;
@synthesize alternateViewPosition = _alternateViewPosition;

@synthesize alternateView = _alternateView;

@synthesize showsSearchBar = _showsSearchBar;
@synthesize searchImmediately = _searchImmediately;
@synthesize searchBar = _searchBar;
@synthesize hasTabbar = _hasTabbar;
- (id) initWithStyle:(UITableViewStyle) style position:(SCAlternateViewPosition) position {
	if (!(self = [super init]))
		return nil;

	_tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:style];

	_alternateViewPosition = position;

	return self;
}

- (void) dealloc {
	if ([self isViewLoaded]) {
		_tableView.dataSource = nil;
		_tableView.delegate = nil;
		_searchBar.delegate = nil;
	}

	[_tableView release];
	[_alternateView release];

	[super dealloc];
}

#pragma mark -

- (void) loadView {
	UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin);

	_tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
	_tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin);

	CGFloat height = 0.;
	if (self.tableView.delegate && [self.tableView.delegate respondsToSelector:@selector(heightForAlternateView:)])
		height = [(id <SCTableViewDelegate>)self.tableView.delegate heightForAlternateView:_alternateView];
	else height = 44.;
    
	if (_alternateViewPosition != SCAlternateViewPositionNone) {
		CGFloat alternateViewYOrigin = 0.;
		if (_alternateViewPosition == SCAlternateViewPositionTop || self.alternateViewPosition == SCAlternateViewPositionNone) {
			alternateViewYOrigin = 0.;
		} 
		_alternateView.frame = CGRectMake(0, alternateViewYOrigin, [UIScreen mainScreen].screenMax, height);
        _alternateViewHeight = height;
		//_alternateView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin);
        
        NSLog(@"alternateViewYOrigin: %f", alternateViewYOrigin);
        NSLog(@"height: %f", height);
		// Autoresizing is great once the initial size is set. but it still has to be set first.
		if (!_unloaded) {
			CGRect frame = _tableView.frame;
			frame.size.height -= height;
			if (_alternateViewPosition == SCAlternateViewPositionTop)
				frame.origin.y += height;
			_tableView.frame = frame;
		}

		//if (_alternateViewPosition == SCAlternateViewPositionTop)
			//_tableView.autoresizingMask |= UIViewAutoresizingFlexibleBottomMargin;
	//	else if (_alternateViewPosition == SCAlternateViewPositionBottom)
			//_tableView.autoresizingMask |= UIViewAutoresizingFlexibleTopMargin;

		[view addSubview:_alternateView];
	}

	// the first time a view is loaded, it doesn't account for the tabbar or statusbar, any time afterwards, it does.
	if (_unloaded) {
		CGRect frame = _tableView.frame;
		//frame.size.height += [SCSocialApplication sharedApplication].tabBarController.tabBar.frame.size.height;
		frame.size.height += [UIApplication sharedApplication].statusBarFrame.size.height;
		if (_alternateViewPosition == SCAlternateViewPositionNone)
			frame.size.height += self.navigationController.navigationBar.frame.size.height;
		_tableView.frame = frame;
	}

	[view addSubview:_tableView];

	self.view = view;

	[view release];
}

- (void) viewDidLoad {
	[super viewDidLoad];
}

- (void) viewDidUnload {
	[super viewDidUnload];

	_unloaded = YES;
}

- (void) viewWillAppear:(BOOL) animated {
	[super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
    [self resizeAlternateView];				
}

- (void) viewDidDisappear:(BOOL) animated {
	[super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void) keyboardWillShow:(NSNotification *) notification {
	_keyboardUp = YES;
	NSValue *keyboardBoundsValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardBounds;
	[keyboardBoundsValue getValue:&keyboardBounds];
    
    NSLog(@"keyboardWillShow");
    
	[self.tableView setContentInsetByIncrementingWithEdgeInsets:UIEdgeInsetsMake(0., 0., (keyboardBounds.size.height /*- _searchBar.frame.size.height*/), 0.)];
}

- (void) keyboardWillHide:(NSNotification *) notification {
	
	NSValue *keyboardBoundsValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardBounds;
	[keyboardBoundsValue getValue:&keyboardBounds];
    
    NSLog(@"keyboardWillHide");
    
	/*
	A table view created while a keyboard is up should not resize when it goes away
	*/
	if (_keyboardUp) {
	    [self.tableView setContentInsetByDecrementingWithEdgeInsets:UIEdgeInsetsMake(0., 0., (keyboardBounds.size.height /*- _searchBar.frame.size.height*/), 0.)];
    }
    _keyboardUp = NO;
}

#pragma mark -

- (void) setAlternateView:(UIView *) alternateView {
	if ([self isViewLoaded])
		return;

	if (alternateView == _alternateView)
		return;

	id old = _alternateView;
	_alternateView = [alternateView retain];
	[old release];
}

- (void) setShowsSearchBar:(BOOL) showsSearchBar {
	if ([self isViewLoaded])
		return;

	_showsSearchBar = showsSearchBar;
}

- (void) resizeAlternateView {
    [self resizeAlternateViewAnimated:NO];
}
    
- (void) resizeAlternateViewAnimated:(BOOL)animated {
    CGFloat oldHeight = _alternateViewHeight; 
    
    CGFloat height = 0.;
	if (self.tableView.delegate && [self.tableView.delegate respondsToSelector:@selector(heightForAlternateView:)])
		height = [(id <SCTableViewDelegate>)self.tableView.delegate heightForAlternateView:_alternateView];
	else height = 44.;
    
	if (_alternateViewPosition != SCAlternateViewPositionNone) {
		CGFloat alternateViewYOrigin = 0.;
		if (_alternateViewPosition == SCAlternateViewPositionTop || self.alternateViewPosition == SCAlternateViewPositionNone) {
			alternateViewYOrigin = 0.;
		}        
        [UIView animateWithDuration:(animated ? 0.2 : 0.0) delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			_alternateView.frame = CGRectMake(0, alternateViewYOrigin, self.view.frame.size.width, height);
		} completion:NULL];	
	}
	
    CGFloat delta =  height - oldHeight;
    if (_alternateViewPosition != SCAlternateViewPositionNone && delta) {
        _alternateViewHeight = height;    
        CGRect frame = _tableView.frame;
		frame.size.height -= delta;
		if (_alternateViewPosition == SCAlternateViewPositionTop) {
			frame.origin.y += delta;
		}
        NSLog(@"animate height to %f", _alternateViewHeight);
		[UIView animateWithDuration:(animated ? 0.2 : 0.0) delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{ 
		    _tableView.frame = frame;    
		} completion:^(BOOL finished) {
            
		}];	    
    }
}
@end
