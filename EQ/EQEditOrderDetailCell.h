//
//  EQEditOrderDetailCell.h
//  EQ
//
//  Created by Sebastian Borda on 5/19/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQEditOrderDetailCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *codeLabel;
@property (strong, nonatomic) IBOutlet UILabel *productNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *quantityLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;

- (IBAction)editButtonAction:(id)sender;
- (IBAction)deleteButtonAction:(id)sender;

@end
