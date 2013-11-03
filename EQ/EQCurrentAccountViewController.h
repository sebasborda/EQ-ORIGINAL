//
//  EQCurrentAccountViewController.h
//  EQ
//
//  Created by Sebastian Borda on 4/20/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewController.h"
#import "EQCurrentAccountViewModel.h"
#import "EQTablePopover.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface EQCurrentAccountViewController : EQBaseViewController<UITableViewDataSource,UITableViewDelegate, EQTablePopoverDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *sortButton;
@property (strong, nonatomic) IBOutlet UIButton *clientButton;
@property (strong, nonatomic) IBOutlet UIButton *localityButton;
@property (strong, nonatomic) IBOutlet UIButton *totalButton;
@property (strong, nonatomic) IBOutlet UIButton *companyButton;
@property (strong, nonatomic) IBOutlet UILabel *thirtyDaysLabel;
@property (strong, nonatomic) IBOutlet UILabel *fortyFiveDaysLabel;
@property (strong, nonatomic) IBOutlet UILabel *ninetyDaysLabel;
@property (strong, nonatomic) IBOutlet UILabel *moreThan90DaysLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalLabel;
@property (strong, nonatomic) IBOutlet UIView *tableHeader;
@property (strong, nonatomic) IBOutlet UIView *headerForEmail;
@property (nonatomic, strong) IBOutlet UITableView *tableViewForEmail;

- (IBAction)companyButtonAction:(id)sender;
- (IBAction)sortButtonAction:(id)sender;
- (IBAction)clientButtonAction:(id)sender;
- (IBAction)localityButtonAction:(id)sender;
- (IBAction)totalButtonAction:(id)sender;
- (IBAction)emailButtonAction:(id)sender;

@end
