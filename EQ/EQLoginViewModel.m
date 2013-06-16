//
//  EQLoginViewModel.m
//  EQ
//
//  Created by Sebastian Borda on 4/14/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQLoginViewModel.h"
#import "NSString+MD5.h"
#import "EQSession.h"
#import "EQNetworkManager.h"
#import "NSDictionary+EQ.h"
#import "Usuario.h"

@implementation EQLoginViewModel
@synthesize delegate = _delegate;

- (void)loginUser:(NSString *)userName withPassword:(NSString *)userPassword{
    EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
    __block Usuario *currentUser = nil;
    __block NSString *hashedPassword = [userPassword MD5];
    if ([[EQSession sharedInstance] lastSyncDate]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.nombreDeUsuario = %@ && SELF.password = %@", userName, hashedPassword];
        currentUser = (Usuario *)[adl objectForClass:[Usuario class] withPredicate:predicate];
    }
    
    if (currentUser) {
        [self loginDidCompleteWithUser:currentUser];
    } else {
        __block NSString *userNameCopy = userName;
        SuccessRequest block = ^(NSArray *jsonArray){
            NSMutableArray *users = [NSMutableArray array];
            for (NSDictionary* usuarioDictionary in jsonArray) {
                NSNumber *identifier = [NSNumber numberWithInt:[[usuarioDictionary filterInvalidEntry:@"vendedor_id"] integerValue] + 31];
                NSString *usuario = [usuarioDictionary filterInvalidEntry:@"username"];
                NSString *password = [usuarioDictionary filterInvalidEntry:@"hashed_password"];
                Usuario *user = (Usuario *)[adl objectForClass:[Usuario class] withId:identifier];
                user.identifier = identifier;
                user.nombreDeUsuario = usuario;
                user.password = password;
                user.nombre = [usuarioDictionary filterInvalidEntry:@"display_name"];
                NSNumber *vendedorID = [usuarioDictionary filterInvalidEntry:@"vendedor_id"];
                user.vendedor = (Vendedor *)[adl objectForClass:[Vendedor class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@", vendedorID]];
                if ([userNameCopy isEqualToString:usuario] && [hashedPassword isEqualToString:password]) {
                    currentUser = user;
                }
                [users addObject:user];
            }
            
            [adl saveContext];
            [self loginDidCompleteWithUser:currentUser];
        };
        
        FailRequest failBlock = ^(NSError *error){
            [self.delegate loginFail];
        };
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:@"listar" forKey:@"action"];
        [parameters setObject:@"login" forKey:@"object"];
        [parameters setObject:userName forKey:@"usuario"];
        [parameters setObject:hashedPassword forKey:@"password"];
        
        EQRequest *request = [[EQRequest alloc] initWithParams:parameters successRequestBlock:block failRequestBlock:failBlock];
        [EQNetworkManager makeRequest:request];
    }
}

- (void)loginDidCompleteWithUser:(Usuario *)user{
    [[EQSession sharedInstance] regiteredUser:user];
    [self.delegate loginSuccessful];
}

@end
