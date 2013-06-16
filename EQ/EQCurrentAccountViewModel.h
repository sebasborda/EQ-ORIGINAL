//
//  EQCurrentAccountViewModel.h
//  EQ
//
//  Created by Sebastian Borda on 5/12/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewModel.h"

@interface EQCurrentAccountViewModel : EQBaseViewModel

@property (nonatomic,strong) NSArray *currentAccountList;
@property (nonatomic,strong) NSArray *sortFields;
@property (nonatomic,weak) id<EQBaseViewModelDelegate> delegate;
@property (nonatomic,assign) BOOL grouped;

- (void)loadData;
- (void)changeSortOrder:(int)index;
- (NSArray *)clients;
- (NSArray *)localities;
- (NSArray *)companies;
- (NSArray *)totals;
- (void)filterByCompany:(NSString *)company;
- (void)filterBylocality:(NSString *)locality;
- (void)filterByClient:(NSString *)client;
- (NSDictionary *)resume;

@end
