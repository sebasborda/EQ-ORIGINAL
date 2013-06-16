//
//  EQLoginViewModel.h
//  EQ
//
//  Created by Sebastian Borda on 4/14/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewModel.h"

@protocol EQLoginViewModelDelegate;

@interface EQLoginViewModel : EQBaseViewModel

@property (nonatomic, assign) id<EQLoginViewModelDelegate> delegate;

- (void)loginUser:(NSString *)user withPassword:(NSString *)password;

@end

@protocol EQLoginViewModelDelegate <EQBaseViewModelDelegate>

- (void)loginSuccessful;
- (void)loginFail;

@end