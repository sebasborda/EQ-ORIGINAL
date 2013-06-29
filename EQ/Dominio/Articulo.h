//
//  Articulo.h
//  EQ
//
//  Created by Sebastian Borda on 6/28/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemPedido;

@interface Articulo : NSManagedObject

@property (nonatomic, retain) NSNumber * activo;
@property (nonatomic, retain) NSNumber * cantidadPredeterminada;
@property (nonatomic, retain) NSString * codigo;
@property (nonatomic, retain) NSDate * creado;
@property (nonatomic, retain) NSString * descripcion;
@property (nonatomic, retain) NSNumber * grupoID;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * imagenURL;
@property (nonatomic, retain) NSNumber * minimoPedido;
@property (nonatomic, retain) NSDate * modificado;
@property (nonatomic, retain) NSNumber * multiploPedido;
@property (nonatomic, retain) NSString * nombre;
@property (nonatomic, retain) NSString * tipo;
@property (nonatomic, retain) NSNumber * disponibilidadID;
@property (nonatomic, retain) NSSet *itemsPedido;
@end

@interface Articulo (CoreDataGeneratedAccessors)

- (void)addItemsPedidoObject:(ItemPedido *)value;
- (void)removeItemsPedidoObject:(ItemPedido *)value;
- (void)addItemsPedido:(NSSet *)values;
- (void)removeItemsPedido:(NSSet *)values;

@end
