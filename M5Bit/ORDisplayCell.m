//
//  ORDisplayCell.m
//  M5Bit
//
//  Created by Orta on 10/11/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "ORDisplayCell.h"

@implementation ORDisplayCell

- (void)updateWithStat:(ORStat *)stat
{
    self.textLabel.text = [NSString stringWithFormat:@"%ld local %ld fitbit ", (long)stat.m5Steps,  (long)stat.fitbitSteps];
}

@end
