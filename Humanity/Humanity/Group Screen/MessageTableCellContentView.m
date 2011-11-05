//
//  MessageTableCellContentView.m
//  Humanity
//
//  Created by David Kasper on 11/5/11.
//  Copyright (c) 2011 Humanity. All rights reserved.
//

#import "MessageTableCellContentView.h"

@implementation MessageTableCellContentView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[self.delegate name] drawAtPoint:CGPointMake(60, 5) withFont:[UIFont boldSystemFontOfSize:18.0]];
    
    [[self.delegate body] drawInRect:CGRectMake(60, 25, 250, 100) withFont:[UIFont systemFontOfSize:12.0] lineBreakMode:UILineBreakModeWordWrap];
}

@end
