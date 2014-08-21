//
//  EQOrdersViewController.h
//  EQ
//
//  Created by Sebastian Borda on 4/20/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewController.h"
#import "EQTablePopover.h"
#import "EQOrderCell.h"
#import "EQDateFilterPopover.h"

@interface EQOrdersViewController : EQBaseViewController<EQTablePopoverDelegate, EQOrderCellDelegate, EQDateFilterPopoverDelegate>

@property (strong, nonatomic) IBOutlet UIButton *clientFilterButton;
@property (strong, nonatomic) IBOutlet UIButton *creationFilterButton;
@property (strong, nonatomic) IBOutlet UIButton *billingFilterButton;
@property (strong, nonatomic) IBOutlet UIButton *statusFilterButton;
@property (strong, nonatomic) IBOutlet UIButton *orderFilterButton;
@property (strong, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (strong, nonatomic) IBOutlet UITableView *ordersTable;
@property (strong, nonatomic) IBOutlet UILabel *totalMessageLabel;

- (IBAction)newOrderButtonAction:(id)sender;
- (IBAction)clientFilterAction:(id)sender;
- (IBAction)creationFilterAction:(id)sender;
- (IBAction)billingFilterAction:(id)sender;
- (IBAction)statusFilterAction:(id)sender;
- (IBAction)orderButtonAction:(id)sender;
- (void)changeStatusFilter:(NSString *)status;
- (IBAction)bugButtonAction:(id)sender;

@end
