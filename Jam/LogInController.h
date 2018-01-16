//
//  LogInController.h
//  RailJam
//
//  Created by Ben Ferraro on 7/10/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef LogInController_h
#define LogInController_h
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

#import "ViewController.h"
#import "CreateAccountController.h"
#import "Account.h"
#import "TutorialControllerMain.h"
#import "AlertView.h"
#import "DailyMessage.h"
#import "Constants.h"
#import <MessageUI/MFMailComposeViewController.h>

@import SkyFloatingLabelTextField;
@import FLAnimatedImage;

@interface LogInController : UIViewController <UIGestureRecognizerDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate, CreateAccountControllerDelegate>

// For loading main view / user info once when loggin in
@property BOOL loggedIn;

// Logged in account
@property Account *logInAccount;

@property (strong, nonatomic) IBOutlet UIImageView *jamTitleImage;

/* Labels */
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;

/* Text Fields */
@property (strong, nonatomic) IBOutlet SkyFloatingLabelTextField *logInUserName;
@property (strong, nonatomic) IBOutlet SkyFloatingLabelTextField *logInPassword;
@property (strong, nonatomic) IBOutlet NSMutableString *dailyMessageInfo;

/* Buttons */
@property (strong, nonatomic) IBOutlet UIButton *logInButton;
@property (strong, nonatomic) IBOutlet UIButton *createAccountButton;
@property (strong, nonatomic) IBOutlet UIButton *emailButton;
@property (strong, nonatomic) IBOutlet UIButton *tutorialButton;
@property (weak, nonatomic) IBOutlet UILabel *forgotPassword;

@property (strong, nonatomic) IBOutlet UIView *blurViewUN;
@property (strong, nonatomic) IBOutlet UIView *blurViewPW;


// Methods
-(void)viewDidLoad;
-(IBAction)logIn:(id)sender;


@end

#endif /* LogInController_h */
