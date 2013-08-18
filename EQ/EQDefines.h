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
    EQTabIndexCommunications,
    EQTabIndexGoals,
    EQTabIndexProducts,
    EQTabIndexClients
}EQTabIndex;

#define APP_DELEGATE (EQAppDelegate *)[[UIApplication sharedApplication]delegate]
#define MAXIMUM_MINUTES_TO_UPDATE 2
#define IMAGES_BASE_URL @"http://www.eqarte.com.ar/wp-content/uploads/"
#define BASE_URL "http://www.eqarte.com.ar/wp-admin/admin-ajax.php"
#define SELECTION_TEXT @"Elige una"
#define DATA_UPDATED_NOTIFICATION @"dataUpdatedNotification"
#define ACTIVE_CLIENT_CHANGE_NOTIFICATION @"activeClientChangeNotification"

#define COMMUNICATION_TYPE_OPERATIVE @"op"
#define COMMUNICATION_TYPE_COMMERCIAL @"com"
#define COMMUNICATION_TYPE_GOAL @"cli"