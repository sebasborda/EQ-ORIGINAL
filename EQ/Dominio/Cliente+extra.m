//
//  Cliente+extra.m
//  EQ
//
//  Created by Sebastian Borda on 6/28/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Cliente+extra.h"
#import "ItemPedido+extra.h"
#import "Pedido+extra.h"
#import "Articulo+extra.h"
#import "Grupo+extra.h"
#import "EQDataAccessLayer.h"

@implementation Cliente (extra)

@dynamic ventas;
@dynamic condicionesDePago;
@dynamic expresos;
@dynamic lineasDeVenta;
@dynamic ivas;
@dynamic provincias;
@dynamic zonasEnvio;
@dynamic pedidos;
@dynamic listaDePrecios;
@dynamic cobradores;
@dynamic vendedores;
@dynamic pedidosPendientes;



- (Provincia *)provincia{
    return [self.provincias lastObject];
}

- (Expreso *)expreso{
    return [self.expresos lastObject];
}

- (LineaVTA *)lineaDeVenta{
    return [self.lineasDeVenta lastObject];
}

- (TipoIvas *)iva{
    return [self.ivas lastObject];
}

- (ZonaEnvio *)zonaEnvio{
    return [self.zonasEnvio lastObject];
}

- (CondPag *)condicionDePago{
    return [self.condicionesDePago lastObject];
}

- (Vendedor *)vendedor{
    return [self.vendedores lastObject];
}

- (Vendedor *)cobrador{
    return [self.cobradores lastObject];
}

- (void)calcularRelevancia{
    for (Pedido *pedido in self.pedidos) {
        for (ItemPedido *item in pedido.items) {
            Grupo *grupo = item.articulo.grupo;
            grupo.relevancia = [NSNumber numberWithInt:[item.cantidad intValue] + [grupo.relevancia intValue]];
            
            if (![grupo.parentID isEqualToString:@"0"]) {
                Grupo *grupo2 = grupo.parent;
                grupo2.relevancia = [NSNumber numberWithInt:[item.cantidad intValue] + [grupo2.relevancia intValue]];
                
                if(![grupo2.parentID isEqualToString:@"0"]){
                    Grupo *grupo3 = grupo2.parent;
                    grupo3.relevancia = [NSNumber numberWithInt:[item.cantidad intValue] + [grupo3.relevancia intValue]];
                    
                }
            }
        }
    }
    [[EQDataAccessLayer sharedInstance] saveContext];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"Cliente id:%@ nombre:%@ desc1-2-3-4:%@-%@-%@-%@ cod1-2:%@-%@ numero de lista :%@ cantidad de precios:%d",self.identifier,self.nombre,self.descuento1,self.descuento2,self.descuento3,self.descuento4,self.codigo1,self.codigo2, self.listaPrecios, [self.listaDePrecios count]];
}

@end
