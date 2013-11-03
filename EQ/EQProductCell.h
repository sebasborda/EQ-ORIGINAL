//
//  EQProductCell.h
//  EQ
//
//  Created by Sebastian Borda on 4/25/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQImageView.h"
#import "Articulo+extra.h"

@interface EQProductCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet EQImageView *productImage;
@property (nonatomic, strong) IBOutlet UILabel *productNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *productCodeLabel;
@property (nonatomic, strong) IBOutlet UILabel *productCostLabel;
@property (nonatomic, strong) IBOutlet UILabel *productStatusLabel;
@property (strong, nonatomic) IBOutlet UIImageView *agotadoImage;
@property (strong, nonatomic) IBOutlet UIImageView *codigoIcon;

- (void)loadArticle:(Articulo *)art;

@end
