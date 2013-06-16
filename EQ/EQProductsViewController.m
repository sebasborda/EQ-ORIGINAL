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

@interface EQProductsViewController ()

@property (nonatomic,strong) EQProductsViewModel *viewModel;

@end

@implementation EQProductsViewController

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.viewModel = [EQProductsViewModel new];
        self.viewModel.delegate = self;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    UINib *nib = [UINib nibWithNibName:@"EQProductCell" bundle: nil];
    [self.productsCollectionView registerNib:nib forCellWithReuseIdentifier:@"ProductCell"];
    self.productDetailView.delegate = self;
    [self.viewModel loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)groupOneAction:(id)sender {
    [self notImplemented];
}

- (IBAction)groupTwoAction:(id)sender {
    [self notImplemented];
}

- (IBAction)groupThreeAction:(id)sender {
    [self notImplemented];
}

- (IBAction)reloadAction:(id)sender {
    [self.viewModel resetFilters];
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
    //TODO: reemplazar con nombre cuando funcione
    cell.productNameLabel.text = art.descripcion;
    cell.productStatusLabel.text = [art.disponibilidadID stringValue];
    [cell.productImage loadURL:art.imagenURL];
    int precio = art.precio.importe ? [art.precio.importe intValue] : 0;
    if (precio > 0) {
        NSLog(@"%i %@", precio, art.identifier);
    }
    cell.productCostLabel.text = [NSString stringWithFormat:@"$%i",precio];
    cell.productCodeLabel.text = art.codigo;
    cell.productStatusLabel.text = [art.disponibilidadID boolValue] ? @"Disponible" : @"Agotado";
    
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

@end
