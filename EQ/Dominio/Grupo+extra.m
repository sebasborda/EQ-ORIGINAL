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
    NSFetchRequest *allRequest = [[NSFetchRequest alloc] initWithEntityName:@"Grupo"];
    NSError *error = nil;
    //fetch new prices
    NSArray *newObjects = [[EQDataAccessLayer sharedInstance].mainManagedObjectContext executeFetchRequest:allRequest error:&error];
    [newObjects setValue:@0 forKey:@"relevancia"];
    
    [[EQDataAccessLayer sharedInstance] saveContext];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"Group id:%@ name:%@ parent:%@",self.identifier,self.nombre,self.parentID];
}

@end
