//
//  ORFitbitAPI.m
//  M5Bit
//
//  Created by Orta on 09/11/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

// BEWARE OAUTH1 DRAGONS

#import "ORFitbitAPI.h"
#import <AFNetworking/AFNetworking.h>
#import <SFHFKeychainUtils/SFHFKeychainUtils.h>
#import <NSDate-Extensions/NSDate-Utilities.h>
#import "OAuth1Controller.h"
#import <ASIHTTPRequest/ASIFormDataRequest.h>
#import "ASIHTTPRequest+OAuth.h"
#import "ASIFormDataRequest+OAuth.h"

@interface ORFitbitAPI()
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *secret;
@end


// https://wiki.fitbit.com/display/API/API+Explorer


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

- (BOOL)running
{
    return self.manager.tasks.count > 0;
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

- (void)setSteps:(NSInteger)steps forDaysAgo:(NSInteger)daysAgo :(void (^)(id JSON))onComplete failure:(void (^)(NSError *error))onFailure
{
    NSDate *date = [NSDate dateWithDaysBeforeNow:daysAgo];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];

    NSString *dayString = [formatter stringFromDate:date];


    NSDictionary *params = @{
        @"activityId" : @"90009",
        @"date": dayString,
        @"distanceUnit":@"Steps",
        @"distance": @(steps),
        @"startTime": @"00:00",
        @"durationMillis": @(43200000)
    };


#define CONSUMER_KEY         @"5a3cf6a5e3e6421787f0025ba16b9fef"
#define CONSUMER_SECRET      @"b578124cd1c64bcda908878a2183110d"

    NSURL *url = [NSURL URLWithString:@"https://api.fitbit.com/1/user/-/activities.json"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];

    NSArray                 *parameterKeys = [params allKeys];
    NSInteger i;
    NSMutableDictionary     *simpleParameters = [[NSMutableDictionary alloc] init];
    NSString *key = nil;

    //Setup parameters for both Simple-OAuth1 POST request and ASIHTTP POST request
    for(i = 0; i < [parameterKeys count]; i++)
    {
        key = [parameterKeys objectAtIndex:i];
        [request setPostValue:[params objectForKey:key] forKey:key];
        [simpleParameters setObject:[params objectForKey:key] forKey:key];
    }

    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type"                                   value:@"application/x-www-form-urlencoded"];
    [request signRequestWithClientIdentifier:CONSUMER_KEY secret:CONSUMER_SECRET tokenIdentifier:self.token secret:self.secret usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];

    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request       //Deal with completed asynchronous ASI HTTP Request
{
    if (request.responseStatusCode == 201)
    {
        //parse out the json data
        NSData *responseData = [request responseData];
        NSError* error;

        NSArray* json = [NSJSONSerialization
                         JSONObjectWithData:responseData
                         options:kNilOptions
                         error:&error];

        NSLog(@"JSON: %@", json);
    }
    else
    {
        // @"Unexpected error";
        NSLog(@"Error Code: %d", request.responseStatusCode);
    }

}

- (void)requestFailed:(ASIHTTPRequest *)request         //Deal with failed ASI HTTP Request
{
    NSError *error = [request error];

    NSLog(@"requestFailed: %@ - \n %@", error, request.responseString);
    
}



@end