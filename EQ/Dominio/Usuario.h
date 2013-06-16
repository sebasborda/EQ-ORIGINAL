//
//  Usuario.h
//  EQ
//
//  Created by Sebastian Borda on 5/1/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Vendedor;

@interface Usuario : NSManagedObject

@property (nonatomic, retain) NSString * nombreDeUsuario;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * nombre;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) Vendedor *vendedor;

@end
