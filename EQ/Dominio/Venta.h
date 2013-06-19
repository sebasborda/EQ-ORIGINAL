//
//  Venta.h
//  EQ
//
//  Created by Sebastian Borda on 6/16/13.
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
@property (nonatomic, retain) NSSet *articulos;
@property (nonatomic, retain) Cliente *cliente;
@property (nonatomic, retain) Vendedor *vendedor;
@end

@interface Venta (CoreDataGeneratedAccessors)

- (void)addArticulosObject:(Articulo *)value;
- (void)removeArticulosObject:(Articulo *)value;
- (void)addArticulos:(NSSet *)values;
- (void)removeArticulos:(NSSet *)values;

@end
