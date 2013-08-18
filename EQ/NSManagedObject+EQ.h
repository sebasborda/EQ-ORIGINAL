//
//  NSManagedObject+EQ.h
//  EQ
//
//  Created by Sebastian Borda on 8/17/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (EQ)

+ (id)findWithIdentifier:(NSNumber *)identifier;
+ (id)findOrCreateWithIdentifier:(NSNumber *)identifier;

@end
