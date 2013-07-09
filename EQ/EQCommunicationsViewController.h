//
//  EQCommunicationsViewController.h
//  EQ
//
//  Created by Sebastian Borda on 6/13/13.
//  Copyright (c) 2013 EQ. All rights reserved.
//

#import "EQBaseViewController.h"
#import "EQCommunicationsViewModel.h"
#import "EQCommunicationHeaderView.h"

@interface EQCommunicationsViewController : EQBaseViewController<EQBaseViewModelDelegate, EQCommunicationHeaderViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UITextView *bodyTextView;
@property (strong, nonatomic) IBOutlet UILabel *notificationsTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *finishButton;
@property (strong, nonatomic) IBOutlet UIButton *replyButton;
@property (strong, nonatomic) IBOutlet UILabel *messageHeader;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentCommunicationType;

- (IBAction)notificationKindChange:(id)sender;
- (IBAction)finishButtonAction:(id)sender;
- (IBAction)replybuttonAction:(id)sender;
- (void)changeToOperative;
- (void)changeToCommercial;

@end
