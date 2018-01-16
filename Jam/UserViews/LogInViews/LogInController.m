//
//  LogInController.m
//  RailJam
//
//  Created by Ben Ferraro on 7/10/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogInController.h"
#import "UIImage+GIF.h"

@interface LogInController ()

@end

@implementation LogInController

- (UIImage*)captureView:(UIView*)view {
    CGRect rect = [view bounds];
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

-(void)viewDidAppear:(BOOL)animated {
    _loggedIn = false;
    _logInButton.userInteractionEnabled = true; // for when logging out, and logging back in
}

-(void)viewDidLoad {
    [super viewDidLoad];
    SPAM(("\nView did load login!\n"));
    
    [self setViewUserInterface]; // set up UI
    // Add Subviews
    [self.view addSubview:self.createAccountButton];
    [self.view addSubview:self.logInUserName];
    [self.view addSubview:self.logInPassword];
    [self.view addSubview:self.logInButton];
    [self.view addSubview:self.emailButton];
    [self.view addSubview:self.tutorialButton];
    [self.view addSubview:self.versionLabel];
    
    // Title Image
    //    _jamTitleImage.image = [UIImage imageNamed:@"jamTitle"]; // title image
    
    /* Font Styles for textFields */
    _versionLabel.text = @"v1.0";
    _versionLabel.font = [UIFont fontWithName:@"ActionMan" size:15.0];
    
    /* Set the text to the User Default Account */
    _logInUserName.text = ((AppDelegate *)([UIApplication sharedApplication].delegate)).defaultAccount.userName;
    NSString *decryptedPW = [Constants decryptPW:((AppDelegate *)([UIApplication sharedApplication].delegate)).defaultAccount.password];
    _logInPassword.text = decryptedPW;
    
    /* Finally, auto login if option is set */
    Account *tmpDeleAcc = ((AppDelegate *)([UIApplication sharedApplication].delegate)).defaultAccount;
    if ([tmpDeleAcc.userName length] > 0 && [tmpDeleAcc.autoLogIn isEqualToString:@"Yes"]) {
        [self logIn:nil];
    }
}

-(void)setViewUserInterface {
    [self setViewGestures];
    [self setButtonUI];
    [self setUpBlurEffects];
    [self setBackGroundImage];
}

-(void)setViewGestures {
    /* For Dismissing keyboard */
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    
    // Forgot Password UILabel Tap Gesture
    UITapGestureRecognizer *tapGesturePassword = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forgotPasswordMail)];
    tapGesturePassword.delegate = self;
    _forgotPassword.userInteractionEnabled = YES;
    [_forgotPassword addGestureRecognizer:tapGesturePassword];
    // Set Label
    NSMutableAttributedString *forgotPWString = [[NSMutableAttributedString alloc] initWithString:@"Forgot Password?"];
    [forgotPWString addAttribute:NSUnderlineStyleAttributeName
                           value:[NSNumber numberWithInt:4]
                           range:(NSRange){0,[forgotPWString length]}];
    _forgotPassword.attributedText = forgotPWString;
}

-(void)setButtonUI {
    /* Set email and tutorial buttons */
    _emailButton.layer.cornerRadius = 10;
    _emailButton.clipsToBounds = YES;
    _emailButton.layer.borderWidth = 3.0f;
    
    _tutorialButton.layer.borderWidth = 3.0f;
    _tutorialButton.clipsToBounds = YES;
    _tutorialButton.layer.cornerRadius = 10;
    
    /* Round edges */
    _logInButton.layer.cornerRadius = 3;
    _logInButton.clipsToBounds = YES;
    _logInUserName.layer.cornerRadius = 3;
    _logInUserName.clipsToBounds = YES;
    _logInPassword.layer.cornerRadius = 3;
    _logInPassword.clipsToBounds = YES;
    _blurViewUN.layer.cornerRadius = 3;
    _blurViewUN.clipsToBounds = YES;
    _blurViewPW.layer.cornerRadius = 3;
    _blurViewPW.clipsToBounds = YES;
    _createAccountButton.layer.cornerRadius = 3;
    _createAccountButton.clipsToBounds = YES;
    _createAccountButton.titleLabel.numberOfLines = 2;
    
    _logInUserName.textColor = [UIColor darkGrayColor];
    _logInPassword.textColor = [UIColor darkGrayColor];
    _logInUserName.placeholderColor = [UIColor darkGrayColor];
    _logInPassword.placeholderColor = [UIColor darkGrayColor];
    
    /* Based on time of day, choose font color */
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH.mm"];
    NSString *strCurrentTime = [dateFormatter stringFromDate:[NSDate date]];
    
    ([strCurrentTime floatValue] >= 18.00 || [strCurrentTime floatValue]  <= 6.00) ? [self nightTime] : [self dayTime];
    
    /* Button constraint layout */
    self.logInButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.createAccountButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.emailButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.tutorialButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    // Set Text Field Delegates
    _logInUserName.delegate = self;
    _logInPassword.delegate = self;
    
}


