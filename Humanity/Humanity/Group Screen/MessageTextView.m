//
//  MessageTextView.m
//  Humanity
//
//  Created by David Kasper on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import "MessageTextView.h"
#import "GroupConstants.h"

@implementation MessageTextView

@synthesize textView = _textView;
@synthesize closeButton = _closeButton;
@synthesize sendButton = _sendButton;
@synthesize enabled = _enabled;
@synthesize locationSwitch = _locationSwitch;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor colorWithWhite:200/255.0 alpha:1.0];
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(PICTURE_SIZE + 10, 10, self.bounds.size.width - PICTURE_SIZE - 20, CONTRACTED_TEXT_HEIGHT)];
        self.textView.font = [UIFont systemFontOfSize:14.0];
        self.textView.userInteractionEnabled = NO;
        [self addSubview:self.textView];
        
        [self showPlaceholder];
        
        self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.sendButton.frame = CGRectMake(self.bounds.size.width - BUTTON_WIDTH - 5, EXPANDED_HEIGHT - BUTTON_HEIGHT - 5, BUTTON_WIDTH, BUTTON_HEIGHT);
        [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        self.sendButton.backgroundColor = [UIColor colorWithRed:48/255.0 green:128/255.0 blue:20/255.0 alpha:1.0];
        [self.sendButton addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.sendButton];
        
        self.locationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(60, self.sendButton.frame.origin.y, BUTTON_WIDTH, BUTTON_HEIGHT)];
        [self addSubview:self.locationSwitch];
    }
    return self;
}

-(void)showPlaceholder {
    if([self.textView.text length] == 0) {
        self.textView.textColor = [UIColor lightGrayColor];
        self.textView.text = @"Send a message";
    }
}

-(void)hidePlaceholder {
    if([self.textView.textColor isEqual:[UIColor lightGrayColor]]) {
        self.textView.textColor = [UIColor blackColor];
        self.textView.text = @"";
    }
}

-(void)expand {
    [self.textView becomeFirstResponder];
    self.textView.userInteractionEnabled = YES;

    [self hidePlaceholder];
    
    CGRect newFrame = self.textView.frame;
    newFrame.size.height = EXPANDED_TEXT_HEIGHT;
    self.textView.frame = newFrame;
    self.enabled = YES;
    
    newFrame = self.frame;
    newFrame.size.height = EXPANDED_HEIGHT;
    self.frame = newFrame;
}

-(void)contract {
    [self.textView resignFirstResponder];
    self.textView.userInteractionEnabled = NO;
    
    [self showPlaceholder];

    CGRect newFrame = self.textView.frame;
    newFrame.size.height = CONTRACTED_TEXT_HEIGHT;
    self.textView.frame = newFrame;
    self.enabled = NO;
    
    newFrame = self.frame;
    newFrame.size.height = CONTRACTED_HEIGHT;
    self.frame = newFrame;
}

-(void)send:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(sendMessage)]) {
        [self.delegate sendMessage];
    }
    self.textView.text = @"";
    [self.delegate toggleTextView:sender];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
