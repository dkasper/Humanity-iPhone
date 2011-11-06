//
//  SCGroupSelectorTableViewController.m
//  Social
//
//  Created by Ammon on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SCGroupSelectorTableViewController.h"
#import "HMButton.h"
//#import "SCTableViewHeader.h"
//#import "SCUserGroupCell.h"

#import <CoreText/CoreText.h>
#import "SCAddressBook.h"
#import "UITableViewAdditions.h"
#import "UIAlertViewAdditions.h"
#import "UITableViewCellAdditions.h"
#import "MessageTextView.h"


#define ROW_HEIGHT 35.
#define BUTTON_HEIGHT 27.
#define LEFT_BUTTON_TITLE_PAD 0.
#define RIGHT_BUTTON_TITLE_PAD 0.

enum {
	GroupListMode,
	MatchListMode,
	SendListMode,
	NoListMode
};


@interface SCGroupSelectorTableViewController (Private)
- (void) layoutButtons;
- (void) filterItemsWithString:(NSString *) filterString; 
- (NSString *) titleForGroup:(NSArray *) group withFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
- (void) animateBadText:(NSNumber *)count; 
- (void) animateBadText;
- (void) addButtonForCurrentText;
@end

static UIImage *buttonBackground;
static UIImage *buttonBackgroundSelected;



@implementation SCGroupSelectorTableViewController

@synthesize groups = _groups;
@synthesize items = _sourceItems;
@synthesize groupHeaderText = _groupHeaderText;
@synthesize allowRawInput = _allowRawInput;
@synthesize badTextAlertBody = _badTextAlertBody;
@synthesize cancelButtonClicked = _cancelButtonClicked;
@synthesize delegate = _delegate;

- (void) setItems:(NSArray *)i { 
    NSMutableDictionary *recordCount = nil; 
    
    BOOL sortOverlap = YES;

    if (sortOverlap) {
        recordCount = [[NSMutableDictionary alloc] initWithCapacity:i.count / 2];
        for (NSDictionary *d in i) {
            id r = [recordCount objectForKey:[d objectForKey:@"display_name"]];
            if (!r) {
                [recordCount setObject:[NSNumber numberWithInt:1] forKey:[d objectForKey:@"display_name"]];
            } else {
                [recordCount setObject:[NSNumber numberWithInt:[r intValue] + 1] forKey:[d objectForKey:@"display_name"]];
            }
        }
    }
   	
	id old = _sourceItems;
	_sourceItems = [[i sortedArrayUsingComparator:^(id first, id second) {
        NSNumber *c1 = nil; 
        NSNumber *c2 = nil; 
        if (sortOverlap) {
            c1 = [recordCount objectForKey:[first objectForKey:@"display_name"]];
            c2 = [recordCount objectForKey:[second objectForKey:@"display_name"]];
        }
        if (c1 == c2 || [c1 isEqual:c2]) {    
            NSString *f1 = [first objectForKey:@"first_name"];
            NSString *f2 = [second objectForKey:@"first_name"];
            NSString *l1 = [first objectForKey:@"last_name"];
            NSString *l2 = [second objectForKey:@"last_name"];
            return [[SCAddressBook sharedAddressBook] compareFirst1:f1 last1:l1 first2:f2 last2:l2];
        } else {
            return [c2 compare:c1];
        }
    }] retain];
	
	[old release];
    [self.tableView reloadData];
}


- (void) setGroups:(NSArray *)g {
	id old = _groups;
	_groups = [g retain];
	[old release];
	_tableViewListMode = GroupListMode;
}

+ (void) initialize {
	static BOOL initialized = NO;
	
	if (initialized)
		return;
	
	initialized = YES;
	
    buttonBackground = [[[UIImage imageNamed:@"user_background_unselected.png"] stretchableImageWithLeftCapWidth:13. topCapHeight:0] retain];
    buttonBackgroundSelected = [[[UIImage imageNamed:@"user_background_selected.png"] stretchableImageWithLeftCapWidth:13. topCapHeight:0] retain];    
}

- (UIImage *) backgroundImageForItem:(NSDictionary *)item selected:(BOOL)selected {
    if (selected) return buttonBackgroundSelected;
    return buttonBackground;    
}
 
