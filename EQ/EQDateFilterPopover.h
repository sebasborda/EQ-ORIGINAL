//
//  EQDateFilterPopover.h
//  EQ
//
//  Created by Sebastian Borda on 5/17/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQPopover.h"

@protocol EQDateFilterPopoverDelegate;

@interface EQDateFilterPopover : UIViewController<EQPopover>

- (id)initWithStartDate:(NSDate *)start endDate:(NSDate *)end delegate:(id<EQDateFilterPopoverDelegate>)delegate;

- (IBAction)saveButtonAction:(id)sender;
- (IBAction)allDatesButtonAction:(id)sender;
- (NSDate *)getPickerStartDate;
- (NSDate *)getPickerEndDate;
- (void)setPickerStartDate:(NSDate *)startDate;
- (void)setPickerEndDate:(NSDate *)endDate;

@property (strong, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *endDatePicker;

@end

@protocol EQDateFilterPopoverDelegate <NSObject>

- (void)dateFilter:(EQDateFilterPopover *)sender didSelectStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end