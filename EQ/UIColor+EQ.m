//
//  UIColor+EQ.m
//  EQ
//
//  Created by Sebastian Borda on 8/4/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "UIColor+EQ.h"

@implementation UIColor (EQ)

const float red = 210.f / 255.f;
const float green = 210.f / 255.f;
const float blue = 210.f / 255.f;

+ (UIColor *)grayForCell{
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

@end
