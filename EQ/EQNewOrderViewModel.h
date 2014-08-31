//
//  EQNewOrderViewModel.h
//  EQ
//
//  Created by Sebastian Borda on 5/18/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewModel.h"
#import "Pedido+extra.h"
#import "Articulo+extra.h"

@protocol EQNewOrderViewModelDelegate <EQBaseViewModelDelegate>

- (void)modelDidAddItem;
- (void)modelAddItemDidFail;
- (void)articleUnavailable:(NSString *)message;

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

@property (nonatomic,assign) NSUInteger categorySelected;
@property (nonatomic,assign) NSUInteger group1Selected;
@property (nonatomic,assign) NSUInteger group2Selected;
@property (nonatomic,assign) NSUInteger articleSelectedIndex;

@property (nonatomic,assign) BOOL newOrder;

- (void)defineSelectedCategory:(NSUInteger)index;
- (void)defineSelectedGroup1:(NSUInteger)index;
- (void)defineSelectedGroup2:(NSUInteger)index;
- (void)defineSelectedArticle:(NSUInteger)index;
- (void)defineOrderStatus:(NSUInteger)index;
- (BOOL)addItemQuantity:(NSUInteger)quantity;
- (NSNumber *)itemsQuantity;
- (NSNumber *)subTotal;
- (float)discountPercentage;
- (float)discountValue;
- (float)total;
- (NSArray *)items;
- (int)orderStatusIndex;
- (NSDate *)date;
- (void)removeItem:(ItemPedido *)item;
- (void)editItem:(ItemPedido *)item;
- (NSNumber *)quantityOfCurrentArticle;
- (void)cancelOrder;
- (void)sortArticlesByIndex:(NSUInteger)index;
- (void)sortGroup2ByIndex:(NSUInteger)index;
- (void)sortGroup1ByIndex:(NSUInteger)index;

- (NSString *)orderHTML;

@end
