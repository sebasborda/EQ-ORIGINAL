//
//  NSString+Number.m
//  EQ
//
//  Created by Sebastian Borda on 5/1/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "NSString+Number.h"

#define NUMBER_FORMATER [[NSNumberFormatter alloc] init]
#define US_LOCALE [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]

@implementation NSString (Number)

- (NSNumber *)number{
    NSString *stringNumber = self;
    NSNumber *number = nil;
    if (stringNumber && [stringNumber length] > 0) {
        NSNumberFormatter *formater = NUMBER_FORMATER;
        [formater setNumberStyle:NSNumberFormatterDecimalStyle];
        [formater setLocale:US_LOCALE];
        number = [formater numberFromString:stringNumber];
    }
    
    return number;
}

@end
