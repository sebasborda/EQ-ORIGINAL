//
//  EQCurrentAccountViewModel.m
//  EQ
//
//  Created by Sebastian Borda on 5/12/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQCurrentAccountViewModel.h"
#import "EQDataAccessLayer.h"
#import "CtaCte.h"
#import "Cliente.h"
#import "Vendedor+extra.h"

@interface EQCurrentAccountViewModel()

@property (nonatomic, strong) NSSortDescriptor *sortDescriptor;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *locality;

@end

@implementation EQCurrentAccountViewModel

- (id)init
{
    self = [super init];
    if (self) {
        self.sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[self ctaCteFieldByIndex:1] ascending:YES];
        self.sortFields = [NSArray arrayWithObjects:@"  Cliente", @"  Fecha", @"  Atraso", @"  Comprobante", @"  Percepcion", @"  Importe", nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeClientChange:) name:ACTIVE_CLIENT_CHANGE_NOTIFICATION object:nil];
        if (self.ActiveClient) {
            self.clientName = self.ActiveClient.nombre;
        }
    }
    return self;
}

- (void)activeClientChange:(NSNotification *)notification{
    Cliente *activeCliente = notification.userInfo[@"activeClient"];
    self.clientName = activeCliente.nombre;
    if ([APP_DELEGATE tabBarController].selectedIndex == EQTabIndexCurrentAccount) {
        [self loadData];
    }
}

- (NSString *)ctaCteFieldByIndex:(int)index{
    switch (index) {
        case 0:
            return @"cliente.nombre";
            break;
        case 1:
            return @"fecha";
            break;
        case 2:
            return @"diasDeAtraso";
            break;
        case 3:
            return @"comprobante";
            break;
        case 4:
            return @"importePercepcion";
            break;
        case 5:
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

- (void)chargeData{
    self.currentAccountList = [NSArray arrayWithArray:self.currentSeller.ctacteList];
    NSMutableArray *subPredicates = [NSMutableArray new];
    if (self.clientName) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.cliente.nombre == %@",self.clientName];
        [subPredicates addObject:predicate];
    }
    
    if (self.company) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.empresa == %@",self.company];
        [subPredicates addObject:predicate];
    }
    
    if (self.locality) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.cliente.localidad == %@",self.locality];
        [subPredicates addObject:predicate];
    }
    
    if ([subPredicates count] > 0) {
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        self.currentAccountList = [self.currentAccountList filteredArrayUsingPredicate:predicate];
    }
    
    NSArray *result = [self.currentAccountList sortedArrayUsingDescriptors:[NSArray arrayWithObject:self.sortDescriptor]];
    NSMutableArray *accounts = [NSMutableArray new];
    self.onlySubTotalAvailable = [self isSortingByClient] && !self.ActiveClient;
    if([self isSortingByClient]){
        Cliente *lastClient = nil;
        NSMutableArray *currentArray = nil;
        for (CtaCte *ctacte in result) {
            if (![lastClient.identifier isEqualToNumber:ctacte.cliente.identifier] || [accounts count] == 0) {
                currentArray = [NSMutableArray new];
                [accounts addObject:currentArray];
            } else {
                currentArray = [accounts lastObject];
            }
            
            lastClient = ctacte.cliente;
            [currentArray addObject:ctacte];
        }
    } else {
        [accounts addObject:result];
    }
    
    self.currentAccountList = accounts;
}

- (void)loadDataInBackGround{
    [self chargeData];
    [super loadDataInBackGround];
}

- (void)changeSortOrder:(int)index{
    BOOL ascending = index != 2;// if is not delay (Atraso)
    self.sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[self ctaCteFieldByIndex:index] ascending:ascending];
    [self loadData];
}

- (NSArray *)clients{
    NSMutableArray *array = [NSMutableArray array];
    if(self.ActiveClient){
        [array addObject:@"Todos"];
        [array addObject:self.ActiveClient.nombre];
    } else {
        for (NSArray *list in self.currentAccountList) {
            for (CtaCte *ctacte in list) {
                if (![array containsObject:ctacte.cliente.nombre] && ctacte.cliente.nombre) {
                    [array addObject:ctacte.cliente.nombre];
                }
            }
        }
        array = [NSMutableArray arrayWithArray:[array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        [array insertObject:[self.currentAccountList count] > 0 ? @"Todos" : @"No hay datos" atIndex:0];
    }
    
    return array;
}

- (NSArray *)localities{
    NSMutableArray *array = [NSMutableArray array];
    for (NSArray *list in self.currentAccountList) {
        for (CtaCte *ctacte in list) {
            if (![array containsObject:ctacte.cliente.localidad] && ctacte.cliente.localidad) {
                [array addObject:ctacte.cliente.localidad];
            }
        }
    }
    array = [NSMutableArray arrayWithArray:[array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    [array insertObject:[self.currentAccountList count] > 0 ? @"Todas" : @"No hay datos" atIndex:0];
    
    return array;
}

- (NSArray *)companies{
    NSMutableArray *array = [NSMutableArray array];
    for (NSArray *list in self.currentAccountList) {
        for (CtaCte *ctacte in list) {
            if (![array containsObject:ctacte.empresa] && ctacte.empresa) {
                [array addObject:ctacte.empresa];
            }
        }
    }
    
    array = [NSMutableArray arrayWithArray:[array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    [array insertObject:[self.currentAccountList count] > 0 ? @"Todas" : @"No hay datos" atIndex:0];
    
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

- (void)filterByCompany:(NSString *)company{
    if (![company isEqualToString:@"Todas"] && ![company isEqual:@"No hay datos"]) {
        self.company = company;
    } else {
        self.company = nil;
    }
    [self loadData];
}

- (void)filterBylocality:(NSString *)locality{
    if (![locality isEqualToString:@"Todas"] && ![locality isEqual:@"No hay datos"]) {
        self.locality = locality;
    } else {
        self.locality = nil;
    }
    [self loadData];
}

- (NSDictionary *)resume{
    NSMutableDictionary *resumeDictionary = [NSMutableDictionary new];
    float total = 0;
    int thirtyDays = 0;
    int fortyDays = 0;
    int ninetyDays = 0;
    int more90Days = 0;
    for (CtaCte* account in [NSArray arrayWithArray:self.currentSeller.ctacteList]) {
        if ([account.condicionDeVenta integerValue] <= 30) {
            thirtyDays += [account.importeConDescuento floatValue];
        } else if ([account.condicionDeVenta integerValue] <= 45) {
            fortyDays += [account.importeConDescuento floatValue];
        } else if ([account.condicionDeVenta integerValue] <= 90) {
            ninetyDays += [account.importeConDescuento floatValue];
        } else {
            more90Days += [account.importeConDescuento floatValue];
        }
        total += [account.importeConDescuento floatValue];
    }
    
    [resumeDictionary setObject:[NSNumber numberWithFloat:total] forKey:@"total"];
    [resumeDictionary setObject:[NSNumber numberWithInt:thirtyDays] forKey:@"30"];
    [resumeDictionary setObject:[NSNumber numberWithInt:fortyDays] forKey:@"45"];
    [resumeDictionary setObject:[NSNumber numberWithInt:ninetyDays] forKey:@"90"];
    [resumeDictionary setObject:[NSNumber numberWithInt:more90Days] forKey:@"+90"];
    
    return resumeDictionary;
}

@end
