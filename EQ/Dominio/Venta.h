//
//  Venta.h
//  EQ
//
//  Created by Sebastian Borda on 8/11/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Venta : NSManagedObject

@property (nonatomic, retain) NSNumber * actualizado;
@property (nonatomic, retain) NSNumber * articuloID;
@property (nonatomic, retain) NSNumber * cantidad;
@property (nonatomic, retain) NSNumber * clienteID;
@property (nonatomic, retain) NSString * comprobante;
@property (nonatomic, retain) NSString * empresa;
@property (nonatomic, retain) NSDate * fecha;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * importe;
@property (nonatomic, retain) NSNumber * vendedorID;
@property (nonatomic, retain) NSNumber * activo;

@end
