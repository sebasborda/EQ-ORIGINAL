//
//  EQCurrentAccountCell.h
//  EQ
//
//  Created by Sebastian Borda on 5/7/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQCurrentAccountCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *clientLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *delayLabel;
@property (strong, nonatomic) IBOutlet UILabel *voucherLabel;
@property (strong, nonatomic) IBOutlet UILabel *conditionLabel;
@property (strong, nonatomic) IBOutlet UILabel *persepLabel;
@property (strong, nonatomic) IBOutlet UILabel *amountLabel;
@property (strong, nonatomic) IBOutlet UILabel *discountLabel;

@end
