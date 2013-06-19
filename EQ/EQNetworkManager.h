//
//  EQNetworkManager.h
//  EQ
//
//  Created by Sebastian Borda on 4/25/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQRequest.h"

@interface EQNetworkManager : NSObject

+ (void)makeRequest:(EQRequest *)request;
+ (void)makeRequest:(EQRequest *)request showLoading:(BOOL)show;

@end
