//
//  Comunicacion+extra.m
//  EQ
//
//  Created by Sebastian Borda on 7/5/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Comunicacion+extra.h"

@implementation Comunicacion (extra)

@dynamic clientes;
@dynamic receivers;
@dynamic senders;

- (Cliente *)cliente{
    return [self.clientes lastObject];
}

- (Usuario *)usuario{
    return [self.receivers lastObject];
}

- (Usuario *)sender{
    return [self.senders lastObject];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Comunicacion receiverID:%@ senderID:%@ clienteID:%@",self.receiverID, self.senderID, self.clienteID];
}

@end
