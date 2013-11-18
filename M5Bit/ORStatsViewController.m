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
#import "ORStat.h"
#import "ORDisplayCell.h"
#import "ARReusableLoadingView.h"

@import CoreMotion;

@interface ORStatsViewController ()
@property (strong, nonatomic) CMStepCounter *stepCounter;
@property (strong, nonatomic) NSMutableArray *stats;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger weekIndex;


@end

@implementation ORStatsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[ORDisplayCell class] forCellReuseIdentifier:@"SearchCell"];
    [self.tableView registerClass:[ARReusableLoadingView class] forCellReuseIdentifier:@"LoadingCell"];

    self.stepCounter = [[CMStepCounter alloc] init];
    self.stats = [NSMutableArray array];
    self.weekIndex = 0;
    self.navigationItem.hidesBackButton = YES;

    [self getWeekAtIndex:self.weekIndex];
    [self startTimer];
}

- (void)startTimer
{
    if (self.timer) {
        return;
    }

    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)tick:(NSTimer *)timer
{
    BOOL networkIsFree = ![[ORFitbitAPI sharedAPI] running];
    BOOL nearBottom = (self.tableView.contentSize.height - CGRectGetHeight(self.view.bounds) - self.tableView.contentOffset.y) < 300;

    if (networkIsFree && nearBottom) {
        self.weekIndex++;
        [self getWeekAtIndex:self.weekIndex];
    }

    NSLog(@"%i - %i",networkIsFree, nearBottom);
}


- (void)getWeekAtIndex:(NSInteger)index
{
    NSInteger max = index + 7;

    for (NSInteger i = index; i < max; i++) {

        __block ORStat *stat = [[ORStat alloc] init];

        NSDate *firstDay = [NSDate dateWithDaysBeforeNow:i];
        NSDate *lastDay = [NSDate dateWithDaysBeforeNow:i + 1];
        stat.daysAgo = i;
        
        NSOperationQueue *queue = [NSOperationQueue new];

        [self.stepCounter queryStepCountStartingFrom:lastDay to:firstDay toQueue:queue withHandler:^(NSInteger numberOfSteps, NSError *error) {
            stat.m5Steps = numberOfSteps;

            NSLog(@"%ld steps", (long)stat.m5Steps);

            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *path = [NSIndexPath indexPathForItem:i inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        }];

        [[ORFitbitAPI sharedAPI] getStepsForDaysAgo:i :^(id JSON) {
            NSNumber *steps = JSON[@"summary"][@"steps"];
            stat.fitbitSteps = steps.integerValue;

            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *path = [NSIndexPath indexPathForItem:i inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
            });


        } failure:^(NSError *error) {
            NSLog(@"error");
            stat.fitbitSteps = -1;

            // THERE IS A RATE LIMIT!
        }];

        [self.stats addObject:stat];
    }

    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return self.stats.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isLastIndex = indexPath.row == self.stats.count;
    NSString *identifier = isLastIndex? @"LoadingCell" : @"SearchCell";

    ORDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (isLastIndex) return cell;

    ORStat *stat = self.stats[indexPath.row];
    [cell updateWithStat:stat];

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row == self.stats.count){
        return nil;
    };
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ORStat *stat = self.stats[indexPath.row];

    [[ORFitbitAPI sharedAPI] setSteps:stat.m5Steps forDaysAgo:indexPath.row :^(id JSON) {
        NSLog(@"win");
        stat.fitbitSteps = stat.m5Steps;

        ORDisplayCell *cell = (id)[tableView  cellForRowAtIndexPath:indexPath];
        [cell updateWithStat:stat];

    } failure:^(NSError *error) {
        NSLog(@"fail");
    }];
}

@end
