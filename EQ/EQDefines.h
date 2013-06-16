//
//  EQDefines.h
//  EQ
//
//  Created by Sebastian Borda on 4/27/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//
#import "EQAppDelegate.h"

typedef enum{
    EQTabIndexOrders,
    EQTabIndexCurrentAccount,
    EQTabIndexSales,
    EQTabIndexComunications,
    EQTabIndexGoals,
    EQTabIndexProducts,
    EQTabIndexClients
}EQTabIndex;

#define APP_DELEGATE (EQAppDelegate *)[[UIApplication sharedApplication]delegate]
#define MAXIMUM_MINUTES_TO_UPDATE 1
#define BASE_URL "http://eq.gm2dev.com/wp-admin/admin-ajax.php"
#define SELECTION_TEXT "Elige una"