//
//  EQCreateClientViewModel.h
//  EQ
//
//  Created by Sebastian Borda on 5/8/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewModel.h"
#import "Cliente+extra.h"

@interface EQCreateClientViewModel : EQBaseViewModel

@property (nonatomic,weak) id<EQBaseViewModelDelegate> delegate;
@property (nonatomic,strong) NSString *clientID;
@property (nonatomic,strong) Cliente *client;

- (void)loadData;
- (void)saveClient:(NSDictionary *)clientDictionary;
- (NSArray *)obtainProvinces;
- (NSArray *)obtainDeliveryAreaList;
- (NSArray *)obtainExpressList;
- (NSArray *)obtainSellersList;
- (NSArray *)obtainCollectorList;
- (NSArray *)obtainSalesLineList;
- (NSArray *)obtainPaymentConditionList;
- (NSArray *)obtainTaxesList;

- (void)selectedTaxAtIndex:(int)index;
- (void)selectedProvinceAtIndex:(int)index;
- (void)selectedPaymentConditionAtIndex:(int)index;
- (void)selectedCollectorAtIndex:(int)index;
- (void)selectedSellerAtIndex:(int)index;
- (void)selectedSalesLineAtIndex:(int)index;
- (void)selectedDeliveryAreaAtIndex:(int)index;
- (void)selectedExpressAtIndex:(int)index;

- (NSString *)obtainSelectedSeller;
- (NSString *)obtainSelectedCollector;
- (NSString *)obtainSelectedProvince;
- (NSString *)obtainSelectedDeliveryArea;
- (NSString *)obtainSelectedPaymentCondition;
- (NSString *)obtainSelectedExpress;
- (NSString *)obtainSelectedTaxes;
- (NSString *)obtainSelectedSalesLine;

@end