- (id) initWithItems:(NSArray *)items {
	if (!(self = [super initWithStyle:UITableViewStylePlain position:SCAlternateViewPositionTop])) 
		return nil;
	
    [self setItems:items];
	
	UIScrollView *altView = [[UIScrollView alloc] init];
	altView.backgroundColor = [UIColor whiteColor];
	
	
	altView.scrollEnabled = YES;
	altView.bounces = NO;
	
	self.alternateView = altView;
	
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	_inputTextfield = [[UITextField alloc] initWithFrame:CGRectMake(0., 0., 320., BUTTON_HEIGHT)];
	_inputTextfield.borderStyle = UITextBorderStyleNone;
	_inputTextfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_inputTextfield.keyboardAppearance = UIKeyboardAppearanceAlert;
	_inputTextfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_inputTextfield.autocorrectionType = UITextAutocorrectionTypeNo;
	_inputTextfield.keyboardType = UIKeyboardTypeDefault;
	_inputTextfield.delegate = self;
	_inputTextfield.returnKeyType = UIReturnKeyDefault;
    
    
    
	/*
	 Set text to zero width space. UITextField provides no way to detect a raw backspace key press, only the action when a char is deleted. 
	 We work around this by using a zero width space in place of an empty string, so that there is always something to delete.      
	 */
	_inputTextfield.text = @"\u200B";
	[altView addSubview:_inputTextfield];
	
	_dummyTextField = [[UITextField alloc] initWithFrame:CGRectZero];
	_dummyTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
	_dummyTextField.keyboardType = UIKeyboardTypeDefault;
	_dummyTextField.hidden = YES;
	_dummyTextField.text = @"\u200B";
	_dummyTextField.delegate = self;
	_dummyTextField.returnKeyType = UIReturnKeyDefault;
	
	[altView addSubview:_dummyTextField];
	
	_selectedButtons = [[NSMutableArray alloc] init];
	_selectedItems = [[NSMutableArray alloc] init];
	
	_headerHeight = ROW_HEIGHT - BUTTON_HEIGHT +  ROW_HEIGHT;
		
	self.tableView.backgroundColor = [UIColor whiteColor];
	self.tableView.separatorColor = [UIColor grayColor];
	//[self.tableView hideSeparatorLinesForEmptyCells];
	
	
	_toLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_toLabel.font = [UIFont systemFontOfSize:15.];
	_toLabel.backgroundColor = [UIColor clearColor];
	_toLabel.text = NSLocalizedString(@"To:", @"Label in sharing view where user enters list of user names, emails, of phone numbers");
	[_toLabel sizeToFit];
	[altView addSubview:_toLabel]; 
	
	_tutorialLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_tutorialLabel.font = [UIFont systemFontOfSize:14.];
	_tutorialLabel.backgroundColor = [UIColor clearColor];
	_tutorialLabel.text = NSLocalizedString(@"name, email or phone number", @"hint text in sharing view");
	_tutorialLabel.numberOfLines = 1;
    _tutorialLabel.minimumFontSize = 8.;    
    _tutorialLabel.adjustsFontSizeToFitWidth = YES;
	_tutorialLabel.textColor = [UIColor lightGrayColor];
	
	[_tutorialLabel sizeToFit];
	[altView addSubview:_tutorialLabel]; 
	
	_tableViewListMode = NoListMode;
	
	[altView release];
	
	_rowsToDisplay = 3;
	
	_grayLine = [[UIView alloc] initWithFrame:CGRectZero];
	_grayLine.backgroundColor = [UIColor colorWithRed:(142. / 255.) green:(142. / 255.) blue:(142. / 255.) alpha:1.];;
	[self.view addSubview:_grayLine];
	
	
	CGColorRef darkColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:((8. / 2) / 8.) * .5].CGColor;
	CGColorRef lightColor = [UIColor clearColor].CGColor;
	_shadowLayer = [[CAGradientLayer alloc] init];
	_shadowLayer.frame = CGRectMake(0., 0., 320., 8.);
	_shadowLayer.colors = [NSArray arrayWithObjects:(id)lightColor, (id)darkColor, nil];
	
    _groupHeaderText = [[NSString alloc] initWithString:NSLocalizedString(@"history", @"section header in sharing view")];
	
    _allowRawInput = YES;
	
    _badTextAlertBody = nil;
	
    _contractedTextView = [[MessageTextView alloc] initWithFrame:CGRectMake(0, 0, 320. ,44.)];
    _contractedTextView.acceptFocus = YES;
    [_contractedTextView contract];
    
    _expandedTextView = [[MessageTextView alloc] initWithFrame:CGRectMake(0, 0, 320. ,44.)];
    _expandedTextView.expandedHeight = 156.;
    _expandedTextView.expandedTextHeight = 106.;
    _expandedTextView.acceptFocus = YES;
    [_expandedTextView expand];
    
    _contractedTextView.delegate = self;
    _expandedTextView.delegate = self;
        
    [self.view addSubview:_contractedTextView];
    [self.view addSubview:_expandedTextView];
    
	return self; 
}

