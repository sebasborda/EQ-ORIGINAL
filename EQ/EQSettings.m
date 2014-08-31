//
//  EQSettings.m
//  EQ
//
//  Created by Sebastian Borda on 1/11/14.
//  Copyright (c) 2014 Sebastian Borda. All rights reserved.
//

#define DEFAULT_PRICE_LIST @"defaultPriceList"
#define SERVER_ENVIROMENT @"serverEnviroment"


#import "EQSettings.h"

@implementation EQSettings

-(void)setDefaultPriceList:(NSString *)defaultPriceList {
    [[NSUserDefaults standardUserDefaults] setObject:defaultPriceList forKey:DEFAULT_PRICE_LIST];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)defaultPriceList {
    return [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_PRICE_LIST];
}

-(void)setEnviroment:(NSString *)enviroment {
    [[NSUserDefaults standardUserDefaults] setObject:enviroment forKey:SERVER_ENVIROMENT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)enviroment {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SERVER_ENVIROMENT];
}

@end
