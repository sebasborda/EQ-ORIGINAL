//
//  EQCatalogViewModel.m
//  EQ
//
//  Created by Sebastian Borda on 10/26/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQCatalogViewModel.h"
#import "EQDataAccessLayer.h"
#import "Catalogo+extra.h"
#import "EQDataManager.h"

@implementation EQCatalogViewModel

- (void)loadDataInBackGround{
    EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
    self.catalogs = [adl objectListForClass:[Catalogo class] filterByPredicate:nil sortBy:[NSSortDescriptor sortDescriptorWithKey:@"posicion" ascending:YES] limit:0];

    NSDictionary *dictionary = [[EQDataManager sharedInstance] obtainLastUpdateFor:[Catalogo class] needIncludeUser:NO];
    NSString *dateString = [dictionary objectForKey:@"timestamp"];
    dateString = [dateString stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateString];

    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    self.lastUpdate = [dateFormatter stringFromDate:date];

    [super loadDataInBackGround];
}

@end
