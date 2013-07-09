//
//  EQProductsViewController.m
//  EQ
//
//  Created by Sebastian Borda on 4/20/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQProductsViewController.h"
#import "EQProductCell.h"
#import "Articulo.h"
#import "Precio.h"
#import "EQTablePopover.h"
#import "Grupo.h"
#import "Disponibilidad.h"
#import "Precio+extra.h"
#import "Articulo+extra.h"

@interface EQProductsViewController ()

@property (nonatomic,strong) EQProductsViewModel *viewModel;
@property (nonatomic,strong) EQTablePopover *popoverGroup1;
@property (nonatomic,strong) EQTablePopover *popoverGroup2;
@property (nonatomic,strong) EQTablePopover *popoverGroup3;
@end

@implementation EQProductsViewController

- (void)viewDidLoad{
    self.viewModel = [EQProductsViewModel new];
    self.viewModel.delegate = self;
    UINib *nib = [UINib nibWithNibName:@"EQProductCell" bundle: nil];
    [self.productsCollectionView registerNib:nib forCellWithReuseIdentifier:@"ProductCell"];
    self.productDetailView.delegate = self;
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.viewModel loadData];
}

- (NSMutableArray *)obtainGroupNames:(NSArray *)group{
    NSMutableArray *names = [NSMutableArray new];
    for (Grupo *groupItem in group) {
        [names addObject:groupItem.nombre];
    }
    
    return names;
}

- (IBAction)groupOneAction:(id)sender {
    self.popoverGroup1 = [[EQTablePopover alloc] initWithData:[self obtainGroupNames:[self.viewModel category1List]] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:self.popoverGroup1];
}

- (IBAction)groupTwoAction:(id)sender {
    self.popoverGroup2 = [[EQTablePopover alloc] initWithData:[self obtainGroupNames:[self.viewModel category2List]] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:self.popoverGroup2];
}

- (IBAction)groupThreeAction:(id)sender {
    self.popoverGroup3 = [[EQTablePopover alloc] initWithData:[self obtainGroupNames:[self.viewModel category3List]] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:self.popoverGroup3];
}

- (IBAction)reloadAction:(id)sender {
    [self.viewModel resetFilters];
    [self.groupOneButton setTitle:@"  Todas" forState:UIControlStateNormal];
    [self.groupTwoButton setTitle:@"  Todas" forState:UIControlStateNormal];
    [self.groupThreeButton setTitle:@"  Todas" forState:UIControlStateNormal];
    self.searchBar.text = @"";
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.viewModel.articles count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EQProductCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"ProductCell" forIndexPath:indexPath];
    Articulo *art = [self.viewModel.articles objectAtIndex:indexPath.item];
    cell.productNameLabel.text = art.nombre;
    cell.productStatusLabel.text = art.disponibilidad.descripcion;
    [cell.productImage loadURL:art.imagenURL];
    CGFloat precioFloat = [art priceForActiveClient].importe ? [[art priceForActiveClient] priceForActiveClient] : 0;
    cell.productCostLabel.text = [NSString stringWithFormat:@"$%.2f",precioFloat];
    cell.productCodeLabel.text = art.codigo;
    if([art.disponibilidad.identifier integerValue] > 1){
        cell.productStatusLabel.hidden = YES;
    } else {
        cell.productStatusLabel.hidden = NO;
        cell.productStatusLabel.text = art.disponibilidad.descripcion;
    }
    
    return cell;
}

- (void)modelDidUpdateData{
    [self.productsCollectionView reloadData];
    [self.searchBar resignFirstResponder];
    [super modelDidUpdateData];
}

- (void)productDetailClose{
    if (self.productDetailView.alpha == 1) {
        [UIView animateWithDuration:0.4 animations:^{
            self.productDetailView.alpha = 0;
        }];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.productDetailView loadArticle:[self.viewModel.articles objectAtIndex:indexPath.item]];
    if (self.productDetailView.alpha < 1) {
        [UIView animateWithDuration:0.4 animations:^{
            self.productDetailView.alpha = 1;
        }];
    }
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(182, 170);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

#pragma mark - search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.viewModel defineSearchTerm:searchText];
    [NSObject cancelPreviousPerformRequestsWithTarget:self.viewModel selector:@selector(loadData) object:nil];
    [self.viewModel performSelector:@selector(loadData) withObject:nil afterDelay:.8];
}

#pragma mark - Table Popover delegate

- (void)tablePopover:(EQTablePopover *)sender selectedRow:(int)rowNumber selectedData:(NSString *)selectedData{
    if (selectedData) {
        NSString *title = [NSString stringWithFormat:@"  %@",selectedData];
        if (sender == self.popoverGroup1) {
            [self.viewModel defineSelectedCategory1:rowNumber];
            [self.groupOneButton setTitle:title forState:UIControlStateNormal];
            [self.groupTwoButton setTitle:@"  Todas" forState:UIControlStateNormal];
            [self.groupThreeButton setTitle:@"  Todas" forState:UIControlStateNormal];
            [self.viewModel loadData];
        } else if (sender == self.popoverGroup2) {
            [self.viewModel defineSelectedCategory2:rowNumber];
            [self.groupTwoButton setTitle:title forState:UIControlStateNormal];
            [self.groupThreeButton setTitle:@"  Todas" forState:UIControlStateNormal];
            [self.viewModel loadData];
        } else if (sender == self.popoverGroup3) {
            [self.viewModel defineSelectedCategory3:rowNumber];
            [self.groupThreeButton setTitle:title forState:UIControlStateNormal];
            [self.viewModel loadData];
        }
    }
    [self closePopover];
    [super tablePopover:sender selectedRow:rowNumber selectedData:selectedData];
}

@end
