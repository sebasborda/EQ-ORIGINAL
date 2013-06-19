//
//  EQProductsViewController.h
//  EQ
//
//  Created by Sebastian Borda on 4/20/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewController.h"
#import "EQProductsViewModel.h"
#import "EQTransparentBackgroundSearchBar.h"
#import "EQProductDetailView.h"
#import "EQTablePopover.h"

@interface EQProductsViewController : EQBaseViewController<UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, EQProductDetailViewDelegate, EQTablePopoverDelegate>

- (IBAction)groupOneAction:(id)sender;
- (IBAction)groupTwoAction:(id)sender;
- (IBAction)groupThreeAction:(id)sender;
- (IBAction)reloadAction:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *groupOneButton;
@property (strong, nonatomic) IBOutlet UIButton *groupTwoButton;
@property (strong, nonatomic) IBOutlet UIButton *groupThreeButton;
@property (strong, nonatomic) IBOutlet UICollectionView *productsCollectionView;
@property (strong, nonatomic) IBOutlet EQTransparentBackgroundSearchBar *searchBar;
@property (strong, nonatomic) IBOutlet EQProductDetailView *productDetailView;

@end
