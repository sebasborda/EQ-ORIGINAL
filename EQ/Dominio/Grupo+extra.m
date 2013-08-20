//
//  Grupo+extra.m
//  EQ
//
//  Created by Sebastian Borda on 6/28/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Grupo+extra.h"
#import "EQDataAccessLayer.h"

@implementation Grupo (extra)

@dynamic articulos;
@dynamic parents;
@dynamic subGrupos;

- (Grupo *)parent{
    return [self.parents lastObject];
}

+ (void)resetRelevancia{
    NSArray *groups = [NSArray arrayWithArray:[[EQDataAccessLayer sharedInstance] objectListForClass:[Grupo class]]];
    for (Grupo *grupo in groups) {
        grupo.relevancia = 0;
    }
    
    [[EQDataAccessLayer sharedInstance] saveContext];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"Group id:%@ name:%@ parent:%@",self.identifier,self.nombre,self.parentID];
}

@end
