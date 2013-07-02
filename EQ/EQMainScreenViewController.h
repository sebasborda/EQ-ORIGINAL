//
//  EQMainScreenViewController.h
//  EQ
//
//  Created by Sebastian Borda on 4/19/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewController.h"
#import "EQCreateClientViewController.h"

@interface EQMainScreenViewController : EQBaseViewController<EQCreateClientViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *loggedUserLabel;
@property (strong, nonatomic) IBOutlet UIButton *clientsButton;

- (IBAction)sectionButtonAction:(id)sender;
- (IBAction)createClientButtonAction:(id)sender;

@end
