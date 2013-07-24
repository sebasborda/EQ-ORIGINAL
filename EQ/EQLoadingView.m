//
//  EQLoadingView.m
//  EQ
//
//  Created by Sebastian Borda on 4/27/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQLoadingView.h"

@interface EQLoadingView()

@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) UILabel *loadingMessage;
@property (nonatomic,assign) int counter;

@end

@implementation EQLoadingView

- (id)initViewWithSize:(CGSize)loadingSize showLargeImage:(BOOL)largeImage{
    CGRect screenFrame = CGRectMake(0, 0, loadingSize.width, loadingSize.height);
    self = [super initWithFrame:screenFrame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        self.alpha = .5;
        UIActivityIndicatorViewStyle style = largeImage ? UIActivityIndicatorViewStyleWhiteLarge : UIActivityIndicatorViewStyleWhite;
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        self.activityIndicator.center =self.center;
        [self addSubview:self.activityIndicator];
        
        CGRect labelFrame = CGRectMake(30, self.center.y + self.activityIndicator.frame.size.height + 30, 708, 40);
        self.loadingMessage = [[UILabel alloc] initWithFrame:labelFrame];
        [self.loadingMessage setTextAlignment:NSTextAlignmentCenter];
        [self.loadingMessage setTextColor:[UIColor whiteColor]];
        [self.loadingMessage setBackgroundColor:[UIColor clearColor]];
        [self.loadingMessage setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.]];
        [self addSubview:self.loadingMessage];
        self.counter = 0;
    }
    return self;
}

- (void)show{
    [self showWithMessage:@""];
}

- (void)showWithMessage:(NSString *)message{
    self.loadingMessage.text = message;
    if (self.counter == 0) {
        if (![self.activityIndicator isAnimating]) {
            [self.ownerView addSubview:self];
            [self.activityIndicator startAnimating];
        }
    }
    self.counter++;
}

- (void)hide{
    if (self.counter > 0) {
        self.counter--;
    }
    self.loadingMessage.text = @"";
    if (self.counter == 0) {
        [UIView animateWithDuration:.5 animations:^{
            if ([self.activityIndicator isAnimating]) {
                [self.activityIndicator stopAnimating];
                [self removeFromSuperview];
            }
        }];
    }
}


@end
