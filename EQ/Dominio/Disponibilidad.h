//
//  Disponibilidad.h
//  EQ
//
//  Created by Sebastian Borda on 6/28/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Disponibilidad : NSManagedObject

@property (nonatomic, retain) NSString * descripcion;
@property (nonatomic, retain) NSNumber * identifier;

@end
