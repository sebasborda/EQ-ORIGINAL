//
//  NSString+Number.h
//  EQ
//
//  Created by Sebastian Borda on 5/1/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Number)

- (NSNumber *)number;
- (NSNumber *)numberAR;
- (NSNumber *)numberWithLocale:(NSLocale *)locale;
@end
