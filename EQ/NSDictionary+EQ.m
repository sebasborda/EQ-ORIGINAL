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
       ![[self objectForKey:key] isKindOfClass:[NSNull class]]){
        return [self objectForKey:key];
    }
    
    return nil;
}

- (NSString *)toJSON{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
