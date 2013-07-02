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

- (NSString *)loggedUserName{
    return [[self sellerName] uppercaseString];
}

@end
