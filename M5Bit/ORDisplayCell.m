//
//  ORDisplayCell.m
//  M5Bit
//
//  Created by Orta on 10/11/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "ORDisplayCell.h"
#import <NSDate-Extensions/NSDate-Utilities.h>

@implementation ORDisplayCell

- (void)updateWithStat:(ORStat *)stat
{
    NSDate *date = [NSDate dateWithDaysBeforeNow:stat.daysAgo];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];


    self.textLabel.text = [NSString stringWithFormat:@"%@ - %ld local / %ld fitbit ",[formatter stringFromDate:date], (long)stat.m5Steps,  (long)stat.fitbitSteps];
}

@end
