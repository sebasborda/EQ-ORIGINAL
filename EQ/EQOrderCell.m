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
    float discount = [pedido porcentajeDescuento];
    int intPart = (int)discount;
    if (discount - intPart > 0.001) {
        self.discountLabel.text = [NSString stringWithFormat:@"%.2f%%", discount];
    } else {
        self.discountLabel.text = [NSString stringWithFormat:@"%i%%", intPart];
    }
    
    self.netPriceLabel.text = [NSString stringWithFormat:@"$%.2f", [pedido.total floatValue]];
}


- (void)loadStatusStyle:(NSString *)estado{
    NSString *imageName = nil;
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
        [self.syncDateLabel setTextColor:[UIColor grayColor]];
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
