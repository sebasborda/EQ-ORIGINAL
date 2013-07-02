//
//  EQOrdersViewModel.h
//  EQ
//
//  Created by Sebastian Borda on 5/15/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewModel.h"

@interface EQOrdersViewModel : EQBaseViewModel

@property (nonatomic, strong) NSArray *orders;
@property (nonatomic, strong) NSMutableArray *clientsList;
@property (nonatomic, strong) NSMutableArray *statusList;
@property (nonatomic, strong) NSDate *startBillingDate;
@property (nonatomic, strong) NSDate *endBillingDate;
@property (nonatomic, strong) NSDate *startSyncDate;
@property (nonatomic, strong) NSDate *endSyncDate;
@property (nonatomic,strong) NSArray *sortFields;
@property (nonatomic, strong) id<EQBaseViewModelDelegate> delegate;

- (void)loadData;
- (void)changeSortOrder:(int)index;
- (void)defineClient:(NSString *)client;
- (void)defineStatus:(NSString *)status;
- (void)cancelOrder:(Pedido *)order;
- (float)total;

@end
