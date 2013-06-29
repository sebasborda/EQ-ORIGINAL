//
//  NSDictionary+EQ.h
//  EQ
//
//  Created by Sebastian Borda on 4/30/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (EQ)

- (id)filterInvalidEntry:(NSString *)key;
- (NSString *)toJSON;

@end
