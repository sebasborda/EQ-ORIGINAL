//
//  EQProductDetailViewController.h
//  EQ
//
//  Created by Sebastian Borda on 4/27/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewController.h"
#import "EQImageView.h"
#import "Articulo.h"

@protocol EQProductDetailViewDelegate;

@interface EQProductDetailView : UIView<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *productsCollectionView;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet EQImageView *productImage;
@property (strong, nonatomic) IBOutlet UILabel *group1Label;
@property (strong, nonatomic) IBOutlet UILabel *codelabel;
@property (strong, nonatomic) IBOutlet UITextView *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *multipleLabel;
@property (strong, nonatomic) IBOutlet UILabel *PriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *quantityLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *repositionDate;
@property (strong, nonatomic) IBOutlet UIImageView *unavailableImage;
@property (weak, nonatomic) id<EQProductDetailViewDelegate> delegate;

- (void)loadArticle:(Articulo *)article client:(Cliente *)client;
- (IBAction)closeButtonAction:(id)sender;

@end

@protocol EQProductDetailViewDelegate <NSObject>

- (void)productDetailClose;

@end
