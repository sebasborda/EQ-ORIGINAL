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
    [[EQDataManager sharedInstance] updateData];
}

- (void)regiteredUser:(Usuario *)user{
    self.user = user;
//    [self updateData];
    
    self.updateTimer = [NSTimer timerWithTimeInterval:(MAXIMUM_MINUTES_TO_UPDATE * 60) target:self selector:@selector(updateData) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
}

- (void)endSession{
    self.user = nil;
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
}

@end
