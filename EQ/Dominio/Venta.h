//
//  Venta.h
//  EQ
//
//  Created by Sebastian Borda on 6/24/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Articulo, Cliente, Vendedor;

@interface Venta : NSManagedObject

@property (nonatomic, retain) NSNumber * actualizado;
@property (nonatomic, retain) NSNumber * cantidad;
@property (nonatomic, retain) NSString * comprobante;
@property (nonatomic, retain) NSString * empresa;
@property (nonatomic, retain) NSDate * fecha;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * importe;
@property (nonatomic, retain) Articulo * articulo;
@property (nonatomic, retain) Cliente * cliente;
@property (nonatomic, retain) Vendedor * vendedor;

@end
