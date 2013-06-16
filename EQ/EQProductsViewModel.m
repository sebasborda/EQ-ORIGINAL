//
//  EQProductsViewModel.m
//  EQ
//
//  Created by Sebastian Borda on 4/25/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQProductsViewModel.h"
#import "Articulo.h"

@interface EQProductsViewModel()

@property (nonatomic, assign) int category1SelectedIndex;
@property (nonatomic, assign) int category2SelectedIndex;
@property (nonatomic, assign) int category3SelectedIndex;
@property (nonatomic, strong) NSString* searchTerm;

@end

@implementation EQProductsViewModel
@synthesize delegate;

- (void)loadData{
    [self.delegate modelWillStartDataLoading];
    EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
    NSMutableArray *subPredicates = [NSMutableArray array];
    if (self.category1SelectedIndex > 0) {
        NSPredicate *subPredicate = [NSPredicate predicateWithFormat:@"categoria1 = %@", [self.category1List objectAtIndex:self.category1SelectedIndex]];
        [subPredicates addObject:subPredicate];
    }
    
    if (self.category2SelectedIndex > 0) {
        NSPredicate *subPredicate = [NSPredicate predicateWithFormat:@"categoria2 = %@", [self.category2List objectAtIndex:self.category2SelectedIndex]];
        [subPredicates addObject:subPredicate];
    }
    
    if (self.category3SelectedIndex > 0) {
        NSPredicate *subPredicate = [NSPredicate predicateWithFormat:@"categoria3 = %@", [self.category3List objectAtIndex:self.category3SelectedIndex]];
        [subPredicates addObject:subPredicate];
    }
    
    if ([self.searchTerm length] > 0) {
        
        NSString *searchTerm = [self.searchTerm stringByAppendingString:@"*"];
        NSPredicate *subPredicate = [NSPredicate predicateWithFormat:@"(SELF.nombre like[cd] %@ || SELF.descripcion like[cd] %@ || SELF.codigo like %@)",searchTerm ,[@"*" stringByAppendingString:searchTerm] ,searchTerm];
        [subPredicates addObject:subPredicate];
    }

    NSPredicate *predicate = [subPredicates count] > 0 ? [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates] : nil;
    NSArray *results = [adl objectListForClass:[Articulo class] filterByPredicate:predicate];
    self.articles = [NSMutableArray arrayWithArray:results];
    
    [self.delegate modelDidUpdateData];
}

- (void)defineSelectedCategory1:(int)categoryIndex{
    self.category1SelectedIndex = categoryIndex;
}

- (void)defineSelectedCategory2:(int)categoryIndex{
    self.category2SelectedIndex = categoryIndex;
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
    [self loadData];
}

@end
