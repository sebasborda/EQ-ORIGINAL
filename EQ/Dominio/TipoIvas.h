//
//  TipoIvas.h
//  EQ
//
//  Created by Sebastian Borda on 6/16/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Cliente;

@interface TipoIvas : NSManagedObject

@property (nonatomic, retain) NSNumber * activo;
@property (nonatomic, retain) NSString * codigo;
@property (nonatomic, retain) NSString * descripcion;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSSet *clientes;
@end

@interface TipoIvas (CoreDataGeneratedAccessors)

- (void)addClientesObject:(Cliente *)value;
- (void)removeClientesObject:(Cliente *)value;
- (void)addClientes:(NSSet *)values;
- (void)removeClientes:(NSSet *)values;

@end
