//
//  ItemPedido.h
//  EQ
//
//  Created by Sebastian Borda on 6/16/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Articulo, Pedido;

@interface ItemPedido : NSManagedObject

@property (nonatomic, retain) NSNumber * cantidad;
@property (nonatomic, retain) Articulo *articulo;
@property (nonatomic, retain) Pedido *pedido;

@end