-(void)dayTime {
    //        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"gif0" ofType:@"gif"];
    //        NSData *gif = [NSData dataWithContentsOfFile:filePath];
    //        FLAnimatedImage *gifBackground = [FLAnimatedImage animatedImageWithGIFData:gif];
    //        gifBG.animatedImage = gifBackground;
    
    
    //        [UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0] // salmon
    //        [UIColor colorWithRed:255.0/255.0 green:184.0/255.0 blue:117.0/255.0 alpha:1.0] // light orange
    
    
    [_emailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _emailButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    [_tutorialButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _tutorialButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    _logInUserName.titleColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0]; // dank blue
    _logInPassword.titleColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    _logInUserName.selectedTitleColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    _logInPassword.selectedTitleColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    _logInUserName.selectedLineColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    _logInPassword.selectedLineColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    
    _forgotPassword.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    
    /* Button Color */
    [_logInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_createAccountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _versionLabel.textColor = [UIColor whiteColor];
    
    _logInButton.backgroundColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    _createAccountButton.backgroundColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
}

-(void)nightTime {
    /* Gif moving background */
    //        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"nightGif" ofType:@"gif"];
    //        NSData *gif = [NSData dataWithContentsOfFile:filePath];
    //        FLAnimatedImage *gifBackground = [FLAnimatedImage animatedImageWithGIFData:gif];
    //        gifBG.animatedImage = gifBackground;
    
    //        [UIColor colorWithRed:247.0/255.0 green:218.0/255.0 blue:74.0/255.0 alpha:1.0]; // light dirty yellow
    
    [_emailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _emailButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    [_tutorialButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _tutorialButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    _logInUserName.titleColor = [UIColor colorWithRed:255.0/255.0 green:81.0/255.0 blue:68.0/255.0 alpha:1.0];
    _logInPassword.titleColor = _logInUserName.titleColor = [UIColor colorWithRed:255.0/255.0 green:81.0/255.0 blue:68.0/255.0 alpha:1.0];
    _logInUserName.selectedTitleColor = [UIColor colorWithRed:255.0/255.0 green:81.0/255.0 blue:68.0/255.0 alpha:1.0];
    _logInPassword.selectedTitleColor = [UIColor colorWithRed:255.0/255.0 green:81.0/255.0 blue:68.0/255.0 alpha:1.0];
    _logInUserName.selectedLineColor = [UIColor colorWithRed:255.0/255.0 green:81.0/255.0 blue:68.0/255.0 alpha:1.0];
    _logInPassword.selectedLineColor = [UIColor colorWithRed:255.0/255.0 green:81.0/255.0 blue:68.0/255.0 alpha:1.0];
    
    _forgotPassword.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    
    /* Button Color */
    [_logInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_createAccountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _versionLabel.textColor = [UIColor whiteColor];
    
    _logInButton.backgroundColor = _logInUserName.titleColor = [UIColor colorWithRed:255.0/255.0 green:81.0/255.0 blue:68.0/255.0 alpha:1.0];
    _createAccountButton.backgroundColor = _logInUserName.titleColor = [UIColor colorWithRed:255.0/255.0 green:81.0/255.0 blue:68.0/255.0 alpha:1.0];
    
}

-(void)setUpBlurEffects {
    /* Blur Effect */
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    
    /* Set up UN blur views */
    UIVisualEffectView *visualEffectViewUN;
    visualEffectViewUN = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectViewUN.frame = self.view.bounds;
    visualEffectViewUN.backgroundColor = [UIColor clearColor];
    visualEffectViewUN.alpha = 1.5;
    visualEffectViewUN.clipsToBounds = true;
    
    /* Set up PW blur views */
    UIVisualEffectView *visualEffectViewPW;
    visualEffectViewPW = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectViewPW.frame = self.view.bounds;
    visualEffectViewPW.backgroundColor = [UIColor clearColor];
    visualEffectViewPW.alpha = 1.5;
    visualEffectViewPW.clipsToBounds = true;
    
    // Blur background
    _blurViewUN.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    _blurViewPW.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    [_blurViewUN addSubview:visualEffectViewUN];
    [_blurViewPW addSubview:visualEffectViewPW];
    [self.view sendSubviewToBack:_blurViewUN];
    [self.view sendSubviewToBack:_blurViewPW];
}

-(void)setBackGroundImage {
    /* Background Gif */
    FLAnimatedImageView *gifBG = [[FLAnimatedImageView alloc] init];
    CGRect newBackGroundFrame = CGRectMake(-20, -20, self.view.frame.size.width+35, self.view.frame.size.height+35);
    gifBG.frame = newBackGroundFrame;

    // Background Image
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dojo1.jpg"]];
    bg.contentMode = UIViewContentModeScaleAspectFill;
    bg.frame = CGRectMake(-20.0, -20.0, self.view.frame.size.width+35.0, self.view.frame.size.height+35.0);
    [self.view addSubview:bg];
    [self.view sendSubviewToBack:bg];
    
    /* Perspective View */
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-20);
    verticalMotionEffect.maximumRelativeValue = @(20);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-20);
    horizontalMotionEffect.maximumRelativeValue = @(20);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [bg addMotionEffect:group];
}


- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)activateLogIn {
    _logInButton.userInteractionEnabled = true;
}

-(IBAction)logIn:(id)sender {
    
    [self performSelector:@selector(activateLogIn) withObject:nil afterDelay:2.0];
    _logInButton.userInteractionEnabled = false;
    
    // progress bar
    [SVProgressHUD showWithStatus:@"Logging In..."];
    
    self.logInAccount = [[Account alloc] init];

    if (!self.logInUserName.text.length || !self.logInPassword.text.length) {
    
        // Dismiss Bar
        [SVProgressHUD dismiss];
        
        // Username or PW is blank...
        [AlertView showAlertTab:@"Username or Password is blank" view:self.view];
    
    } else {
        [Account loadAccount:kBaseURL userName:self.logInUserName.text initialLoad:@"yes" message:@"0"
                    callback:^(NSError *error, BOOL success, NSDictionary *responseAccount, NSInteger statusCode) {
                        if (success && [responseAccount objectForKey:@"userName"] != nil) {
                            SPAM(("\nGot Account success\n"));
                            /* Must do segue in main thread */
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                dispatch_async(dispatch_get_main_queue(), ^{

                                    // Dismiss Bar
                                    [SVProgressHUD dismiss];

                                    /* Compare (encrypted) plaintext user enetered PW to the DB encrypted password */
                                    NSString *encryptedPW = [Constants encryptPW:self.logInPassword.text];
                                    if ([encryptedPW isEqualToString:[responseAccount objectForKey:@"password"]]) {

                                        if (!_loggedIn) {
                                            _loggedIn = true;
                                            _logInButton.userInteractionEnabled = false;
                                            
                                            /* Load account with data */
                                            [self.logInAccount initWithDictionary:responseAccount];
                                            
                                            // If first time loading app, one must init default account
                                            // Also set Autologin to YES
                                            if (((AppDelegate *)([UIApplication sharedApplication].delegate)).defaultAccount == nil) {
                                                ((AppDelegate *)([UIApplication sharedApplication].delegate)).defaultAccount = [[Account alloc] init];
                                                ((AppDelegate *)([UIApplication sharedApplication].delegate)).defaultAccount.autoLogIn = @"Yes";
                                            }
                                            
                                            /* Sets the user deafult account UN and PW, persists past termination */
                                            ((AppDelegate *)([UIApplication sharedApplication].delegate)).defaultAccount.userName = self.logInAccount.userName;
                                            ((AppDelegate *)([UIApplication sharedApplication].delegate)).defaultAccount.password = self.logInAccount.password; // always encrypted
                                            ((AppDelegate *)([UIApplication sharedApplication].delegate)).defaultAccount._accountid = self.logInAccount._accountid;
                                            
                                            /* Update Accounts lastLogOn */
                                            NSDate *currDate = [NSDate date]; // Get Date
                                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                            [formatter setDateFormat:@"dd-MM-yyyy"];
                                            NSString *stringFromDate = [formatter stringFromDate:currDate];
                                            self.logInAccount.lastLogOn = stringFromDate;
                                            
                                            if (responseAccount[@"message"] == nil) {
                                                _dailyMessageInfo = [[NSMutableString alloc] initWithString:@"Could not retrieve daily message!"];
                                            } else {
                                                _dailyMessageInfo = responseAccount[@"message"];
                                            }
                                            
                                            [self performSegueWithIdentifier:@"mainSegue" sender:self];
                                        }
                                    } else {
                                        [AlertView showAlertTab:@"No Accout with that Password" view:self.view];
                                        _logInButton.userInteractionEnabled = true;
                                    }
                                });
                            });
                        } else { // error or account not found
                            dispatch_async(dispatch_get_main_queue(), ^{
                                // Dismiss Bar
                                [SVProgressHUD dismiss];
                                
                                _logInButton.userInteractionEnabled = true;
                                
                                if (!success) {
                                    NSLog(@"%@", error);
                                    /* Loading alert box */
                                    NSString *alertControllerBadAccountTitle;
                                    NSString *alertControllerBadAccountMessage;
                                    if (statusCode == 0) {
                                        alertControllerBadAccountTitle = @"Trouble logging on! Give it another shot -- The servers may be down for maintenance...";
                                        alertControllerBadAccountMessage = @"Thank you for your patience.";
                                    } else {
                                        alertControllerBadAccountTitle = @"Could not load account";
                                        alertControllerBadAccountMessage = nil;
                                    }

                                    [AlertView showAlertControllerOkayOption:alertControllerBadAccountTitle message:alertControllerBadAccountMessage view:self];
                                } else {
                                    [AlertView showAlertTab:@"No Accout with that Username" view:self.view];
                                }
                            });
                    }
        }]; // end load account
    }
}

