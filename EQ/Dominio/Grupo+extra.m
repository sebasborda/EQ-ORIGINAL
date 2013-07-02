//
//  Grupo+extra.m
//  EQ
//
//  Created by Sebastian Borda on 6/28/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Grupo+extra.h"

@implementation Grupo (extra)

@dynamic articulos;
@dynamic parents;

- (Grupo *)parent{
    return [self.parents lastObject];
}

@end
