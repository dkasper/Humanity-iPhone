//
//  MessageTextView.m
//  Humanity
//
//  Created by David Kasper on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import "MessageTextView.h"
#import "GroupConstants.h"
#import "SCAPIRequestController.h"
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequestAdditions.h"

@implementation MessageTextView

@synthesize textView = _textView;
@synthesize closeButton = _closeButton;
@synthesize sendButton = _sendButton;
@synthesize enabled = _enabled;
@synthesize locationSwitch = _locationSwitch;
@synthesize delegate = _delegate;
@synthesize acceptFocus = _acceptFocus;
@synthesize expandedHeight = _expandedHeight;
@synthesize expandedTextHeight = _expandedTextHeight; 
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _expandedHeight = EXPANDED_HEIGHT;
        _expandedTextHeight = EXPANDED_TEXT_HEIGHT;
        
        
        _speechBubble = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"speechbubble.png"] stretchableImageWithLeftCapWidth:20. topCapHeight:22.]];
        [self addSubview:_speechBubble];
        
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor colorWithWhite:200/255.0 alpha:1.0];
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(PICTURE_SIZE + 10, 10, self.bounds.size.width - PICTURE_SIZE - 20, CONTRACTED_TEXT_HEIGHT)];
        self.textView.font = [UIFont systemFontOfSize:14.0];
        self.textView.userInteractionEnabled = NO;
        self.textView.delegate = self;
        self.textView.backgroundColor = [UIColor clearColor]; 
        [self addSubview:self.textView];
        
        [self showPlaceholder];
        
        self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        self.sendButton.backgroundColor = [UIColor colorWithRed:48/255.0 green:128/255.0 blue:20/255.0 alpha:1.0];
        [self.sendButton addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.sendButton];
        
        self.locationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [self addSubview:self.locationSwitch];
    }
    return self;
}
- (void) dealloc {
    [_speechBubble release];
    [super dealloc];
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
- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect frame = _speechBubble.frame;
    frame.origin.x = self.textView.frame.origin.x - 7.;
    frame.origin.y = self.textView.frame.origin.y;
    frame.size.width = self.textView.frame.size.width + 7.;
    frame.size.height = self.textView.frame.size.height;
    _speechBubble.frame = frame;  
    
    self.sendButton.frame = CGRectMake(self.textView.frame.origin.x + self.textView.frame.size.width - BUTTON_WIDTH, _expandedHeight - BUTTON_HEIGHT - 5, BUTTON_WIDTH, BUTTON_HEIGHT);
    self.locationSwitch.frame = CGRectMake(self.textView.frame.origin.x, self.sendButton.frame.origin.y, BUTTON_WIDTH, BUTTON_HEIGHT);
}
-(void)expand {
    if (!_acceptFocus) {
        [self.textView becomeFirstResponder];
    }
    [self setNeedsLayout];
    
    
    self.textView.userInteractionEnabled = YES;
    [self hidePlaceholder];
    
    CGRect newFrame = self.textView.frame;
    newFrame.size.height = _expandedTextHeight;
    self.textView.frame = newFrame;
    self.enabled = YES;
    
    newFrame = self.frame;
    newFrame.size.height = _expandedHeight;
    self.frame = newFrame;
}

-(void)contract {
    
    if (!_acceptFocus) {
        [self.textView resignFirstResponder];
        self.textView.userInteractionEnabled = NO;
    } else {
        self.textView.userInteractionEnabled = YES;
    }
    
    [self setNeedsLayout];
    
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
    NSLog(@"Send");
    if(self.delegate && [self.delegate respondsToSelector:@selector(sendMessage)]) {
        [self.delegate sendMessage];
    } else {    
        ASIHTTPRequest *request = [ASIHTTPRequest apiRequestWithAPI:@"message/create.json" target:self selectorFormat:@"sendRequest"];
        request.requestMethod = POST;
        [request setPostValue:self.textView.text forKey:@"content"];
        [[SCAPIRequestController sharedController] addRequest:request]; 
    } 
}

- (void) sendRequestDidFinish:(ASIHTTPRequest *) request {
    self.textView.text = @"";
    [self.delegate toggleTextView:nil];
}

- (void) sendRequestDidFail:(ASIHTTPRequest *) request {
    NSLog(@"Error");
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if(self.delegate && [self.delegate respondsToSelector:@selector(messageTextViewSelected:)]) {
        [self.delegate messageTextViewSelected:self];
    }
    return YES;
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
