//
//  EQSalesViewModel.m
//  EQ
//
//  Created by Sebastian Borda on 6/22/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQSalesViewModel.h"
#import "Venta.h"
#import "Grupo.h"

@interface EQSalesViewModel()

@property (nonatomic, strong) NSSortDescriptor *sortDescriptor;
@property (nonatomic, strong) NSString *clientName;
@property (nonatomic, strong) Grupo *group;
@property (nonatomic, strong) NSArray *groupsList;
@property (nonatomic, strong) NSArray *originalSalesList;
@end

@implementation EQSalesViewModel

- (id)init
{
    self = [super init];
    if (self) {
        self.sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[self salesFieldByIndex:1] ascending:YES];
        self.sortFields = [NSArray arrayWithObjects:@"  Periodo", @"  Cliente", @"  Articulo/Grupo", @"  Cantidad", @"  Importe", nil];
        self.clientName = self.ActiveClient.nombre;
    }
    return self;
}

- (void)initializeData{
    self.groupsList = [[EQDataAccessLayer sharedInstance] objectListForClass:[Grupo class]];
    self.originalSalesList = [[EQDataAccessLayer sharedInstance] objectListForClass:[Venta class]];
}

- (NSString *)salesFieldByIndex:(int)index{
    switch (index) {
        case 0:
            return @"fecha";
            break;
        case 1:
            return @"cliente.nombre";
            break;
        case 2:
            return @"articulo.grupoID"; //TODO: arreglar esto
            break;
        case 3:
            return @"cantidad";
            break;
        case 4:
            return @"importe";
            break;
        default:
            return @"cliente.nombre";
            break;
    }
}

- (BOOL)isSortingByClient {
    return [self.sortDescriptor.key isEqualToString:@"cliente.nombre"];
}

- (void)loadData{
    [self.delegate modelWillStartDataLoading];
    self.salesList = [self.originalSalesList copy];
    NSMutableArray *subPredicates = [NSMutableArray new];
    if (self.clientName) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.cliente.nombre == %@",self.clientName];
        [subPredicates addObject:predicate];
    }
    
    if (self.group) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.articulo.grupoID == %@",self.group.identifier];
        [subPredicates addObject:predicate];
    }
    
    if ([subPredicates count] > 0) {
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        self.salesList = [self.salesList filteredArrayUsingPredicate:predicate];
    }
    
    NSArray *result = [self.salesList sortedArrayUsingDescriptors:[NSArray arrayWithObject:self.sortDescriptor]];
    NSMutableArray *sales = [NSMutableArray new];
    self.onlySubTotalAvailable = [self isSortingByClient] && !self.ActiveClient;
    if([self isSortingByClient]){
        Cliente *lastClient = nil;
        NSMutableArray *currentArray = nil;
        for (Venta *sale in result) {
            if (![lastClient.identifier isEqualToNumber:sale.cliente.identifier] || [sales count] == 0) {
                currentArray = [NSMutableArray new];
                [sales addObject:currentArray];
            } else {
                currentArray = [sales lastObject];
            }
            
            lastClient = sale.cliente;
            [currentArray addObject:sale];
        }
    } else {
        [sales addObject:result];
    }
    
    self.salesList = sales;
    [self.delegate modelDidUpdateData];
}

- (void)changeSortOrder:(int)index{
    BOOL ascending = true;
    self.sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[self salesFieldByIndex:index] ascending:ascending];
    [self loadData];
}

- (NSArray *)clients{
    NSMutableArray *array = [NSMutableArray array];
    if(self.ActiveClient){
        [array addObject:@"Todos"];
        [array addObject:self.ActiveClient.nombre];
    } else {
        for (NSArray *list in self.salesList) {
            for (Venta *sale in list) {
                if (![array containsObject:sale.cliente.nombre] && sale.cliente.nombre) {
                    [array addObject:sale.cliente.nombre];
                }
            }
        }
        array = [NSMutableArray arrayWithArray:[array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        [array insertObject:[self.salesList count] > 0 ? @"Todos" : @"No hay datos" atIndex:0];
    }
    
    return array;
}

- (NSArray *)groupsName{
    NSMutableArray *array = [NSMutableArray array];
    for (Grupo *group in self.groupsList) {
        [array addObject:group.nombre];
    }
    
    array = [NSMutableArray arrayWithArray:[array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    [array insertObject:[array count] > 0 ? @"Todas" : @"No hay datos" atIndex:0];
    
    return array;
}

- (NSArray *)totals{
    return [NSArray arrayWithObjects:@"Todo", @"Subtotal", nil];
}

- (void)filterByClient:(NSString *)client{
    if (![client isEqualToString:@"Todos"] && ![client isEqual:@"No hay datos"]) {
        self.clientName = client;
    } else {
        self.clientName = nil;
    }
    [self loadData];
}

- (void)filterByGroup:(NSString *)Group{
    if (![Group isEqualToString:@"Todas"] && ![Group isEqual:@"No hay datos"]) {
        self.Group = (Grupo *)[[EQDataAccessLayer sharedInstance] objectForClass:[Grupo class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.nombre == %@",Group]];
    } else {
        self.Group = nil;
    }
    [self loadData];
}

@end
