//
//  MessageTextView.h
//  Humanity
//
//  Created by David Kasper on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTextView : UIView<UITextViewDelegate> {
    BOOL _acceptFocus;  
}

-(void)showPlaceholder;
-(void)hidePlaceholder;
-(void)expand;
-(void)contract;

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIButton *closeButton;
@property (nonatomic, retain) UIButton *sendButton;
@property (nonatomic, retain) UISwitch *locationSwitch;
@property (assign) BOOL enabled;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) BOOL acceptFocus;
@end