- (void) setToLabelText:(NSString *)text {
    _toLabel.text = text;
    [_toLabel sizeToFit]; 
}

- (void) setHintLabelText:(NSString *)text {
    _tutorialLabel.text = text;
    [_tutorialLabel sizeToFit];
}

- (void) dealloc {
	[_sourceItems release];
	[_matchingItems release];
	[_inputTextfield release];
	[_selectedButtons release];
	[_selectedItems release];
	[_groups release];
	[_toLabel release];
	[_tutorialLabel release];
	[_shadowLayer release];
	[_grayLine release];
    [_groupHeaderText release];
    [_badTextAlertBody release];
    [_contractedTextView release];
	[_expandedTextView release];
    [_savedTextInput release];
    [super dealloc];
}

- (void) scrollToBottomAnimated:(BOOL)animated {
	CGPoint bottomOffset = CGPointMake(0, [((UIScrollView *) self.alternateView) contentSize].height - _headerHeight);
	[((UIScrollView *) self.alternateView) setContentOffset: bottomOffset animated:animated];
}

- (CGFloat) heightForAlternateView:(UIView *) alternateView {
	return _headerHeight;
}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    [self.tableView hideSeparatorLinesForEmptyCells];
    _cancelButtonClicked = NO;
	
	[self layoutButtons];
    
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [UIApplication sharedApplication].statusBarHidden = NO;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.navigationController.navigationBar.alpha = 1.;
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	  
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel button") style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
	self.navigationItem.leftBarButtonItem = leftItem;
	[leftItem release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:_inputTextfield];        	
    
    [_inputTextfield becomeFirstResponder];
}
- (void) backButtonPressed:(id)sender{
    _cancelButtonClicked = YES;
    if (_delegate) {
        [_delegate groupSelectorDidClose:self doneClicked:NO];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) sendMessage{
    [self doneButtonPressed:nil];
}

- (void) doneButtonPressed:(id)sender{
    [self addButtonForCurrentText];
    
    if (_tableViewListMode != SendListMode) {
        if (!([_inputTextfield.text isEqual:@"\u200B"] || !_inputTextfield.text.length)) {
            [UIAlertView presentAlertWithTitle:nil message:NSLocalizedString(@"Your last entry was not recognized.", @"Message when user enters bad text in group interface")];
    		return;
    	}
    }
    if (_delegate) {
        [_delegate groupSelectorDidClose:self doneClicked:YES];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) viewWillDisappear:(BOOL) animated {
	[super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [_dummyTextField resignFirstResponder];
	[_inputTextfield resignFirstResponder];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	/*
	if (scrollView == self.tableView) {
		[_dummyTextField resignFirstResponder];
		[_inputTextfield resignFirstResponder];
	}*/
}

- (BOOL) textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange) range replacementString:(NSString *) string {
	NSLog(@"shouldChangeCharactersInRange %d-%d to %@", range.location, range.length, string);		 
	
	if ([string isEqualToString:@"\n"])
		return NO;
	
	if ([string isEqualToString:@","] || [string isEqualToString:@" "]) {
        [self textFieldShouldReturn:textField];
		return NO;
	}
		
	_inputTextfield.textColor = [UIColor blackColor];
	
	//entire string was deleted	
	if (!string.length && range.location == 0 && range.length ==  textField.text.length) {
		if (_selectedItems.count == 0) {
			[self.alternateView addSubview:_tutorialLabel];
		}
				
		//textfield was already empty 
		if ([textField.text isEqual:@"\u200B"]) {
			if (_selectedButton) {
				[self performSelector:@selector(removeSelectedButton) withObject:nil afterDelay:0.1];
			} else {
				if (_selectedButtons.count) {
					_selectedButton = [_selectedButtons objectAtIndex:_selectedButtons.count - 1];
					[_selectedButton setBackgroundImage:[self backgroundImageForItem:_selectedButton.userInfo selected:YES] forState:UIControlStateNormal];
					[_selectedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
					[_dummyTextField becomeFirstResponder];
				}
			}    
		}
		
		if (_tableViewListMode != GroupListMode) {
			_tableViewListMode = GroupListMode;
			[_shadowLayer removeFromSuperlayer];
			[self performSelector:@selector(clearFilter) withObject:nil afterDelay:0.1];
		}
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doFilterWithString:) object:textField.text];
		//all text was deleted. Sub in zero width marker, so that we can still trap delete key 
		
		textField.text = @"\u200B";
		
		return NO;
	}
	    
	BOOL rtn = YES;
	NSString *newString;
	
	if ([textField.text isEqual:@"\u200B"]) {
		if (_tutorialLabel) {
			[_tutorialLabel removeFromSuperview];
		}
			
		// text was added to zero-width marker. Remove the marker.  
		_inputTextfield.text = string;
		if (textField == _dummyTextField) {
			if (_selectedButton) {
				[_selectedItems removeObject:_selectedButton.userInfo];
				[_selectedButton removeFromSuperview];
				[_selectedButtons removeObject:_selectedButton];
				_selectedButton = nil;
				[_inputTextfield becomeFirstResponder];
				[self layoutButtons];
			}
			[_inputTextfield becomeFirstResponder];	
		}
		rtn = NO;
		newString = string; 
	} else {
		newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
	}
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doFilterWithString:) object:textField.text];
    [self performSelector:@selector(doFilterWithString:) withObject:newString afterDelay:0.2];
	
	return rtn;	
}

