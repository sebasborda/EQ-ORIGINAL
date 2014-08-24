//
//  EQMainScreenViewController.h
//  EQ
//
//  Created by Sebastian Borda on 4/19/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewController.h"
#import "EQCreateClientViewController.h"

@interface EQMainScreenViewController : EQBaseViewController<EQCreateClientViewControllerDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *loggedUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

- (IBAction)sectionButtonAction:(id)sender;
- (IBAction)createClientButtonAction:(id)sender;
- (IBAction)updateDataAction:(id)sender;
- (IBAction)updateImages:(id)sender;

@end
