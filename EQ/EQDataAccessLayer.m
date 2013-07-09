//
//  EQDataAccessLayer.m
//  EQ
//
//  Created by Sebastian Borda on 3/24/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQDataAccessLayer.h"


@interface EQDataAccessLayer ()
- (NSURL *)applicationDocumentsDirectory;
@end

@implementation EQDataAccessLayer
@synthesize storeCoordinator;
@synthesize managedObjectModel;
@synthesize managedObjectContext;

+ (EQDataAccessLayer *)sharedInstance {
    __strong static EQDataAccessLayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EQDataAccessLayer alloc] init];
        sharedInstance.storeCoordinator = [sharedInstance persistentStoreCoordinator];
        sharedInstance.managedObjectContext = [sharedInstance managedObjectContext];
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
    });
    return sharedInstance;
}

#pragma mark - Core Data

- (void)saveContext {
    @synchronized (self) {
        NSError *error = nil;
        if (managedObjectContext != nil)
        {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
            {
                NSLog(@"error: %@", error.userInfo);
                /*
                 Replace this implementation with code to handle the error appropriately.
                 
                 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
                 */
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
}

- (NSArray *)objectListForClass:(Class)objectClass{
    return [self objectListForClass:objectClass filterByPredicate:nil sortBy:nil];
}

- (NSArray *)objectListForClass:(Class)objectClass filterByPredicate:(NSPredicate *)predicate{
    return [self objectListForClass:objectClass filterByPredicate:predicate sortBy:nil];
}

- (NSArray *)objectListForClass:(Class)objectClass filterByPredicate:(NSPredicate *)predicate sortBy:(NSSortDescriptor *)sortDescriptor{
    @synchronized (self) {
        NSString *className = NSStringFromClass(objectClass);
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:className];
        if (fetchRequest) {
            fetchRequest.predicate = predicate;
        }
        
        if (sortDescriptor) {
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        } else {
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        }
        
        NSArray *managedObjectList = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        return managedObjectList;
    }
}


- (NSManagedObject *)objectForClass:(Class)objectClass withId:(NSNumber *)idValue{
    if (idValue) {
        NSManagedObject *object = [self objectForClass:objectClass withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@",idValue]];
        if (object) {
            return object;
        }
    }
    
    NSString *className = NSStringFromClass(objectClass);
    return [self createManagedObject:className];
}

- (NSManagedObject *)objectForClass:(Class)objectClass withPredicate:(NSPredicate *)predicate{
    @synchronized (self) {
        NSString *className = NSStringFromClass(objectClass);
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:className];
        fetchRequest.predicate = predicate;
        
        NSError *error = nil;
        NSArray *managedObjectList = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if([managedObjectList count] > 0){
            return [managedObjectList lastObject];
        }
        
        return nil;
    }
}

- (NSManagedObject *)createManagedObject:(NSString*)kind{
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:kind
                                   inManagedObjectContext:self.managedObjectContext];
    
    NSManagedObject *newEntity = [[NSManagedObject alloc]
                                  initWithEntity:entity
                                  insertIntoManagedObjectContext:self.managedObjectContext];
    
    return newEntity;
}

#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (managedObjectContext != nil)
    {
        return managedObjectContext;
    }
    
    if (storeCoordinator != nil)
    {
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:storeCoordinator];
    }
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil)
    {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"EQModel" withExtension:@"momd"];
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (storeCoordinator != nil)
    {
        return storeCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"model.sqlite"];
    
    NSError *error = nil;
    self.storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return storeCoordinator;
}

#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)contextChanged:(NSNotification*)notification
{
    if ([notification object] == [self managedObjectContext]) return;
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(contextChanged:) withObject:notification waitUntilDone:YES];
        return;
    }
    
    [[self managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
}

@end