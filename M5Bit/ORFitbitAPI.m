//
//  ORFitbitAPI.m
//  M5Bit
//
//  Created by Orta on 09/11/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "ORFitbitAPI.h"
#import <AFNetworking/AFNetworking.h>
#import <SFHFKeychainUtils/SFHFKeychainUtils.h>
#import <NSDate-Extensions/NSDate-Utilities.h>
#import "OAuth1Controller.h"

@interface ORFitbitAPI()
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) AFHTTPRequestSerializer *serializer;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *secret;
@end

@implementation ORFitbitAPI

+ (ORFitbitAPI *)sharedAPI
{
    static ORFitbitAPI *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;

    NSURL *baseURL = [NSURL URLWithString:@"https://api.fitbit.com/"];
    _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];

    _token = [SFHFKeychainUtils getPasswordForUsername:@"token" andServiceName:@"m7bit" error:nil];
    _secret = [SFHFKeychainUtils getPasswordForUsername:@"secret" andServiceName:@"m7bit" error:nil];

    return self;
}

- (void)getStepsForDaysAgo:(NSInteger)daysAgo :(void (^)(id JSON))onComplete failure:(void (^)(NSError *error))onFailure
{
    NSDate *date = [NSDate dateWithDaysBeforeNow:daysAgo];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];

    NSString *dayString = [NSString stringWithFormat:@"1/user/-/activities/date/%@.json",[formatter stringFromDate:date]];

    NSURLRequest *request = [OAuth1Controller preparedRequestForPath:dayString parameters:@{} HTTPmethod:@"GET" oauthToken:self.token oauthSecret:self.secret];

    NSURLSessionDataTask *task = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error && onFailure) {
            onFailure(error);
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                onComplete(responseObject);
            });
        }
    }];

    [task resume];
}


@end