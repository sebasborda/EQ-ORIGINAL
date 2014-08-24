//
//  EQCatalogViewController.h
//  EQ
//
//  Created by Sebastian Borda on 10/26/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewController.h"

@interface EQCatalogViewController : EQBaseViewController <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *catalogsCollectionView;
@property (strong, nonatomic) IBOutlet UILabel *catalogTitleLabel;
- (IBAction)closeCatalogAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *catalogDetailView;
@property (strong, nonatomic) IBOutlet UIScrollView *catalogScrollView;
@property (strong, nonatomic) IBOutlet UIButton *categoryOneButton;
- (IBAction)categoryOneButtonAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *categoryTwoButton;
- (IBAction)categoryTwoButtonAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *categoryThreeButton;
- (IBAction)categoryThreeButtonAction:(id)sender;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *categoryButtonsList;
@property (strong, nonatomic) IBOutlet UIButton *updateCatalogButton;
- (IBAction)updateCatalogAction:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *lastUpdateLabel;

@end
