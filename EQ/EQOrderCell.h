//
//  EQOrderCell.h
//  EQ
//
//  Created by Sebastian Borda on 5/15/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Pedido+extra.h"

@protocol EQOrderCellDelegate <NSObject>

- (void)editOrder:(Pedido *)pedido;
- (void)copyOrder:(Pedido *)pedido;
- (void)cancelOrder:(Pedido *)pedido;

@end

@interface EQOrderCell : UITableViewCell

@property (assign, nonatomic) id<EQOrderCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIImageView *statusImageView;
@property (strong, nonatomic) IBOutlet UILabel *syncDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *billingDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *clienLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *grossPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *discountLabel;
@property (strong, nonatomic) IBOutlet UILabel *netPriceLabel;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *cloneButton;

- (IBAction)editButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)cloneButtonAction:(id)sender;

- (void)loadOrder:(Pedido *)pedido;

@end
