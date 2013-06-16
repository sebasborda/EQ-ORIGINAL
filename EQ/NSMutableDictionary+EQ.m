//
//  NSMutableDictionary+EQ.m
//  EQ
//
//  Created by Sebastian Borda on 5/9/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "NSMutableDictionary+EQ.h"

@implementation NSMutableDictionary (EQ)

- (void)setNotNilObject:(id)anObject forKey:(id <NSCopying>)aKey{
    if (anObject) {
        [self setObject:anObject forKey:aKey];
    }
}

- (void)setNotEmptyStringEscaped:(NSString *)stringValue forKey:(id <NSCopying>)aKey{
    if ([stringValue length] > 0) {
        NSString *escapedString = [stringValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self setObject:escapedString forKey:aKey];
    }
}

- (void)setNotEmptyString:(NSString *)string forKey:(id <NSCopying>)aKey{
    if ([string length] > 0) {
        [self setObject:string forKey:aKey];
    }
}

@end
