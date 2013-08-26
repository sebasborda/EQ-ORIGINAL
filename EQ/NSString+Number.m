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
#define AR_LOCALE [[NSLocale alloc] initWithLocaleIdentifier:@"es_AR"]

@implementation NSString (Number)

- (NSNumber *)number{
    return [self numberWithLocale:US_LOCALE];
}

- (NSNumber *)numberAR{
    return [self numberWithLocale:AR_LOCALE];
}

- (NSNumber *)numberWithLocale:(NSLocale *)locale{
    NSString *stringNumber = self;
    NSNumber *number = nil;
    if (stringNumber && [stringNumber length] > 0) {
        NSNumberFormatter *formatter = NUMBER_FORMATER;
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setLocale:locale];
        number = [formatter numberFromString:stringNumber];
    }
    
    return number;
}

@end
