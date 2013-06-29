//
//  Precio.h
//  EQ
//
//  Created by Sebastian Borda on 6/28/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Precio : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * importe;
@property (nonatomic, retain) NSString * numero;
@property (nonatomic, retain) NSNumber * articuloID;

@end
