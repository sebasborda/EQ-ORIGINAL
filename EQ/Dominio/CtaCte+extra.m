//
//  CtaCte+extra.m
//  EQ
//
//  Created by Sebastian Borda on 7/3/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "CtaCte+extra.h"

@implementation CtaCte (extra)

@dynamic vendedores;

- (Vendedor *)vendedor{
    return [self.vendedores lastObject];
}

@end
