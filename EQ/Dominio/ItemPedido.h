//
//  ItemPedido.h
//  EQ
//
//  Created by Sebastian Borda on 6/29/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Pedido;

@interface ItemPedido : NSManagedObject

@property (nonatomic, retain) NSNumber * articuloID;
@property (nonatomic, retain) NSNumber * cantidad;
@property (nonatomic, retain) NSNumber * descuento1;
@property (nonatomic, retain) NSNumber * descuento2;
@property (nonatomic, retain) NSNumber * descuentoMonto;
@property (nonatomic, retain) NSNumber * importeConDescuento;
@property (nonatomic, retain) NSNumber * importeFinal;
@property (nonatomic, retain) NSNumber * precioUnitario;
@property (nonatomic, retain) Pedido *pedido;

@end
