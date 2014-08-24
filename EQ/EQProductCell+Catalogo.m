//
//  EQProductCell+Catalogo.m
//  EQ
//
//  Created by Sebastian Borda on 10/26/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQProductCell+Catalogo.h"
#import "EQImagesManager.h"
#import "CatalogoImagen.h"

#define DEFAULT_IMAGE @"catalogoFotoProductoInexistente.png"

@implementation EQProductCell (Catalogo)

- (void)loadCatalog:(Catalogo *)catalog {
    self.productNameLabel.text = catalog.titulo;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pagina" ascending:YES];
    NSArray *photos = [catalog.imagenes sortedArrayUsingDescriptors:@[sortDescriptor]];

    CatalogoImagen *imagenCatalog = [photos firstObject];
    UIImage *image = [[EQImagesManager sharedInstance] catalogImageNamed:imagenCatalog.nombre defaltImage:DEFAULT_IMAGE];
    self.productImage.image = image;

    self.productStatusLabel.hidden = YES;
    self.agotadoImage.hidden = YES;
    self.codigoIcon.hidden = YES;
    self.productCodeLabel.hidden = YES;
    self.productCostLabel.hidden = YES;
}

@end
