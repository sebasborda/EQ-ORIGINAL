//
//  EQSalesViewController.h
//  EQ
//
//  Created by Sebastian Borda on 4/20/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewController.h"
#import "EQTablePopover.h"
#import "EQCustomDateFilterPopover.h"

@interface EQSalesViewController : EQBaseViewController<EQTablePopoverDelegate, UITableViewDataSource, UITableViewDelegate,EQDateFilterPopoverDelegate>
@property (strong, nonatomic) IBOutlet UIButton *periodFilterButton;
@property (strong, nonatomic) IBOutlet UIButton *clientFilterButton;
@property (strong, nonatomic) IBOutlet UIButton *groupFilterButton;
@property (strong, nonatomic) IBOutlet UIButton *modeButton;
@property (strong, nonatomic) IBOutlet UIButton *sortButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *totalLabel;
@property (strong, nonatomic) IBOutlet UILabel *articlesLabel;

- (IBAction)periodFilterButtonAction:(id)sender;
- (IBAction)clientFilterButtonAction:(id)sender;
- (IBAction)groupFilterButtonAction:(id)sender;
- (IBAction)modeButtonAction:(id)sender;
- (IBAction)sortButtonAction:(id)sender;
@end
