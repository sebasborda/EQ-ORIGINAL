//
//  CondPag.h
//  EQ
//
//  Created by Sebastian Borda on 5/24/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Cliente;

@interface CondPag : NSManagedObject

@property (nonatomic, retain) NSNumber * activo;
@property (nonatomic, retain) NSString * codigo;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * descripcion;
@property (nonatomic, retain) NSSet *cliente;
@end

@interface CondPag (CoreDataGeneratedAccessors)

- (void)addClienteObject:(Cliente *)value;
- (void)removeClienteObject:(Cliente *)value;
- (void)addCliente:(NSSet *)values;
- (void)removeCliente:(NSSet *)values;

@end
