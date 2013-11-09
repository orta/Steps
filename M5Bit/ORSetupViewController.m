//
//  ORSetupViewController.m
//  M5Bit
//
//  Created by Orta on 09/11/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "ORSetupViewController.h"
#import <STLOAuth/STLOAuthClient.h>
#import "OAuth1Controller.h"

@import CoreMotion;

@interface ORSetupViewController ()

@property (strong, nonatomic) IBOutlet UILabel *m5InfoLabel;
@property (strong, nonatomic) IBOutlet UILabel *fitbitInfoLabel;
@property (strong, nonatomic) IBOutlet UIButton *m5Button;
@property (strong, nonatomic) IBOutlet UIButton *fitbitButton;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (assign, nonatomic) BOOL hasM5Sorted;
@property (assign, nonatomic) BOOL hasFitBitSorted;
@property (strong, nonatomic) OAuth1Controller *authController;

@end

@implementation ORSetupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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

            self.fitbitInfoLabel.text = message;
            self.m5Button.enabled = !sorted;

        }];
    }
}

// Thanks http://omarmetwally.quora.com/Integrating-the-Fitbit-API-in-iOS-apps

- (IBAction)giveAccessToFitBitTapped:(id)sender
{
    self.webView.hidden = NO;

    self.authController = [[OAuth1Controller alloc] init];
    [self.authController loginWithWebView:self.webView completion:^(NSDictionary *oauthTokens, NSError *error) {
         NSLog(@"HIHHIHHIIHHI");
        
        if (!error) {
         // Store your tokens for authenticating your later requests, consider storing the tokens in the Keychain
//         self.oauthToken = oauthTokens[@"oauth_token"];
//         self.oauthTokenSecret = oauthTokens[@"oauth_token_secret"];

//         self.accessTokenLabel.text = self.oauthToken;
//         self.accessTokenSecretLabel.text = self.oauthTokenSecret;
            [self.webView removeFromSuperview];

     } else {
         NSLog(@"Error authenticating: %@", error.localizedDescription);
     }}];

}



@end
