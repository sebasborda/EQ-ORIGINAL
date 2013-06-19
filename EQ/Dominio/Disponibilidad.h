//
//  Disponibilidad.h
//  EQ
//
//  Created by Sebastian Borda on 6/17/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Articulo;

@interface Disponibilidad : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * descripcion;
@property (nonatomic, retain) NSSet *articulos;
@end

@interface Disponibilidad (CoreDataGeneratedAccessors)

- (void)addArticulosObject:(Articulo *)value;
- (void)removeArticulosObject:(Articulo *)value;
- (void)addArticulos:(NSSet *)values;
- (void)removeArticulos:(NSSet *)values;

@end
