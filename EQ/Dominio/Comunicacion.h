//
//  Comunicacion.h
//  EQ
//
//  Created by Sebastian Borda on 7/6/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Comunicacion : NSManagedObject

@property (nonatomic, retain) NSNumber * activo;
@property (nonatomic, retain) NSNumber * actualizado;
@property (nonatomic, retain) NSNumber * clienteID;
@property (nonatomic, retain) NSNumber * codigoSerial;
@property (nonatomic, retain) NSString * descripcion;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSDate * leido;
@property (nonatomic, retain) NSNumber * receiverID;
@property (nonatomic, retain) NSNumber * senderID;
@property (nonatomic, retain) NSNumber * threadID;
@property (nonatomic, retain) NSString * tipo;
@property (nonatomic, retain) NSString * titulo;
@property (nonatomic, retain) NSDate * creado;

@end
