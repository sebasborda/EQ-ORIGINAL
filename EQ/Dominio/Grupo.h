//
//  Grupo.h
//  EQ
//
//  Created by Sebastian Borda on 6/16/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Grupo : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * parentID;
@property (nonatomic, retain) NSString * nombre;
@property (nonatomic, retain) NSString * descripcion;
@property (nonatomic, retain) NSNumber * count;

@end
