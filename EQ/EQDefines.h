//
//  EQDefines.h
//  EQ
//
//  Created by Sebastian Borda on 4/27/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//
#import "EQAppDelegate.h"

typedef enum{
    EQTabIndexMain,
    EQTabIndexOrders,
    EQTabIndexCurrentAccount,
    EQTabIndexSales,
    EQTabIndexCommunications,
    EQTabIndexGoals,
    EQTabIndexProducts,
    EQTabIndexClients,
    EQTabIndexCatalogs
}EQTabIndex;

#define APP_DELEGATE (EQAppDelegate *)[[UIApplication sharedApplication]delegate]
#define PROD_BASE_URL @"https://www.eqarte.com.ar"

#ifdef TEST_VERSION
    #define MAXIMUM_MINUTES_TO_UPDATE 2
    #define HOST @"stg.eqarte.com.ar"
    #define BASE_URL @"http://stg.eqarte.com.ar/"
    #define IMAGES_BASE_URL @"https://www.eqarte.com.ar/wp-content/uploads/"
    #define API_URL "http://stg.eqarte.com.ar/wp-admin/admin-ajax.php"
    #define DEBUG_ERROR NO
    #define DEBUG_ERROR_CODE @"40-072220140051"
#else
    #define MAXIMUM_MINUTES_TO_UPDATE 5
    #define HOST @"www.eqarte.com.ar"
    #define BASE_URL @"https://www.eqarte.com.ar/"
    #define IMAGES_BASE_URL @"https://www.eqarte.com.ar/wp-content/uploads/"
    #define API_URL "https://www.eqarte.com.ar/wp-admin/admin-ajax.php"
    #define DEBUG_ERROR NO
    #define DEBUG_ERROR_CODE @"INGRESE EL CODIGO DE ERROR"

#endif

#define DATA_UPDATED_NOTIFICATION @"dataUpdatedNotification"
#define ACTIVE_CLIENT_CHANGE_NOTIFICATION @"activeClientChangeNotification"

#define COMMUNICATION_TYPE_OPERATIVE @"op"
#define COMMUNICATION_TYPE_COMMERCIAL @"com"
#define COMMUNICATION_TYPE_GOAL @"cli"

#define SUPPORT_EMAIL @"sebasborda@gmail.com"