- (IBAction)createAccount:(id)sender {
    // Dismiss Bar
    [SVProgressHUD dismiss];
    [self performSegueWithIdentifier:@"createAccountSegue" sender:self];
}

/* Called from CreateAccount.m */
-(void)toTutorialUN:(NSString*)userName {
    
    /* Set username and PW text boxes */
    _logInUserName.text = userName;
    _logInPassword.text = @"";
    
    [self dismissViewControllerAnimated:YES completion:^() {
        
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        
        TutorialControllerMain *tc = [storyboard instantiateViewControllerWithIdentifier:@"TutorialControllerMain"];
        
        [self presentViewController:tc animated:YES completion:nil];
    }];
}


/* Write an email*/
- (IBAction)mailButton:(id)sender {
    // Dismiss Bar
    [SVProgressHUD dismiss];
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
        composeVC.mailComposeDelegate = self;
        // Configure the fields of the interface.
        [composeVC setToRecipients:@[@"jammercommunity@gmail.com"]];
        [composeVC setSubject:@"Questions, Comments, Complaints"];
        [composeVC setMessageBody:@"Greetings Jammer!\n\n Please send us your thoughts, photos, videos, stories...etc! Along with your User Name...\n\nUser Name:" isHTML:false];
        
        // Present the view controller modally.
        [self presentViewController:composeVC animated:true completion:nil];
    }
}

