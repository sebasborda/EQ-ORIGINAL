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
#import "NSString+Number.h"

@implementation EQLoginViewModel
@synthesize delegate = _delegate;

- (void)loginUser:(NSString *)userName withPassword:(NSString *)userPassword{
    __block NSString *hashedPassword = [userPassword MD5];
    __block Usuario *currentUser = [Usuario MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"SELF.nombreDeUsuario == %@ && SELF.password == %@", userName, hashedPassword]];
    if (currentUser) {
        [self loginDidCompleteWithUser:currentUser];
    } else {
        __block NSString *userNameCopy = userName;
        SuccessRequest block = ^(NSArray *jsonArray){
            [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext){
                for (NSDictionary* usuarioDictionary in jsonArray) {
                    NSNumber *identifier = [[usuarioDictionary filterInvalidEntry:@"wp_user_id"] number];
                    NSString *usuario = [usuarioDictionary filterInvalidEntry:@"username"];
                    NSString *password = [usuarioDictionary filterInvalidEntry:@"hashed_password"];
                    Usuario *user = [Usuario MR_createInContext:localContext];
                    user.identifier = identifier;
                    user.nombreDeUsuario = usuario;
                    user.password = password;
                    user.nombre = [usuarioDictionary filterInvalidEntry:@"display_name"];
                    user.vendedorID = [[usuarioDictionary filterInvalidEntry:@"vendedor_id"] number];
                    if ([userNameCopy isEqualToString:usuario] && [hashedPassword isEqualToString:password]) {
                        currentUser = user;
                    }
                }
            } completion:^(BOOL success, NSError *error){
                if (currentUser) {
                    [self loginDidCompleteWithUser:currentUser];
                } else {
                    [self.delegate loginFail];
                }
            }];
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
