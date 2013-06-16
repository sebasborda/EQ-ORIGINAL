//
//  EQSession.h
//  EQ
//
//  Created by Sebastian Borda on 4/25/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Vendedor.h"

@interface EQSession : NSObject

+ (EQSession *)sharedInstance;
- (NSDate *)lastSyncDate;
- (void)regiteredUser:(Usuario *)user;
- (void)endSession;
- (void)dataUpdated;

@property (nonatomic,strong) Cliente *selectedClient;
@property (nonatomic,strong) Usuario* user;

@end
