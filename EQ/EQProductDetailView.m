//
//  EQProductDetailViewController.m
//  EQ
//
//  Created by Sebastian Borda on 4/27/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQProductDetailView.h"
#import "EQProductCell.h"
#import "Precio.h"
#import "Disponibilidad+extra.h"
#import "Grupo+extra.h"
#import "Precio+extra.h"
#import "Articulo+extra.h"

@interface EQProductDetailView()

@property (nonatomic,strong) NSArray *articles;

@end

@implementation EQProductDetailView

- (void)loadArticle:(Articulo *)article{
    UINib *nib = [UINib nibWithNibName:@"EQProductCell" bundle: nil];
    [self.productsCollectionView registerNib:nib forCellWithReuseIdentifier:@"ProductCell"];
    self.productName.text = article.nombre;
    [self.productImage loadURL:article.imagenURL];
    self.descriptionLabel.text = article.descripcion;
    self.codelabel.text = article.codigo;
    self.quantityLabel.text = [article.minimoPedido stringValue];
    self.multipleLabel.text = [article.multiploPedido stringValue];
    if ([article.disponibilidad isAvailable]) {
        self.statusLabel.hidden = YES;
        self.unavailableImage.hidden = YES;
    }

    CGFloat precio = [article priceForActiveClient].importe ? [[article priceForActiveClient] priceForActiveClient] : 0;
    self.PriceLabel.text = [NSString stringWithFormat:@"$ %.2f",precio];
    self.group1Label.text = [article.grupo nombre];
    [self LoadGridData:article];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.articles count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EQProductCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"ProductCell" forIndexPath:indexPath];
    Articulo *art = [self.articles objectAtIndex:indexPath.item];

    cell.productNameLabel.text = art.nombre;
    cell.productStatusLabel.text = art.disponibilidad.descripcion;
    [cell.productImage loadURL:art.imagenURL];
    CGFloat precio = [art priceForActiveClient].importe ? [[art priceForActiveClient] priceForActiveClient] : 0;
    cell.productCostLabel.text = [NSString stringWithFormat:@"$%.2f",precio];
    cell.productCodeLabel.text = art.codigo;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Articulo *article = [self.articles objectAtIndex:indexPath.item];
    [self loadArticle:article];
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(183, 218);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(9, 5, 9, 5);
}


- (IBAction)closeButtonAction:(id)sender {
    [self.delegate productDetailClose];
}

- (void)LoadGridData:(Articulo *)article{
    self.articles = article.grupo.articulos;
    self.group1Label.text = [article.grupo nombre];
    [self.productsCollectionView reloadData];
}
@end
