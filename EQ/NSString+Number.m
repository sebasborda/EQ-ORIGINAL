//
//  NSString+Number.m
//  EQ
//
//  Created by Sebastian Borda on 5/1/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "NSString+Number.h"

@implementation NSString (Number)

- (NSNumber *)number{
    NSString *stringNumber = self;
    if (stringNumber && [stringNumber length] > 0) {
        NSNumberFormatter *formater = [[NSNumberFormatter alloc] init];
        [formater setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *number = [formater numberFromString:stringNumber];
        return number;
    }
    
    return nil;
}

@end
