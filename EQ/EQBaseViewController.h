//
//  EQBaseViewController.h
//  EQ
//
//  Created by Sebastian Borda on 4/14/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewModel.h"

@interface EQBaseViewController : UIViewController<EQBaseViewModelDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *sellerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *syncDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *clientStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *clientNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *notificationsButton;
@property (strong, nonatomic) IBOutlet UIButton *goalsButton;
@property (strong, nonatomic) IBOutlet UIButton *pendingOrdersButton;
@property (nonatomic, strong) UIButton *popoverOwner;

- (IBAction)pendingOrdersAction:(id)sender;
- (IBAction)notificationsAction:(id)sender;
- (IBAction)goalsAction:(id)sender;
- (IBAction)logoutAction:(id)sender;
- (BOOL)isButtonPopoverOwner:(UIButton *)button;

- (void)presentPopoverInView:(UIButton *)view withContent:(UIViewController *)content;
- (void)closePopover;
- (void)startLoading;
- (void)stopLoading;
- (void)notImplemented;
- (UIImage *)captureView:(UIView *)view;

@end
