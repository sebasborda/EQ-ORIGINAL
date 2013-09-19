//
//  EQOrdersViewModel.h
//  EQ
//
//  Created by Sebastian Borda on 5/15/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewModel.h"
#import "Pedido+extra.h"

@interface EQOrdersViewModel : EQBaseViewModel

@property (nonatomic, strong) NSArray *orders;
@property (nonatomic, strong) NSMutableArray *clientsList;
@property (nonatomic, strong) NSMutableArray *statusList;
@property (nonatomic, strong) NSDate *startBillingDate;
@property (nonatomic, strong) NSDate *endBillingDate;
@property (nonatomic, strong) NSDate *startCreationDate;
@property (nonatomic, strong) NSDate *endCreationDate;
@property (nonatomic, strong) NSArray *sortFields;
@property (nonatomic, assign) id<EQBaseViewModelDelegate> delegate;
@property (nonatomic, strong) NSString* clientName;

- (void)changeSortOrder:(int)index;
- (void)defineClient:(NSString *)client;
- (void)defineStatus:(NSString *)status;
- (void)cancelOrder:(Pedido *)order;
- (BOOL)canCreateOrder;
- (float)total;

@end
