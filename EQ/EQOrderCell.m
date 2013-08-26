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
#import "NSNumber+EQ.h"

@interface EQOrderCell()

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
    self.creationDateLabel.text = [dateFormat stringFromDate:pedido.fecha];
    self.billingDateLabel.text = [dateFormat stringFromDate:pedido.fechaFacturacion];
    self.clienLabel.text = pedido.cliente.nombre;
    self.orderNumberLabel.text = pedido.identifier;
    self.grossPriceLabel.text = [NSString stringWithFormat:@"%@", [pedido.subTotal currencyString]];
    float discount = [pedido porcentajeDescuento];
    self.discountLabel.text = [NSString stringWithFormat:@"%.2f%%", discount];
    self.netPriceLabel.text = [NSString stringWithFormat:@"%@", [pedido.total currencyString]];
}


- (void)loadStatusStyle:(NSString *)estado{
    NSString *imageName = nil;
    [self.creationDateLabel setTextColor:[UIColor blackColor]];
    [self.billingDateLabel setTextColor:[UIColor blackColor]];
    [self.clienLabel setTextColor:[UIColor blackColor]];
    [self.orderNumberLabel setTextColor:[UIColor blackColor]];
    [self.grossPriceLabel setTextColor:[UIColor blackColor]];
    [self.discountLabel setTextColor:[UIColor blackColor]];
    [self.netPriceLabel setTextColor:[UIColor blackColor]];
    if ([estado isEqualToString:@"pendiente"]) {
        imageName = @"pedidoReferenciaPendiente.png";
        self.editButton.hidden = YES;
        self.cancelButton .hidden = YES;
        self.cloneButton.hidden = NO;
    } else if ([estado isEqualToString:@"facturado"]) {
        imageName = @"pedidoReferenciaSincronizado.png";
        self.editButton.hidden = YES;
        self.cancelButton .hidden = YES;
        self.cloneButton.hidden = NO;
    } else if ([estado isEqualToString:@"presupuestado"]) {
        imageName = @"pedidoReferenciaPresupuestado.png";
        self.editButton.hidden = NO;
        self.cancelButton .hidden = NO;
        self.cloneButton.hidden = NO;
    } else if ([estado isEqualToString:@"anulado"]) {
        imageName = @"pedidoReferenciaCancelado.png";
        self.editButton.hidden = YES;
        self.cancelButton .hidden = YES;
        self.cloneButton.hidden = NO;
        [self.creationDateLabel setTextColor:[UIColor grayColor]];
        [self.billingDateLabel setTextColor:[UIColor grayColor]];
        [self.clienLabel setTextColor:[UIColor grayColor]];
        [self.orderNumberLabel setTextColor:[UIColor grayColor]];
        [self.grossPriceLabel setTextColor:[UIColor grayColor]];
        [self.discountLabel setTextColor:[UIColor grayColor]];
        [self.netPriceLabel setTextColor:[UIColor grayColor]];
    }
    
    self.statusImageView.image = [UIImage imageNamed:imageName];
}

@end
