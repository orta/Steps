//
//  ORFitbitAPI.h
//  M5Bit
//
//  Created by Orta on 09/11/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//


@interface ORFitbitAPI : NSObject

+ (ORFitbitAPI *)sharedAPI;

- (void)getStepsForDaysAgo:(NSInteger)daysAgo :(void (^)(id JSON))onComplete failure:(void (^)(NSError *error))onFailure;

@end
