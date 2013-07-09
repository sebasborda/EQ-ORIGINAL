//
//  EQProductsViewModel.h
//  EQ
//
//  Created by Sebastian Borda on 4/25/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewModel.h"

@interface EQProductsViewModel : EQBaseViewModel

@property (nonatomic,assign) id<EQBaseViewModelDelegate> delegate;
@property (nonatomic,strong) NSMutableArray *articles;
@property (nonatomic,strong) NSArray *category1List;
@property (nonatomic,strong) NSArray *category2List;
@property (nonatomic,strong) NSArray *category3List;

- (void)defineSelectedCategory1:(int)categoryIndex;
- (void)defineSelectedCategory2:(int)categoryIndex;
- (void)defineSelectedCategory3:(int)categoryIndex;
- (void)defineSearchTerm:(NSString *)term;
- (void)resetFilters;

@end
