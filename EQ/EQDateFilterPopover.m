//
//  EQDateFilterPopover.m
//  EQ
//
//  Created by Sebastian Borda on 5/17/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQDateFilterPopover.h"

#define POPOVER_WIDTH 320
#define POPOVER_HEIGHT 475

@interface EQDateFilterPopover ()

@property (strong, nonatomic) NSDate* startDate;
@property (strong, nonatomic) NSDate* endDate;
@property (strong, nonatomic) id<EQDateFilterPopoverDelegate> delegate;

@end

@implementation EQDateFilterPopover

- (id)initWithStartDate:(NSDate *)start endDate:(NSDate *)end delegate:(id)delegate{
    self = [super init];
    if (self) {
        self.startDate = start;
        self.endDate = end;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    if (self.startDate && self.endDate) {
        [self setPickerStartDate:self.startDate];
        [self setPickerEndDate:self.endDate];
    } else {
        self.startDatePicker.date = self.startDatePicker.minimumDate;
        self.endDatePicker.date = [NSDate date];
    }
    self.startDatePicker.maximumDate = [NSDate date];
    self.endDatePicker.maximumDate = [NSDate date];
}

- (CGSize)popoverSize{
    return CGSizeMake(POPOVER_WIDTH, POPOVER_HEIGHT);
}

- (IBAction)saveButtonAction:(id)sender {
        [self.delegate dateFilter:self didSelectStartDate:[self getPickerStartDate] endDate:[self getPickerEndDate]];
}

- (IBAction)allDatesButtonAction:(id)sender {
    [self.delegate dateFilter:self didSelectStartDate:nil endDate:nil];
}

- (NSDate *)getPickerStartDate{
    return self.startDatePicker.date;
}

- (NSDate *)getPickerEndDate{
    return self.endDatePicker.date;
}

- (void)setPickerStartDate:(NSDate *)startDate{
    self.startDatePicker.date = startDate;
}

- (void)setPickerEndDate:(NSDate *)endDate{
    self.endDatePicker.date = endDate;
}

@end
