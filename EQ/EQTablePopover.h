//
//  EQTablePopover.h
//  EQ
//
//  Created by Sebastian Borda on 4/21/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQPopover.h"

@protocol EQTablePopoverDelegate;

@interface EQTablePopover : UITableViewController<EQPopover>

- (id)initWithData:(NSArray *)data delegate:(id<EQTablePopoverDelegate>)delegate;

@end

@protocol EQTablePopoverDelegate <NSObject>
- (void)tablePopover:(EQTablePopover *)sender selectedRow:(int)rowNumber selectedData:(NSString *)selectedData;
@end
