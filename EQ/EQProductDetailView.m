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

@interface EQProductDetailView()

@property (nonatomic,strong) NSArray *articles;

@end

@implementation EQProductDetailView

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        UINib *nib = [UINib nibWithNibName:@"EQProductCell" bundle: nil];
        [self.productsCollectionView registerNib:nib forCellWithReuseIdentifier:@"ProductCell"];
    }
    
    return self;
}

- (void)loadArticle:(Articulo *)article{
    self.productName.text = article.nombre;
    [self.productImage loadURL:article.imagenURL];
    self.descriptionLabel.text = article.descripcion;
    self.codelabel.text = article.codigo;
    self.quantityLabel.text = [article.minimoPedido stringValue];
    self.multipleLabel.text = [article.multiploPedido stringValue];
    self.statusLabel.text = [article.disponibilidadID boolValue] ? @"Disponible" : @"Agotado";
    int precio = article.precio.importe ? [article.precio.importe intValue] : 0;
    self.PriceLabel.text = [NSString stringWithFormat:@"$ %i",precio];
    [self LoadGridData];
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
    //TODO: reemplazar con nombre cuando funcione
    cell.productNameLabel.text = art.descripcion;
    cell.productStatusLabel.text = [art.disponibilidadID stringValue];
    [cell.productImage loadURL:art.imagenURL];
    cell.productCostLabel.text = [art.precio.importe stringValue];
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

- (void)LoadGridData{
    EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
    //TODO: cambiar predicate para buscar por tercer categoria
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.codigo like %@",@"400*"];
    self.articles = [adl objectListForClass:[Articulo class] filterByPredicate:predicate];
}
@end