/* Write an email for PW retrevial */
-(void)forgotPasswordMail {
    // Dismiss Bar
    [SVProgressHUD dismiss];
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
        composeVC.mailComposeDelegate = self;
        // Configure the fields of the interface.
        [composeVC setToRecipients:@[@"jammercommunity@gmail.com"]];
        [composeVC setSubject:@"Password retrieval"];
        [composeVC setMessageBody:@"Greetings Jammer!\n\n If you have forgotten your password, please send us your User Name and Name and we will get back to you!\n\nUser Name:\nName:" isHTML:false];
        
        // Present the view controller modally.
        [self presentViewController:composeVC animated:true completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error; {
    
    if (result == MFMailComposeResultSent) {
        SPAM(("It's away!\n"));
    } else {
        // load an error
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


/* SEGUE CODE */
// Pass in info to next page
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    /* 'mainSegue' goes to main view */
    if ([[segue identifier] isEqualToString:@"mainSegue"]) {
        ViewController *vc = [segue destinationViewController];
        vc.mainAccount = _logInAccount;
        vc.dailyMessage = _dailyMessageInfo;
    } else if ([[segue identifier] isEqualToString:@"createAccountSegue"]) {
        CreateAccountController *cc = [segue destinationViewController];
        cc.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"tutorialSegue"]) {
    }
}

@end
