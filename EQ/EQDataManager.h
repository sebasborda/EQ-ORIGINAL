//
//  EQDataManager.h
//  EQ
//
//  Created by Sebastian Borda on 4/30/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Cliente.h"
#import "Comunicacion.h"
#import "Pedido+extra.h"

@interface EQDataManager : NSObject

+ (EQDataManager *)sharedInstance;
- (void)updateDataShowLoading:(BOOL)show;
- (void)sendClient:(Cliente *)client;
- (void)sendOrder:(Pedido *)order;
- (void)sendCommunication:(Comunicacion *)communication;

//used to debug errors
- (NSString *)ordersToJSon:(NSArray *)orders;

@end
