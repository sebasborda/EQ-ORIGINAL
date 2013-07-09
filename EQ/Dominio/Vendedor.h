//
//  Vendedor.h
//  EQ
//
//  Created by Sebastian Borda on 7/3/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Cliente, Usuario;

@interface Vendedor : NSManagedObject

@property (nonatomic, retain) NSNumber * activo;
@property (nonatomic, retain) NSString * codigo;
@property (nonatomic, retain) NSString * descripcion;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSSet *clienteCobrador;
@property (nonatomic, retain) NSSet *clienteVendedor;
@property (nonatomic, retain) Usuario *usuario;
@end

@interface Vendedor (CoreDataGeneratedAccessors)

- (void)addClienteCobradorObject:(Cliente *)value;
- (void)removeClienteCobradorObject:(Cliente *)value;
- (void)addClienteCobrador:(NSSet *)values;
- (void)removeClienteCobrador:(NSSet *)values;

- (void)addClienteVendedorObject:(Cliente *)value;
- (void)removeClienteVendedorObject:(Cliente *)value;
- (void)addClienteVendedor:(NSSet *)values;
- (void)removeClienteVendedor:(NSSet *)values;

@end
