//
//  NSMutableDictionary+EQ.h
//  EQ
//
//  Created by Sebastian Borda on 5/9/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (EQ)

- (void)setNotNilObject:(id)anObject forKey:(id <NSCopying>)aKey;
- (void)setNotEmptyStringEscaped:(NSString *)stringValue forKey:(id <NSCopying>)aKey;
- (void)setNotEmptyString:(NSString *)string forKey:(id <NSCopying>)aKey;

@end
