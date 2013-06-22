//
//  EQNewOrderViewModel.h
//  EQ
//
//  Created by Sebastian Borda on 5/18/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewModel.h"
#import "Pedido.h"
#import "Articulo.h"

@protocol EQNewOrderViewModelDelegate <EQBaseViewModelDelegate>

- (void)modelDidAddItem;
- (void)modelAddItemDidFail;

@end

@interface EQNewOrderViewModel : EQBaseViewModel

- (id)initWithOrder:(Pedido *)order;
- (void)loadData;
- (void)save;

@property (nonatomic,assign) id<EQNewOrderViewModelDelegate> delegate;
@property (nonatomic,strong) NSArray *articles;
@property (nonatomic,strong) Pedido *order;
@property (nonatomic,strong) Articulo *articleSelected;
@property (nonatomic,strong) NSArray *group1;
@property (nonatomic,strong) NSArray *group2;
@property (nonatomic,strong) NSArray *categories;

@property (nonatomic,assign) int categorySelected;
@property (nonatomic,assign) int group1Selected;
@property (nonatomic,assign) int group2Selected;

@property (nonatomic,assign) BOOL newOrder;

- (void)defineSelectedCategory:(int)index;
- (void)defineSelectedGroup1:(int)index;
- (void)defineSelectedGroup2:(int)index;
- (void)defineSelectedArticle:(int)index;
- (void)addItemQuantity:(int)quantity;
- (NSNumber *)itemsQuantity;
- (NSNumber *)subTotal;
- (int)discountPercentage;
- (int)discountValue;
- (float)total;
- (NSArray *)items;

@end
