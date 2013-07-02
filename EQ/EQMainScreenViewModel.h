//
//  EQMainScreenViewModel.h
//  EQ
//
//  Created by Sebastian Borda on 4/19/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewModel.h"

@interface EQMainScreenViewModel : EQBaseViewModel

@property (nonatomic,strong) NSArray *clients;
@property (nonatomic,weak) id<EQBaseViewModelDelegate> delegate;

- (NSString *)loggedUserName;

@end
