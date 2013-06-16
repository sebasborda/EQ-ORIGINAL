//
//  EQClientCell.h
//  EQ
//
//  Created by Sebastian Borda on 5/2/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

@protocol EQClientCellDelegate <NSObject>

- (void)editClientWithID:(NSNumber *)clientID;
- (void)mailToClientWithID:(NSNumber *)clientID;

@end

@interface EQClientCell : UITableViewCell
@property (weak, nonatomic) id<EQClientCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *clientLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *localityLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UIButton *mailButton;
@property (strong, nonatomic) NSNumber *clientID;

- (IBAction)editButtonAction:(id)sender;
- (IBAction)mailButtonAction:(id)sender;
- (void)hasEmail:(BOOL)has;

@end
