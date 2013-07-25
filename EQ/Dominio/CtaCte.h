//
//  CtaCte.h
//  EQ
//
//  Created by Sebastian Borda on 7/24/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CtaCte : NSManagedObject

@property (nonatomic, retain) NSNumber * clienteID;
@property (nonatomic, retain) NSString * comprobante;
@property (nonatomic, retain) NSString * condicionDeVenta;
@property (nonatomic, retain) NSString * empresa;
@property (nonatomic, retain) NSDate * fecha;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * importe;
@property (nonatomic, retain) NSNumber * importeConDescuento;
@property (nonatomic, retain) NSNumber * importePercepcion;
@property (nonatomic, retain) NSNumber * vendedorID;

@end
