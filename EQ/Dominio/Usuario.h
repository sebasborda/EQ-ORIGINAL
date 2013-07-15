//
//  Usuario.h
//  EQ
//
//  Created by Sebastian Borda on 7/13/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Usuario : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * nombre;
@property (nonatomic, retain) NSString * nombreDeUsuario;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * vendedorID;

@end
