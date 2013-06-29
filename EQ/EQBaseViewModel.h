//
//  EQBaseViewModel.h
//  EQ
//
//  Created by Sebastian Borda on 4/14/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQDataAccessLayer.h"
#import "Cliente.h"

@protocol EQBaseViewModelDelegate;

@interface EQBaseViewModel : NSObject

- (NSString *)sellerName;
- (NSString *)lastUpdateWithFormat;
- (NSString *)currentDateWithFormat;
- (NSString *)clientName;
- (NSString *)clientStatus;
- (Cliente *)ActiveClient;
- (Vendedor *)currentSeller;

@end

@protocol EQBaseViewModelDelegate <NSObject>

- (void)modelDidUpdateData;
- (void)modelDidFinishWithError:(NSError *)error;
- (void)modelWillStartDataLoading;

@end
