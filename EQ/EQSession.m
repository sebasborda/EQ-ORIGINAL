//
//  EQSession.m
//  EQ
//
//  Created by Sebastian Borda on 4/25/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQSession.h"
#import "EQDefines.h"
#import "Usuario.h"
#import "EQDataManager.h"
#import "EQDataAccessLayer.h"
#import "Cliente+extra.h"
#import "Grupo+extra.h"

@interface EQSession()

@property (nonatomic,strong) NSTimer* updateTimer;

@end

@implementation EQSession

+ (EQSession *)sharedInstance
{
    static EQSession *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EQSession alloc] init];
    });
    return sharedInstance;
}

- (void)updateData{
    [[EQDataManager sharedInstance] updateDataShowLoading:NO];
}

- (void)regiteredUser:(Usuario *)user{
    self.user = user;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:user.identifier forKey:@"loggedUser"];
    [defaults synchronize];
    [self initializeDataSynchronization];
}

- (void)initializeDataSynchronization{
    self.updateTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:(MAXIMUM_MINUTES_TO_UPDATE * 60)] interval:(MAXIMUM_MINUTES_TO_UPDATE * 60) target:self selector:@selector(updateData) userInfo:nil repeats:YES];
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:self.updateTimer forMode: NSDefaultRunLoopMode];
    [[EQDataManager sharedInstance] updateDataShowLoading:YES];
}

- (void)endSession{
    self.user = nil;
    [Grupo resetRelevancia];
    self.selectedClient = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"loggedUser"];
    [defaults synchronize];
    [self.updateTimer invalidate];
}

- (NSDate *)lastSyncDate{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"lastSyncDate"];
}

- (void)dataUpdated{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:@"lastSyncDate"];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_UPDATED_NOTIFICATION object:nil];
    [self updateCache];
}

- (BOOL)isUserLogged{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *userID = [defaults objectForKey:@"loggedUser"];
    if (userID && !self.user) {
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        [self regiteredUser:(Usuario *)[adl objectForClass:[Usuario class] withId:userID]];
    }
    
    return userID != nil;
}

- (void)setSelectedClient:(Cliente *)selectedClient{
    [Grupo resetRelevancia];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    _selectedClient = selectedClient;
    if (selectedClient) {
        [selectedClient calcularRelevancia];
        [userInfo setObject:selectedClient forKey:@"activeClient"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ACTIVE_CLIENT_CHANGE_NOTIFICATION object:nil userInfo:userInfo];
}

- (void)updateCache{
    [[EQDataAccessLayer sharedInstance].managedObjectContext refreshObject:self.selectedClient mergeChanges:YES];
    [[EQDataAccessLayer sharedInstance].managedObjectContext refreshObject:self.user.vendedor mergeChanges:YES];
    [[EQDataAccessLayer sharedInstance].managedObjectContext refreshObject:self.user mergeChanges:YES];
}

@end
