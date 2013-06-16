//
//  EQBaseViewModel.m
//  EQ
//
//  Created by Sebastian Borda on 4/14/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewModel.h"
#import "EQSession.h"
#import "Usuario.h"
#import "Vendedor.h"


@implementation EQBaseViewModel

- (NSString *)sellerName{
    
    return [EQSession sharedInstance].user.vendedor ? [EQSession sharedInstance].user.vendedor.descripcion : [EQSession sharedInstance].user.nombre;
}

- (NSString *)lastUpdateWithFormat{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yy | HH:mm"];
    return  [NSString stringWithFormat:@"%@ hs.",[dateFormat stringFromDate:[[EQSession sharedInstance] lastSyncDate]]];
}

- (NSString *)currentDateWithFormat{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yy"];
    return  [dateFormat stringFromDate:[NSDate date]];
}

- (NSString *)clientName{
    return [EQSession sharedInstance].selectedClient.nombre;
}

- (NSString *)clientStatus{
    return @"Cliente activo";
}

- (Cliente *)ActiveClient{
    return [EQSession sharedInstance].selectedClient;
}

@end
