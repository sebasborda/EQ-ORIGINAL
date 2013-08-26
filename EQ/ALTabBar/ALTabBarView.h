//
//  ALTabBarView.h
//  ALCommon
//
//  Created by Andrew Little on 10-08-17.
//  Copyright (c) 2010 Little Apps - www.myroles.ca. All rights reserved.
//
//  Simple custom TabBar view that is defined in the TabBarView nib and used to 
//  replace the standard iOS TabBar view.  By customizing TabBarView.xib, you can
//  create a tab bar that is unique to your application, but still has the tab
//  switching functionality you've come to expect out of UITabBarController.

#import <UIKit/UIKit.h>

//Delegate methods for responding to TabBar events
@protocol ALTabBarDelegate <NSObject>

//Handle tab bar touch events, sending the index of the selected tab
-(void)tabWasSelected:(NSInteger)index;

@end

@interface ALTabBarView : UIView
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *tabButtons;
@property (nonatomic, weak) id<ALTabBarDelegate> delegate;
@property (nonatomic, strong) UIButton *selectedButton;
 

-(IBAction)touchButton:(id)sender;
-(void)selectTabAtIndex:(int)index;
@end
