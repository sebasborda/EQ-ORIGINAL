//
//  EQDataAccessLayer.h
//  EQ
//
//  Created by Sebastian Borda on 3/24/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface EQDataAccessLayer : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *storeCoordinator;

+ (EQDataAccessLayer *)sharedInstance;
- (void)saveContext;
- (NSArray *)objectListForClass:(Class)objectClass;
- (NSArray *)objectListForClass:(Class)objectClass filterByPredicate:(NSPredicate *)predicate;
- (NSArray *)objectListForClass:(Class)objectClass filterByPredicate:(NSPredicate *)predicate sortBy:(NSSortDescriptor *)sortDescriptor;
- (NSManagedObject *)objectForClass:(Class)objectClass withId:(NSNumber *)idValue;
- (NSManagedObject *)objectForClass:(Class)objectClass withPredicate:(NSPredicate *)predicate;
- (NSManagedObject *)createManagedObject:(NSString*)kind;


@end
