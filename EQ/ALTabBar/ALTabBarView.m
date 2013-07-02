//
//  ALTabBarView.m
//  ALCommon
//
//  Created by Andrew Little on 10-08-17.
//  Copyright (c) 2010 Little Apps - www.myroles.ca. All rights reserved.
//

#import "ALTabBarView.h"


@implementation ALTabBarView

@synthesize delegate;
@synthesize selectedButton;
@synthesize tabButtons;

//Let the delegate know that a tab has been touched
-(IBAction) touchButton:(id)sender {

    if( delegate != nil && [delegate respondsToSelector:@selector(tabWasSelected:)]) {
        //DESACTIVA EL ESTADO EL BOTON ANTERIOR
        [self.selectedButton setSelected:NO];
        self.selectedButton = (UIButton *)sender;
        //ACTIVA EL NUEVO BOTON SELECCIONADO
        [self.selectedButton setSelected:YES];
        
        [delegate tabWasSelected:selectedButton.tag];
    }
}

-(void) selectTabAtIndex:(int)index{
    //DESACTIVA EL ESTADO EL BOTON ANTERIOR
    [self.selectedButton setSelected:NO];
    for (UIButton *button in self.tabButtons) {
        if (button.tag == index) {
            [button setSelected:YES];
            self.selectedButton = button;
            break;
        }
    }
    
    [delegate tabWasSelected:index];
}

@end
