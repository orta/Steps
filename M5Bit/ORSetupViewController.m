//
//  ORSetupViewController.m
//  M5Bit
//
//  Created by Orta on 09/11/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "ORSetupViewController.h"
#import <SFHFKeychainUtils/SFHFKeychainUtils.h>
#import "OAuth1Controller.h"
#import "ORStatsViewController.h"

@import CoreMotion;

@interface ORSetupViewController ()

@property (strong, nonatomic) IBOutlet UILabel *m5InfoLabel;
@property (strong, nonatomic) IBOutlet UILabel *fitbitInfoLabel;
@property (strong, nonatomic) IBOutlet UIButton *m5Button;
@property (strong, nonatomic) IBOutlet UIButton *fitbitButton;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;

@property (assign, nonatomic) BOOL hasM5Sorted;
@property (assign, nonatomic) BOOL hasFitBitSorted;
@property (strong, nonatomic) OAuth1Controller *authController;

@end

@implementation ORSetupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"has_access_m7"] && [SFHFKeychainUtils getPasswordForUsername:@"token" andServiceName:@"m7bit" error:nil]) {
        [self.navigationController pushViewController:[[ORStatsViewController alloc]init] animated:NO];
//    }
}

- (IBAction)giveAccessToM5Tapped:(id)sender
{
    if([CMMotionActivityManager isActivityAvailable]) {
        CMMotionActivityManager *manager = [[CMMotionActivityManager alloc] init];
        [manager queryActivityStartingFromDate:[NSDate date] toDate:[NSDate date] toQueue:[NSOperationQueue mainQueue] withHandler:^(NSArray *activities, NSError *error) {
            // error 103 = nothing?
            // error 105 = refused

            BOOL sorted = (error.code != 105);
            self.hasM5Sorted = sorted;

            NSString *message = nil;
            if (sorted) {
                message = @"Alright! We can get access to your activity.";
            } else {
                message = @"Uh Oh looks like you said no. Better go to system prefs.";
            }

            self.m5InfoLabel.text = message;
            self.m5Button.enabled = !sorted;

            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"has_access_m7"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [self checkToEnableContinue];
        }];
    }
}

// Thanks http://omarmetwally.quora.com/Integrating-the-Fitbit-API-in-iOS-apps

- (IBAction)giveAccessToFitBitTapped:(id)sender
{
    self.webView.hidden = NO;

    self.authController = [[OAuth1Controller alloc] init];
    [self.authController loginWithWebView:self.webView completion:^(NSDictionary *oauthTokens, NSError *error) {

        if (!error) {
            // Store your tokens for authenticating your later requests, consider storing the tokens in the Keychain
            NSString *oauthToken = oauthTokens[@"oauth_token"];
            NSString *oauthTokenSecret = oauthTokens[@"oauth_token_secret"];

            [self.webView removeFromSuperview];

            [SFHFKeychainUtils storeUsername:@"token" andPassword:oauthToken forServiceName:@"m7bit" updateExisting:YES error:nil];
            [SFHFKeychainUtils storeUsername:@"secret" andPassword:oauthTokenSecret forServiceName:@"m7bit" updateExisting:YES error:nil];

            self.fitbitButton.enabled = NO;
            self.hasFitBitSorted = YES;

            [self checkToEnableContinue];

        } else {
         NSLog(@"Error authenticating: %@", error.localizedDescription);
     }}];
}

- (void)checkToEnableContinue
{
    self.continueButton.enabled = (self.hasFitBitSorted && self.hasM5Sorted);
}

@end