/*
The delegate method shouldChangeCharactersInRange is (very oddly) not called when 
the user holds down delete and does a full-line delete. This catches that case. 
*/
- (void)textFieldDidChange:(NSNotification *)notification {
    UITextField *aTextField = [notification object];
    if (aTextField == _inputTextfield || aTextField == _dummyTextField) {
        if ([aTextField.text length] == 0) {
            //all text was deleted. Sub in zero width marker, so that we can still trap delete key 
            aTextField.text =  @"\u200B";
            if (_selectedItems.count == 0) {
    			[self.alternateView addSubview:_tutorialLabel];
    		}
        }            
    }
}


- (void) removeSelectedButton {
    [_selectedItems removeObject:_selectedButton.userInfo];
	[_selectedButton removeFromSuperview];
	[_selectedButtons removeObject:_selectedButton];
	_selectedButton = nil;
	if (_selectedItems.count == 0 && (!_inputTextfield.text.length || [_inputTextfield.text isEqual:@"\u200B"] )) {
	    [self.alternateView addSubview:_tutorialLabel];	
	}
	[_inputTextfield becomeFirstResponder];
	[self layoutButtons];
}

- (void) clearFilter {
    
    [self showContractedTextArea];
    
    if (3 != _rowsToDisplay) {
		_rowsToDisplay = 3;
		[self layoutButtons];
		[self scrollToBottomAnimated:NO];
	}
	[self.tableView reloadData];
}
- (void) doFilterWithString:(NSString*)string {
    
    [self filterItemsWithString:string]; 
    
    _tableViewListMode = MatchListMode;
	
    [self hideTextArea];
	
	if (_matchingItems.count) {
		[self.view.layer addSublayer:_shadowLayer];
	} else {
		[_shadowLayer removeFromSuperlayer];
	}
		
	NSInteger newRowsToDisplay = (_matchingItems.count ? 1 : 3);
	if (newRowsToDisplay != _rowsToDisplay) {
		_rowsToDisplay = newRowsToDisplay;
		[self layoutButtons];
		[self scrollToBottomAnimated:NO];
	}
	
	[self.tableView reloadData];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if (textField == _inputTextfield) {
		if (_selectedButton) {
			[_selectedButton setBackgroundImage:[self backgroundImageForItem:_selectedButton.userInfo selected:NO] forState:UIControlStateNormal];
			[_selectedButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			_selectedButton = nil;
		}
        [self showContractedTextArea];
	}
}

- (void) layoutButtons {
#define X_OFFSET 5.	
	float x = X_OFFSET;
	float y = ROW_HEIGHT - BUTTON_HEIGHT;
	
	//_headerHeight = ROW_HEIGHT - BUTTON_HEIGHT +  ROW_HEIGHT;
	
	float width = self.alternateView.frame.size.width;

	CGRect frame = _toLabel.frame;
	frame.origin.x = x;
	frame.origin.y = y + BUTTON_HEIGHT / 2.0 - frame.size.height / 2.0;
	_toLabel.frame = frame;
	x += frame.size.width + 5.;
	
	if (_tableViewListMode != SendListMode) {
        _tutorialLabel.hidden = NO;
    	if (_tutorialLabel) {
    		frame = _tutorialLabel.frame;
    		frame.origin.x = x + LEFT_BUTTON_TITLE_PAD;
    		frame.origin.y = y + BUTTON_HEIGHT / 2.0 - frame.size.height / 2.0;
    		frame.size.width = width - frame.origin.x;
    		_tutorialLabel.frame = frame;
    	}
	
    	for (UIButton *button in _selectedButtons) {
            button.hidden = NO;
    		if (x > X_OFFSET && x + button.frame.size.width > width) {
    			x = X_OFFSET;
    			y += ROW_HEIGHT;
    		}
    		frame = button.frame;
    		frame.origin.x = x;
    		frame.origin.y = y;
    		button.frame = frame; 
			
    		x += frame.size.width + 5.;  
    	}
	
    	if (x > width * 0.66) {
    		x = X_OFFSET;
    		y += ROW_HEIGHT;
    	}
	} else {
	    _tutorialLabel.hidden = YES;
	    for (UIButton *button in _selectedButtons) {
            button.hidden = YES;
        }
	}
	
	frame = _inputTextfield.frame;
	frame.origin.x = x;
	frame.origin.y = y;
	frame.size.width = width - frame.origin.x;
	_inputTextfield.frame = frame;
	
	if (_tableViewListMode == SendListMode) {
	    _inputTextfield.text = [self titleForSelectedGroupWithFont:_inputTextfield.font constrainedToWidth:320. - _inputTextfield.frame.origin.x];
	}
	
	CGFloat height = y + ROW_HEIGHT;
	
	if (fabs(((UIScrollView *) self.alternateView).contentSize.height - height) > 0.01) {
	    ((UIScrollView *) self.alternateView).contentSize = CGSizeMake(self.alternateView.frame.size.width, height);    
	}
	
	_headerHeight = MIN(height, ROW_HEIGHT - BUTTON_HEIGHT + ROW_HEIGHT * _rowsToDisplay);
	
	[self resizeAlternateViewAnimated:YES];
}
 
- (NSString *) typeForValue:(NSString *)value {
	static NSPredicate *emailRegex = nil;
	static NSPredicate *phoneRegex = nil;
	if (!emailRegex) {
		emailRegex = [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @".+[@].+[.].+"] retain];
	}
	if (!phoneRegex) {
		phoneRegex = [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[0-9.+\\-]*[0-9]+[0-9.+\\-]*"] retain];
	}
	
	if ([emailRegex evaluateWithObject:value] == YES) {
		return @"email";
	}
	
	if ([phoneRegex evaluateWithObject:value] == YES) {
		return @"phone";
	}
	return nil;
}

- (NSString *) formatValue:(NSString *)value {
	return value;
}


- (void) addButtonForItem:(NSDictionary *)item {
    BOOL add = YES;
    
	for (NSDictionary *i in _selectedItems) {
		if ([[i objectForKey:@"id"] isEqual:[item objectForKey:@"id"]]) {
			add = NO; 
		}
	}
	
	if ([_selectedItems containsObject:item]) add = NO;
	
	if (add) {  
	    [_selectedItems addObject:item];
	
    	HMButton *button = [HMButton buttonWithType:UIButtonTypeCustom];
    	[button setBackgroundImage:[self backgroundImageForItem:item selected:NO] forState:UIControlStateNormal];
        button.adjustsImageWhenHighlighted = NO;
    	
    	[button setTitle:[item objectForKey:@"display_name"] forState:UIControlStateNormal];
    	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    	button.titleLabel.font = [UIFont systemFontOfSize:15];
    	button.titleEdgeInsets = UIEdgeInsetsMake(0., LEFT_BUTTON_TITLE_PAD, 0., RIGHT_BUTTON_TITLE_PAD);

    	[button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    	button.userInfo = item;
    	
    	CGRect frame = CGRectZero;
	
    	frame.size.height = BUTTON_HEIGHT;	
    	frame.size.width = MAX(BUTTON_HEIGHT, [[item objectForKey:@"display_name"] sizeWithFont: button.titleLabel.font].width + LEFT_BUTTON_TITLE_PAD + RIGHT_BUTTON_TITLE_PAD + 20);
	
    	if (frame.size.width > self.alternateView.frame.size.width)
    		frame.size.width = self.alternateView.frame.size.width; 
	
    	button.frame = frame; 
	
    	[self.alternateView addSubview:button];
	
    	[_selectedButtons addObject:button];
	}
	  
	[self layoutButtons];

}

- (void) addButtonForCurrentText {
	if ([_inputTextfield.text isEqual:@"\u200B"] || !_inputTextfield.text.length) {
		return;
	}
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doFilterWithString:) object:_inputTextfield.text];
	
	if (![self typeForValue:_inputTextfield.text] || !_allowRawInput) {
		[self animateBadText];
		return; 
	}
	
	NSString *value = [self formatValue:_inputTextfield.text];
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:value forKey:@"id"];
	[dict setObject:value forKey:@"display_name"];
	[dict setObject:[self typeForValue:_inputTextfield.text] forKey:@"type"];
	[dict setObject:@"true" forKey:@"user_supplied"];
	
	[self addButtonForItem:dict];
								  
	_inputTextfield.text = @"\u200B";
    
	if (_tableViewListMode != GroupListMode) {
		_tableViewListMode = GroupListMode;
        [self showContractedTextArea];
		[_shadowLayer removeFromSuperlayer];
		if (3 != _rowsToDisplay) {
			_rowsToDisplay = 3;
			[self layoutButtons];
			[self scrollToBottomAnimated:NO];
		}
		
		[self.tableView reloadData];
	}	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ((!_inputTextfield.text.length || [_inputTextfield.text isEqual:@"\u200B"]) && _selectedItems.count) {
        [self doneButtonPressed:nil];
		return NO; 
	}
	    
	[self addButtonForCurrentText];	
	return NO;
}
	
