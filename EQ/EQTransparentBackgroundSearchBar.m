//
//  EQTransparentBackgroundSearchBar.m
//  EQ
//
//  Created by Sebastian Borda on 4/23/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQTransparentBackgroundSearchBar.h"

@implementation EQTransparentBackgroundSearchBar

-(void)didAddSubview:(UIView *)subview{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        if (![subview isKindOfClass:[UITextField class]]) {
            subview.alpha = 0;
        }
    }
}

@end
