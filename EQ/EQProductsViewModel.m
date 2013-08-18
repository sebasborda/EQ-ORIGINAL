//
//  EQProductsViewModel.m
//  EQ
//
//  Created by Sebastian Borda on 4/25/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQProductsViewModel.h"
#import "Articulo.h"
#import "Grupo+extra.h"
 

@interface EQProductsViewModel()

@property (nonatomic, assign) int category1SelectedIndex;
@property (nonatomic, assign) int category2SelectedIndex;
@property (nonatomic, assign) int category3SelectedIndex;
@property (nonatomic, strong) NSString* searchTerm;

@end

@implementation EQProductsViewModel
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        self.searchTerm = nil;
        self.category1SelectedIndex = -1;
        self.category2SelectedIndex = -2;
        self.category3SelectedIndex = -3;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeClientChange:) name:ACTIVE_CLIENT_CHANGE_NOTIFICATION object:nil];
    }
    return self;
}

- (void)activeClientChange:(NSNotification *)notification{
    if ([APP_DELEGATE tabBarController].selectedIndex == EQTabIndexProducts) {
        [self loadData];
    }
}

- (void)releaseUnusedMemory{
    [super releaseUnusedMemory];
    self.articles = nil;
}

- (void)loadDataInBackGround{
    NSMutableArray *subPredicates = [NSMutableArray array];
    if ([self.searchTerm length] > 0) {
        NSString *searchTerm = [self.searchTerm stringByAppendingString:@"*"];
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(SELF.nombre like[cd] %@ || SELF.descripcion like[cd] %@ || SELF.codigo like %@)",searchTerm ,[@"*" stringByAppendingString:searchTerm] ,searchTerm];
        [subPredicates addObject:searchPredicate];
    }
    
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"SELF.parentID == %i", 0];
    self.category1List = [Grupo MR_findAllWithPredicate:categoryPredicate];
    
    if (self.category1SelectedIndex >= 0) {
        Grupo *grupo = [self.category1List objectAtIndex:self.category1SelectedIndex];
        self.category2List = [NSArray arrayWithArray:grupo.subGrupos];
    }
    
    if (self.category2SelectedIndex >= 0) {
        Grupo *grupo = [self.category2List objectAtIndex:self.category2SelectedIndex];
        self.category3List = [NSArray arrayWithArray:grupo.subGrupos];
    }
    
    if (([self.category3List count] == 0 && self.category2SelectedIndex >= 0) || self.category3SelectedIndex >= 0) {
        Grupo *grupo = [self.category3List count] > 0 ? [self.category3List objectAtIndex:self.category3SelectedIndex] : [self.category2List objectAtIndex:self.category2SelectedIndex];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.grupoID == %@",grupo.identifier];
        [subPredicates addObject:predicate];
    }

    NSPredicate *predicate = [subPredicates count] > 0 ? [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates] : nil;
    NSArray *results = [Articulo MR_findAllWithPredicate:predicate];
    self.articles = [NSMutableArray arrayWithArray:results];
    
    [super loadDataInBackGround];
}

- (void)defineSelectedCategory1:(int)categoryIndex{
    self.category1SelectedIndex = categoryIndex;
    self.category2SelectedIndex = -2;
    self.category3SelectedIndex = -3;
}

- (void)defineSelectedCategory2:(int)categoryIndex{
    self.category2SelectedIndex = categoryIndex;
    self.category3SelectedIndex = -3;
}

- (void)defineSelectedCategory3:(int)categoryIndex{
    self.category3SelectedIndex = categoryIndex;
}

- (void)defineSearchTerm:(NSString *)term{
    self.searchTerm = term;
}

- (void)resetFilters{
    self.searchTerm = nil;
    self.category1SelectedIndex = -1;
    self.category2SelectedIndex = -2;
    self.category3SelectedIndex = -3;
    self.category1List = nil;
    self.category2List = nil;
    self.category3List = nil;
    [self loadData];
}

@end
