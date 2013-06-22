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
#import "Disponibilidad.h"
#import "Grupo.h"
#import "Precio+Cliente.h"

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
    self.statusLabel.text = article.disponibilidad.descripcion;
    CGFloat precio = article.precio.importe ? [article.precio importeConDescuento] : 0;
    self.PriceLabel.text = [NSString stringWithFormat:@"$ %.2f",precio];
    EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
    Grupo *grupo = (Grupo *)[adl objectForClass:[Grupo class] withId:article.grupoID];
    self.group1Label.text = [grupo nombre];
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
    CGFloat precio = art.precio.importe ? [art.precio importeConDescuento] : 0;
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
    return CGSizeMake(182, 170);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(9, 15, 9, 15);
}


- (IBAction)closeButtonAction:(id)sender {
    [self.delegate productDetailClose];
}

- (void)LoadGridData:(Articulo *)article{
    EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.grupoID = %@",article.grupoID];
    self.articles = [adl objectListForClass:[Articulo class] filterByPredicate:predicate];
    Grupo *grupo = (Grupo *)[adl objectForClass:[Grupo class] withId:article.grupoID];
    self.group1Label.text = [grupo nombre];
    [self.productsCollectionView reloadData];
}
@end