- (void) buttonTapped:(id) sender {
	/*
	if (_inputTextfield.text.length && ![_inputTextfield.text isEqual:@"\u200B"]) {
		if (![self typeForValue:_inputTextfield.text]) {
			[self animateBadText];
			return;
		}
	}*/
	
	HMButton *button = (HMButton *) sender; 
	if (_selectedButton && _selectedButton != button) {
		[_selectedButton setBackgroundImage:[self backgroundImageForItem:_selectedButton.userInfo selected:NO] forState:UIControlStateNormal];
	    [_selectedButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	[button setBackgroundImage:[self backgroundImageForItem:button.userInfo selected:YES] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	_selectedButton = button;
	
	[_dummyTextField becomeFirstResponder];
	
	[self addButtonForCurrentText];	
	
}

- (NSString *) condensedTitleForGroupOf:(NSInteger)size {
    if (!size) return @"";
	return (size > 1 ? [NSString stringWithFormat:NSLocalizedString(@"%d people", @"title line for group of people in share interface"), size] : NSLocalizedString(@"1 person", @"title line for group of people in share interface")); 
}

- (NSString*)titleForSelectedGroupWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width {
    return [self titleForGroup:_selectedItems withFont:font constrainedToWidth:width];
}

- (NSString *) titleForGroup:(NSArray *) group withFont:(UIFont *)font constrainedToWidth:(CGFloat)width {	
	NSString *title = [self condensedTitleForGroupOf:group.count];
	for (NSUInteger i = 0; i < group.count; i++) {
		NSMutableString *newTitle = [NSMutableString string];
		for (NSUInteger j = 0; j <= i; j++) { 
            if ([[[group objectAtIndex:j] objectForKey:@"first_name"] length] && [[[group objectAtIndex:j] objectForKey:@"last_name"] length])
                [newTitle appendFormat:@"%@ %@", [[group objectAtIndex:j] objectForKey:@"first_name"], [[[group objectAtIndex:j] objectForKey:@"last_name"] substringToIndex:1]];
			else
			    [newTitle appendString:[[group objectAtIndex:j] objectForKey:@"display_name"]];
			if (j < i) {
				[newTitle appendString:@", "];
			}
		}
		if (i < group.count - 1) {
			[newTitle appendFormat:NSLocalizedString(@" and %d more...", @"in group person selector, appended to title for groups of people if all can't fit on one line"), group.count - 1 - i];
		}
       NSLog(@"[newTitle sizeWithFont:font].width %f %f", [newTitle sizeWithFont:font].width, width);
		if ([newTitle sizeWithFont:font].width <= width) {
			title = newTitle;
		} else {
			break;
		}
	}
	return title;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView {	
	if (_tableViewListMode == GroupListMode) {
		return 1;
	} else if (_tableViewListMode == MatchListMode) {
		return 1;
	}
	return 0;
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
    if (_tableViewListMode == GroupListMode) {
		if (_groups.count != 0) return _groups.count;  
        return 0; 
	} else if (_tableViewListMode == MatchListMode) {
		return _matchingItems.count;
	}
    return 0;
}


- (UITableViewCell *) cellForItem:(NSDictionary *)item inTableView:(UITableView *) tableView {
    UITableViewCell *cell = [UITableViewCell reusableCellForTableView:tableView style:UITableViewCellStyleSubtitle];
    cell.textLabel.text = [item objectForKey:@"display_name"];
	cell.imageView.image = nil;
	if ([[item objectForKey:@"type"] isEqual:@"facebook"]) {
		cell.detailTextLabel.text = @"Facebook"; 
	} else if ([[item objectForKey:@"type"] isEqual:@"humanity"]) {
	    cell.detailTextLabel.text = @"Humanity";
	} else {
		cell.detailTextLabel.text = [item objectForKey:@"id"];
	}
	return cell; 
} 

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	if (_tableViewListMode == GroupListMode) {
		if (_groups.count == 0) {
            UITableViewCell *cell = [UITableViewCell reusableCellForTableView:tableView style:UITableViewCellStyleDefault];
            return cell;
		}
		if (indexPath.row < _groups.count) {
			if ([[_groups objectAtIndex:indexPath.row] count] == 1) {
                return [self cellForItem:[[_groups objectAtIndex:indexPath.row] lastObject] inTableView:tableView];
			} else {	
			    /*
                SCUserGroupCell *cell = [SCUserGroupCell reusableCellForTableView:tableView style:UITableViewCellStyleSubtitle];
                cell.imageView.image =  [UIImage imageNamed:@"contact-group-icon.png"];
                cell.textLabel.text = [self condensedTitleForGroupOf:[[_groups objectAtIndex:indexPath.row] count]];
    			cell.detailTextLabel.text = [self titleForGroup:[_groups objectAtIndex:indexPath.row] withFont:cell.detailTextLabel.font constrainedToWidth:999.9];
    			return cell;
                 */
			}
		}
	} else if (_tableViewListMode == MatchListMode) {
		if (indexPath.row < _matchingItems.count) {			
			return [self cellForItem:[_matchingItems objectAtIndex:indexPath.row] inTableView:tableView];
		}
	}
	return [UITableViewCell reusableCellForTableView:tableView];
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath {	
	if (_tableViewListMode == GroupListMode) {
		if (indexPath.row < _groups.count) {
			if (_tutorialLabel) {
				[_tutorialLabel removeFromSuperview];
			}
			
			for (NSDictionary *item in [_groups objectAtIndex:indexPath.row]) {
				[self addButtonForItem:item];
			}
			
			//scroll to bottom so we can see the new items
			[self scrollToBottomAnimated:YES];

			
			NSMutableArray *mutableGroups = [_groups mutableCopy];
			[mutableGroups removeObjectAtIndex:indexPath.row];
			self.groups = mutableGroups;
			[tableView beginUpdates];
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[tableView endUpdates];
			if (!_inputTextfield.isFirstResponder) [_inputTextfield becomeFirstResponder];
		}
	} else if (_tableViewListMode == MatchListMode) {
		if (indexPath.row < _matchingItems.count) {
			_tableViewListMode = GroupListMode;
			[self showContractedTextArea];
			[_shadowLayer removeFromSuperlayer];
			_rowsToDisplay = 3;
				
			[self addButtonForItem:[_matchingItems objectAtIndex:indexPath.row]];
			
			_inputTextfield.text = @"\u200B";
			
			[self scrollToBottomAnimated:NO];
			[self.tableView reloadData];
			
			
			if (!_inputTextfield.isFirstResponder) [_inputTextfield becomeFirstResponder];
		}
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) animateBadText:(NSNumber *)count {
#define ITERS 8.
    CGFloat i = [count doubleValue];
	_inputTextfield.textColor = [UIColor colorWithRed:1. + ((0. - 1.)/ITERS)*i green:0 blue:0 alpha:1.];
	if (i < ITERS) {
        [self performSelector:_cmd withObject:[NSNumber numberWithDouble:i + 1.] afterDelay:0.04];
    }
}  

- (void) animateBadText {	
	//if (!_formatAlertShown) {
	//	[UIAlertView presentAlertWithTitle:nil message:_badTextAlertBody];
	//	_formatAlertShown = YES;
	//}
	_inputTextfield.textColor = [UIColor redColor];
    [self performSelector:@selector(animateBadText:) withObject:nil afterDelay:0.2];
}

/*
- (NSString *) titleForHeaderInSection:(NSInteger)section {
	if (_tableViewListMode == GroupListMode && _groups.count) {
		return _groupHeaderText;
	}
	return nil;
}*/

/*
- (CGFloat) tableView:(UITableView *) tableView heightForHeaderInSection:(NSInteger) section {
	if (![self titleForHeaderInSection:section].length)
        return 0;
	return 22.;
}*/

/*
- (UIView *) tableView:(UITableView *) tableView viewForHeaderInSection:(NSInteger) section {
	SCTableViewHeader *header = [[SCTableViewHeader alloc] init];
    header.titleLabel.text = [self titleForHeaderInSection:section];
	return [header autorelease];	
}*/

- (void) filterItemsWithString:(NSString *) filterString {
	NSLog(@"filterItemsWithString %@", filterString);
	
	if (filterString.length) {
		NSMutableArray *newMatches = [[NSMutableArray alloc] init];
        
		for (NSDictionary *item in _sourceItems) {
			if ([[item objectForKey:@"display_name"] hasCaseInsensitivePrefix:filterString]) {
				[newMatches addObject:item]; 
				continue; 
			}
			for (NSString *key in [item objectForKey:@"match_keys"]) {
				if ([key hasCaseInsensitivePrefix:filterString]) {
					[newMatches addObject:item]; 
					break;
				}
			}
		}
		
		id old = _matchingItems;
		_matchingItems = newMatches;
		[old release];
	}			
}

- (void) resizeAlternateViewAnimated:(BOOL)animated {
	[super resizeAlternateViewAnimated:animated];
	[UIView animateWithDuration:(animated ? 0.2 : 0) delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		CGRect frame = _shadowLayer.frame;
		frame.origin.y = _headerHeight;
		_shadowLayer.frame = frame;
		_grayLine.frame = CGRectMake(0, _headerHeight, self.view.frame.size.width, 1.);
	} completion:^(BOOL innerFinished) {
	}];
}

- (NSArray *) selectedItems {
    if (!_selectedItems.count) return nil;
    NSMutableArray *rtn = [NSMutableArray array];
    for (NSDictionary *item in _selectedItems) {
        NSMutableDictionary *d = [item mutableCopy];
        [d removeObjectForKey:@"match_keys"];
        [rtn addObject:d];
        [d release];
    }
    return rtn;
}


- (void) hideTextArea {
    _contractedTextView.hidden = YES;
    _expandedTextView.hidden = YES;
    
}

- (void) showContractedTextArea {
    _contractedTextView.textView.text = _expandedTextView.textView.text;
    _contractedTextView.hidden = NO;
    _expandedTextView.hidden = YES;    
}

- (void) showExpandedTextArea {
    _contractedTextView.hidden = YES;
    _contractedTextView.textView.text = nil;
    _expandedTextView.hidden = NO;    
}

- (void) keyboardWillShow:(NSNotification *) notification {
    [super keyboardWillShow:notification];
	NSValue *keyboardBoundsValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardBounds;
	[keyboardBoundsValue getValue:&keyboardBounds];
    
    [self showContractedTextArea];
    
    CGRect frame = _contractedTextView.frame;
    frame.origin.y = keyboardBounds.origin.y - frame.size.height - 44. - 20;
    _contractedTextView.frame = frame;
    
    frame = _expandedTextView.frame;
    frame.origin.y = keyboardBounds.origin.y - frame.size.height - 44. - 20;
    _expandedTextView.frame = frame;
}


- (void) messageTextViewSelected:(MessageTextView *)messageTextView {
    if (messageTextView == _contractedTextView) {
        _savedTextInput = [_inputTextfield.text copy];
        _savedState = _tableViewListMode;
        _tableViewListMode = SendListMode;
        [((UIScrollView *) self.alternateView) setContentOffset:CGPointMake(0, 0) animated:NO];
        [self layoutButtons];
        //[self scrollToBottomAnimated:NO];
        [self showExpandedTextArea];
        [_expandedTextView.textView becomeFirstResponder];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _inputTextfield && _tableViewListMode == SendListMode) {
        _tableViewListMode = _savedState;
        _inputTextfield.text = _savedTextInput;
        [_savedTextInput release], _savedTextInput = nil;
        [self layoutButtons];
        [self scrollToBottomAnimated:NO];
    }
    return YES;
}

- (NSString *) message {
    return _expandedTextView.textView.text;
}

@end
