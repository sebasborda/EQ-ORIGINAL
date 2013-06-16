//
//  EQDataManager.h
//  EQ
//
//  Created by Sebastian Borda on 4/30/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Cliente.h"

@interface EQDataManager : NSObject

+ (EQDataManager *)sharedInstance;
- (void)updateData;
- (void)sendClient:(Cliente *)client;
@end
