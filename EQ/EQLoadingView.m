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
@property (nonatomic,assign) int counter;

@end

@implementation EQLoadingView

- (id)initViewWithSize:(CGSize)loadingSize showLargeImage:(BOOL)largeImage{
    CGRect screenFrame = CGRectMake(0, 0, loadingSize.width, loadingSize.height);
    self = [super initWithFrame:screenFrame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:55 green:55 blue:55 alpha:.5];
        UIActivityIndicatorViewStyle style = largeImage ? UIActivityIndicatorViewStyleWhiteLarge : UIActivityIndicatorViewStyleWhite;
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        CGSize activitySize = self.activityIndicator.frame.size;
        CGRect activityFrame = CGRectMake(self.center.x - (activitySize.height / 2),self.center.y - (activitySize.width / 2), activitySize.height, activitySize.width);
        
        self.activityIndicator.frame = activityFrame;
        [self addSubview:self.activityIndicator];
        self.counter = 0;
        
        self.hidden = YES;
    }
    return self;
}

- (void)show{
    if (self.counter == 0) {
        [UIView animateWithDuration:.5 animations:^{
            if (![self.activityIndicator isAnimating]) {
                [self.activityIndicator startAnimating];
            }
            self.hidden = NO;
        }];
    }
    self.counter++;
}

- (void)hide{
    if (self.counter > 0) {
        self.counter--;
    }
    
    if (self.counter == 0) {
        [UIView animateWithDuration:.5 animations:^{
            self.hidden = YES;
            if ([self.activityIndicator isAnimating]) {
                [self.activityIndicator stopAnimating];
            }
        }];
    }
}


@end
