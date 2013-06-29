//
//  EQOrderCell.m
//  EQ
//
//  Created by Sebastian Borda on 5/15/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQOrderCell.h"
#import "Cliente.h"
#import "EQImageView.h"

@interface EQOrderCell()

@property (nonatomic,strong) Pedido *pedido;

@end

@implementation EQOrderCell

- (IBAction)editButtonAction:(id)sender {
    [self.delegate editOrder:self.pedido];
}

- (IBAction)cancelButtonAction:(id)sender {
    [self.delegate cancelOrder:self.pedido];
}

- (IBAction)cloneButtonAction:(id)sender {
    [self.delegate copyOrder:self.pedido];
}

- (void)loadOrder:(Pedido *)pedido{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yy"];
    self.pedido = pedido;
    [self loadStatusStyle:pedido.estado];
    self.syncDateLabel.text = [dateFormat stringFromDate:pedido.sincronizacion];
    self.billingDateLabel.text = [dateFormat stringFromDate:pedido.fecha];
    self.clienLabel.text = pedido.cliente.nombre;
    self.orderNumberLabel.text = [pedido.identifier stringValue];
    self.grossPriceLabel.text = [NSString stringWithFormat:@"$%.2f", [pedido.subTotal floatValue]];
    self.discountLabel.text = [NSString stringWithFormat:@"%@%%", pedido.descuento];
    self.netPriceLabel.text = [NSString stringWithFormat:@"$%.2f", [pedido.total floatValue]];
}


- (void)loadStatusStyle:(NSString *)estado{
    NSString *imageName = nil;
    if ([estado isEqualToString:@"pendiente"]) {
        imageName = @"03.listado.de.pedidos.btn.estado.pendiente.png";
        self.editButton.hidden = NO;
        self.cancelButton .hidden = NO;
        self.cloneButton.hidden = YES;
    } else if ([estado isEqualToString:@"facturado"]) {
        imageName = @"03.listado.de.pedidos.btn.estado.facturado.png";
        self.editButton.hidden = NO;
        self.cancelButton .hidden = NO;
        self.cloneButton.hidden = YES;
    } else if ([estado isEqualToString:@"presupuestado"]) {
        imageName = @"03.listado.de.pedidos.btn.estado.sin.facturar.png";
        self.editButton.hidden = NO;
        self.cancelButton .hidden = NO;
        self.cloneButton.hidden = NO;
    } else if ([estado isEqualToString:@"anulado"]) {
        imageName = @"03.listado.de.pedidos.btn.estado.cancelado.png";
        self.editButton.hidden = NO;
        self.cancelButton .hidden = NO;
        self.cloneButton.hidden = YES;
        [self.syncDateLabel setTextColor:[UIColor grayColor]];
        [self.billingDateLabel setTextColor:[UIColor grayColor]];
        [self.clienLabel setTextColor:[UIColor grayColor]];
        [self.orderNumberLabel setTextColor:[UIColor grayColor]];
        [self.grossPriceLabel setTextColor:[UIColor grayColor]];
        [self.discountLabel setTextColor:[UIColor grayColor]];
        [self.netPriceLabel setTextColor:[UIColor grayColor]];
    }
    
    self.statusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
}

@end
