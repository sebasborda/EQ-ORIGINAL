//
//  EQArticleCell.h
//  EQ
//
//  Created by Sebastian Borda on 5/18/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQImageView.h"

@interface EQArticleCell : UITableViewCell

@property (strong, nonatomic) IBOutlet EQImageView *articleImage;
@property (strong, nonatomic) IBOutlet UILabel *codeLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@end
