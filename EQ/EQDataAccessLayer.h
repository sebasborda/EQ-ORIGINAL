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
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;

+ (EQDataAccessLayer *)sharedInstance;
- (void)saveContext;
- (NSArray *)objectListForClass:(Class)objectClass;
- (NSArray *)objectListForClass:(Class)objectClass filterByPredicate:(NSPredicate *)predicate;
- (NSArray *)objectListForClass:(Class)objectClass filterByPredicate:(NSPredicate *)predicate sortBy:(NSSortDescriptor *)sortDescriptor limit:(int)limit ;
- (NSManagedObject *)objectForClass:(Class)objectClass withId:(NSNumber *)idValue;
- (NSManagedObject *)objectForClass:(Class)objectClass withPredicate:(NSPredicate *)predicate;
- (NSManagedObject *)createManagedObject:(NSString*)kind;
- (NSManagedObject *)createManagedObjectWithEntity:(NSEntityDescription*)entityDescription;
- (NSManagedObjectContext *)managedObjectContext;

@end
