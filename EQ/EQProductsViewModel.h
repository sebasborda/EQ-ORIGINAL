//
//  EQProductsViewModel.h
//  EQ
//
//  Created by Sebastian Borda on 4/25/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewModel.h"
@class Grupo;

typedef enum {
    typeListNone,
    typeListGroup,
    typeListProduct
} typeList;

@protocol EQProductsViewModelDelegate;

@interface EQProductsViewModel : EQBaseViewModel

- (id)initWithCategory:(Grupo *)category;

@property (nonatomic,assign) id<EQProductsViewModelDelegate> delegate;
@property (nonatomic,strong) NSArray *articles;
@property (nonatomic,strong) NSArray *category1List;
@property (nonatomic,strong) NSArray *category2List;
@property (nonatomic,strong) NSArray *category3List;
@property (nonatomic,assign) typeList typeList;

- (void)defineSelectedCategory1:(int)categoryIndex;
- (void)defineSelectedCategory2:(int)categoryIndex;
- (void)defineSelectedCategory3:(int)categoryIndex;
- (void)defineSearchTerm:(NSString *)term;
- (void)resetFilters;
- (NSString *)imageForCategory2;

@end

@protocol EQProductsViewModelDelegate <EQBaseViewModelDelegate>

- (void)changeCategory1Selected:(NSString *)category;
- (void)changeCategory2Selected:(NSString *)category;
- (void)changeCategory3Selected:(NSString *)category;

@end
