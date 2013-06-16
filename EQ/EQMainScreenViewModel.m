//
//  EQMainScreenViewModel.m
//  EQ
//
//  Created by Sebastian Borda on 4/19/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQMainScreenViewModel.h"
#import "EQSession.h"
#import "Usuario.h"
#import "Cliente.h"
@implementation EQMainScreenViewModel

- (void)loadData{
    [self.delegate modelWillStartDataLoading];
    NSArray *results = [[EQSession sharedInstance].user.vendedor.clienteVendedor allObjects];
    results = [results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier > 0"]];
    self.clients = [results sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]]];
    [self.delegate modelDidUpdateData];
}

- (NSString *)loggedUserName{
    return [[self sellerName] uppercaseString];
}

- (void)selectClientAtIndex:(NSUInteger)index{
    Cliente *client = [self.clients objectAtIndex:index];
    [EQSession sharedInstance].selectedClient = client;
}

- (NSArray *)clientsNameList{
    NSMutableArray *names = [NSMutableArray array];
    for (Cliente *client in self.clients) {
        [names addObject:client.nombre];
    }
    
    return names;
}

@end
