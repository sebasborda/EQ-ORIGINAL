//
//  EQEditOrderDetailCell.m
//  EQ
//
//  Created by Sebastian Borda on 5/19/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQEditOrderDetailCell.h"

@implementation EQEditOrderDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)editButtonAction:(id)sender {
}

- (IBAction)deleteButtonAction:(id)sender {
}
@end
