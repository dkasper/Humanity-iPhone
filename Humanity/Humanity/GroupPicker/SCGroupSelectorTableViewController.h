//
//  SCGroupSelectorTableViewController.h
//  Social
//
//  Created by Ammon on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "SCTableViewController.h"
#import <QuartzCore/QuartzCore.h>

@class SCGroupSelectorTableViewController;

@protocol SCGroupSelectorTableViewControllerDelegate <NSObject>
- (void) groupSelectorDidClose:(SCGroupSelectorTableViewController *)groupSelector doneClicked:(BOOL)done;
@end


@class HMButton;
@class MessageTextView;

@interface SCGroupSelectorTableViewController : SCTableViewController <SCTableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	NSArray *_sourceItems;
	NSArray *_matchingItems;
	NSMutableArray *_selectedItems;
	NSMutableArray *_selectedButtons;
	UITextField *_inputTextfield; 
	UITextField *_dummyTextField;  
	CGFloat _headerHeight;	
	HMButton *_selectedButton;
	NSArray *_groups; 
	
	NSInteger _tableViewListMode;
	UILabel *_toLabel; 
	UILabel *_tutorialLabel; 
	NSInteger _rowsToDisplay;
	
	CAGradientLayer *_shadowLayer;
	UIView *_grayLine;
	BOOL _formatAlertShown; 
    NSString *_groupHeaderText;
    BOOL _allowRawInput;
    NSString *_badTextAlertBody;   
    BOOL _cancelButtonClicked; 
    
    id<SCGroupSelectorTableViewControllerDelegate> _delegate;
     
    MessageTextView *_expandedTextView;      
    MessageTextView *_contractedTextView; 
    
    NSString *_savedTextInput;
    NSInteger _savedState;     
}

- (id) initWithItems:(NSArray *)items;
- (NSString*)titleForSelectedGroupWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;

- (void) setToLabelText:(NSString *)text;
- (void) setHintLabelText:(NSString *)text;
//- (void) sendMessage; 
 
@property (nonatomic, retain) NSArray *groups;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) NSString *groupHeaderText;
@property (nonatomic, assign) BOOL allowRawInput;
@property (nonatomic, retain) NSString *badTextAlertBody;
@property (nonatomic, readonly) NSArray *selectedItems;
@property (nonatomic, readonly) BOOL cancelButtonClicked;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, assign) id<SCGroupSelectorTableViewControllerDelegate> delegate;

@end
