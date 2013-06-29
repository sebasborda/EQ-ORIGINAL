//
//  Cliente.h
//  EQ
//
//  Created by Sebastian Borda on 6/28/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CtaCte, Pedido, Vendedor;

@interface Cliente : NSManagedObject

@property (nonatomic, retain) NSNumber * activo;
@property (nonatomic, retain) NSNumber * actualizado;
@property (nonatomic, retain) NSString * codigo1;
@property (nonatomic, retain) NSString * codigo2;
@property (nonatomic, retain) NSString * codigoPostal;
@property (nonatomic, retain) NSString * cuit;
@property (nonatomic, retain) NSNumber * descuento1;
@property (nonatomic, retain) NSNumber * descuento2;
@property (nonatomic, retain) NSNumber * descuento3;
@property (nonatomic, retain) NSNumber * descuento4;
@property (nonatomic, retain) NSString * diasDePago;
@property (nonatomic, retain) NSString * domicilio;
@property (nonatomic, retain) NSString * domicilioDeEnvio;
@property (nonatomic, retain) NSString * encCompras;
@property (nonatomic, retain) NSString * horario;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * latitud;
@property (nonatomic, retain) NSString * localidad;
@property (nonatomic, retain) NSString * longitud;
@property (nonatomic, retain) NSString * mail;
@property (nonatomic, retain) NSString * nombre;
@property (nonatomic, retain) NSString * nombreDeFantasia;
@property (nonatomic, retain) NSString * observaciones;
@property (nonatomic, retain) NSString * propietario;
@property (nonatomic, retain) NSNumber * sucursal;
@property (nonatomic, retain) NSString * telefono;
@property (nonatomic, retain) NSString * web;
@property (nonatomic, retain) NSNumber * ivaID;
@property (nonatomic, retain) NSNumber * condicionDePagoID;
@property (nonatomic, retain) NSNumber * expresoID;
@property (nonatomic, retain) NSNumber * lineaDeVentaID;
@property (nonatomic, retain) NSNumber * provinciaID;
@property (nonatomic, retain) NSNumber * zonaEnvioID;
@property (nonatomic, retain) Vendedor *cobrador;
@property (nonatomic, retain) NSSet *ctaCte;
@property (nonatomic, retain) NSSet *pedidos;
@property (nonatomic, retain) Vendedor *vendedor;
@end

@interface Cliente (CoreDataGeneratedAccessors)

- (void)addCtaCteObject:(CtaCte *)value;
- (void)removeCtaCteObject:(CtaCte *)value;
- (void)addCtaCte:(NSSet *)values;
- (void)removeCtaCte:(NSSet *)values;

- (void)addPedidosObject:(Pedido *)value;
- (void)removePedidosObject:(Pedido *)value;
- (void)addPedidos:(NSSet *)values;
- (void)removePedidos:(NSSet *)values;

@end
