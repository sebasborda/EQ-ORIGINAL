//
//  EQLoginViewController.h
//  EQ
//
//  Created by Sebastian Borda on 4/13/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewController.h"
#import "EQLoginViewModel.h"

@interface EQLoginViewController : EQBaseViewController<UIAlertViewDelegate, EQLoginViewModelDelegate>
@property (strong, nonatomic) IBOutlet UITextField *usuarioTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) EQLoginViewModel *viewModel;

- (IBAction)loginButtonAction:(id)sender;

@end
