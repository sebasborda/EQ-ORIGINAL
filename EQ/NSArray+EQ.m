//
//  NSArray+EQ.m
//  EQ
//
//  Created by Sebastian Borda on 7/19/14.
//  Copyright (c) 2014 Sebastian Borda. All rights reserved.
//

#import "NSArray+EQ.h"

@implementation NSArray (EQ)

- (NSString *)toJson {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)0
                                                         error:&error];

    if (!jsonData) {
        return @"[]";
    } else {
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        json = [json stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        json = [json stringByReplacingOccurrencesOfString:@"//" withString:@""];
        json = [json stringByReplacingOccurrencesOfString:@",[{" withString:@",{"];
        json = [json stringByReplacingOccurrencesOfString:@"}]," withString:@"},"];
        json = [json stringByReplacingOccurrencesOfString:@"]]" withString:@"]"];
        json = [json stringByReplacingOccurrencesOfString:@"[[" withString:@"["];
        return json;
    }
}

@end
