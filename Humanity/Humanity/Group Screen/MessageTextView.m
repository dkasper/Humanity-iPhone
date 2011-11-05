//
//  MessageTextView.m
//  Humanity
//
//  Created by David Kasper on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import "MessageTextView.h"

#define CONTRACTED_TEXT_HEIGHT 30
#define EXPANDED_TEXT_HEIGHT 60
#define EXPANDED_HEIGHT 80
#define CONTRACTED_HEIGHT 50
#define PICTURE_SIZE 40
#define BUTTON_WIDTH 40
#define BUTTON_HEIGHT 20

@implementation MessageTextView

@synthesize textView = _textView;
@synthesize closeButton = _closeButton;
@synthesize sendButton = _sendButton;
@synthesize enabled = _enabled;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:200/255.0 alpha:1.0];
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(PICTURE_SIZE + 10, 5, self.bounds.size.width - PICTURE_SIZE - 15, CONTRACTED_TEXT_HEIGHT)];
        self.textView.font = [UIFont systemFontOfSize:14.0];
        self.textView.userInteractionEnabled = NO;
        [self addSubview:self.textView];
        
        [self showPlaceholder];
        
        self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.sendButton.frame = CGRectMake(self.bounds.size.width - BUTTON_WIDTH - 5, CONTRACTED_TEXT_HEIGHT + 10, BUTTON_WIDTH, BUTTON_HEIGHT);
        self.sendButton.titleLabel.text = @"Send";
        self.sendButton.backgroundColor = [UIColor greenColor];
        [self addSubview:self.sendButton];
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
    
    newFrame = self.sendButton.frame;
    newFrame.origin.y += EXPANDED_HEIGHT - CONTRACTED_HEIGHT;
    self.sendButton.frame = newFrame;
    
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
    
    newFrame = self.sendButton.frame;
    newFrame.origin.y -= EXPANDED_HEIGHT - CONTRACTED_HEIGHT;
    self.sendButton.frame = newFrame;
    
    newFrame = self.frame;
    newFrame.size.height = CONTRACTED_HEIGHT;
    self.frame = newFrame;
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
