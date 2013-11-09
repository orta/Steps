//
//  ORViewController.m
//  M5Bit
//
//  Created by Orta on 09/11/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "ORStatsViewController.h"
#import <NSDate-Extensions/NSDate-Utilities.h>
#import "ORFitbitAPI.h"


@import CoreMotion;

@interface Stat : NSObject
@property (assign, nonatomic) NSInteger m5Steps;
@property (assign, nonatomic) NSInteger fitbitSteps;
@end

@implementation Stat
@end

@interface ORStatsViewController ()
@property (strong, nonatomic) CMStepCounter *stepCounter;
@property (strong, nonatomic) NSMutableArray *stats;
@end

@implementation ORStatsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SearchCell"];

    self.stepCounter = [[CMStepCounter alloc] init];
    self.stats = [NSMutableArray array];

    [self getWeekAtIndex:0];
}

- (void)getWeekAtIndex:(NSInteger)index
{
    NSInteger max = index + 7;

    for (NSInteger i = index; i < max; i++) {

        __block Stat *stat = [[Stat alloc] init];

        NSDate *firstDay = [NSDate dateWithDaysBeforeNow:i];
        NSDate *lastDay = [NSDate dateWithDaysBeforeNow:i + 1];
        NSOperationQueue *queue = [NSOperationQueue new];

        [self.stepCounter queryStepCountStartingFrom:lastDay to:firstDay toQueue:queue withHandler:^(NSInteger numberOfSteps, NSError *error) {
            stat.m5Steps = numberOfSteps;

            NSLog(@"%ld steps", (long)stat.m5Steps);

            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *path = [NSIndexPath indexPathForItem:i inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        }];

        [[ORFitbitAPI sharedAPI] getStepsForDaysAgo:0 :^(id JSON) {
            NSNumber *steps = JSON[@"summary"][@"steps"];
            stat.fitbitSteps = steps.integerValue;

            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *path = [NSIndexPath indexPathForItem:i inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
            });


        } failure:^(NSError *error) {
            NSLog(@"error");
        }];


        [self.stats addObject:stat];
    }

    [self.tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return self.stats.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    Stat *stat = self.stats[indexPath.row];

    cell.textLabel.text = [NSString stringWithFormat:@"%ld local %ld fitbit ", (long)stat.m5Steps,  (long)stat.fitbitSteps];

    return cell;
}




@end
