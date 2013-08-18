//
//  NSManagedObject+EQ.m
//  EQ
//
//  Created by Sebastian Borda on 8/17/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "NSManagedObject+EQ.h"

#define predicate [NSPredicate predicateWithFormat:@"identifier == $OBJECT_ID"]

@implementation NSManagedObject (EQ)

+ (id)findWithIdentifier:(NSNumber *)identifier{
    NSPredicate* localPredicate = [predicate predicateWithSubstitutionVariables:@{@"OBJECT_ID":identifier}];
    return [self MR_findFirstWithPredicate:localPredicate];
}

+ (id)findOrCreateWithIdentifier:(NSNumber *)identifier{
    NSManagedObject *managedObject = [NSManagedObject findWithIdentifier:identifier];
    if (!managedObject) {
        managedObject = [self MR_createEntity];
        [managedObject setValue:identifier forKey:@"identifier"];
    }
    return managedObject;
}

@end
