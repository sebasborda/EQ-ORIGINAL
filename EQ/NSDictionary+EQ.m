//
//  NSDictionary+EQ.m
//  EQ
//
//  Created by Sebastian Borda on 4/30/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "NSDictionary+EQ.h"

@implementation NSDictionary (EQ)

- (id)filterInvalidEntry:(NSString *)key
{
    if([self objectForKey:key] != Nil &&
       ![[self objectForKey:key] isKindOfClass:[NSNull class]] &&
       [self objectForKey:key] != nil){
        return [self objectForKey:key];
    }
    
    return nil;
}

@end
