//
//  Catalogo+extra.m
//  EQ
//
//  Created by Sebastian Borda on 10/25/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Catalogo+extra.h"

@implementation Catalogo (extra)

@dynamic imagenes;

-(void)setPhotosList:(NSArray*)list{
    self.fotos = [NSKeyedArchiver archivedDataWithRootObject:list];
}

-(NSArray*)getPhotosList{
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.fotos];
}

@end
