//
//  EQLoadingView.h
//  EQ
//
//  Created by Sebastian Borda on 4/27/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQLoadingView : UIView

- (id)initViewWithSize:(CGSize)loadingSize showLargeImage:(BOOL)largeImage;
- (void)show;
- (void)hide;

@end
