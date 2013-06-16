//
//  EQCurrentAccountFooter.h
//  EQ
//
//  Created by Sebastian Borda on 5/22/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQCurrentAccountFooter : UIView
@property (strong, nonatomic) IBOutlet UILabel *clientLabel;
@property (strong, nonatomic) IBOutlet UILabel *grossLabel;
@property (strong, nonatomic) IBOutlet UILabel *netLabel;

@end
