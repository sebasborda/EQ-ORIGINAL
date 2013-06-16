//
//  EQClientCell.m
//  EQ
//
//  Created by Sebastian Borda on 5/2/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQClientCell.h"

@implementation EQClientCell

- (void)hasEmail:(BOOL)has{
    self.mailButton.hidden = !has;
}

- (IBAction)editButtonAction:(id)sender {
    [self.delegate editClientWithID:self.clientID];
}

- (IBAction)mailButtonAction:(id)sender {
    [self.delegate mailToClientWithID:self.clientID];
}

@end
