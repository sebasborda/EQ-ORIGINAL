//
//  CatalogoImagen.h
//  EQ
//
//  Created by Sebastian Borda on 10/30/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CatalogoImagen : NSManagedObject

@property (nonatomic, retain) NSString * nombre;
@property (nonatomic, retain) NSString * catalogoID;
@property (nonatomic, retain) NSNumber * pagina;

@end
