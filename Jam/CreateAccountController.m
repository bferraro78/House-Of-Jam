//
//  createAccountController.m
//  RailJam
//
//  Created by Ben Ferraro on 7/10/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CreateAccountController.h"

@implementation CreateAccountController


- (UIImage*)captureView:(UIView*)view {
    CGRect rect = [view bounds];
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    SPAM(("\nEnter Create Account View\n"));
 
    /* Create Account Object */
    self.createAccount = [[Account alloc] init];
    
    /* For Dismissing keyboard */
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];

    /* Scroll View */
    _scrollView.bounces = false;
    
    /* Top User Name */
    _createAccountLine.layer.cornerRadius = 10; // rounded edges
    _createAccountLine.clipsToBounds = YES;
    _createAccountLine.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:219.0/255.0 blue:88.0/255.0 alpha:1.0]; // banana
    _createAccountLabel.textColor = [UIColor whiteColor]; // white
    _createAccountLabel.text = @"Create Account";
    [self.view bringSubviewToFront:_createAccountLabel];
    
    /* Button Color/frame */
    _createAccountButton.layer.cornerRadius = 3; // rounded edges
    _createAccountButton.clipsToBounds = YES;
    [_createAccountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; // color and boarder
    _createAccountButton.backgroundColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    _createAccountButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    _createAccountButton.layer.borderWidth = 1.5;
    
    _voidAccount.layer.cornerRadius = 3; // rounded edges
    _voidAccount.clipsToBounds = YES;
    [_voidAccount setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; // color and boarder
    _voidAccount.backgroundColor = [UIColor whiteColor];
    _voidAccount.layer.borderColor = [[UIColor blackColor] CGColor];
    _voidAccount.layer.borderWidth = 2.0;
    
    /* Blur Effect */
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    
    /* Set up blur views */
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = _createEmail.bounds;
    visualEffectView.backgroundColor = [UIColor clearColor];
    visualEffectView.alpha = 1.5;
    visualEffectView.clipsToBounds = true;
    
    _createEmail.background = [self captureView:visualEffectView];
    _createUserName.background = [self captureView:visualEffectView];
    _name.background = [self captureView:visualEffectView];
    _createPassword.background = [self captureView:visualEffectView];
    _reenterPassword.background = [self captureView:visualEffectView];
    _hometown.background = [self captureView:visualEffectView];

    // Center text
    _createEmail.textAlignment = NSTextAlignmentCenter;
    _createUserName.textAlignment = NSTextAlignmentCenter;
    _name.textAlignment = NSTextAlignmentCenter;
    _createPassword.textAlignment = NSTextAlignmentCenter;
    _reenterPassword.textAlignment = NSTextAlignmentCenter;
    _hometown.textAlignment = NSTextAlignmentCenter;
    
    _createEmail.layer.cornerRadius = 3;
    _createEmail.clipsToBounds = YES;
    _createUserName.layer.cornerRadius = 3;
    _createUserName.clipsToBounds = YES;
    _name.layer.cornerRadius = 3;
    _name.clipsToBounds = YES;
    _createPassword.layer.cornerRadius = 3;
    _createPassword.clipsToBounds = YES;
    _reenterPassword.layer.cornerRadius = 3;
    _reenterPassword.clipsToBounds = YES;
    _hometown.layer.cornerRadius = 3;
    _hometown.clipsToBounds = YES;
    
    /* Set up text fields */
    _createUserName.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    _createPassword.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    _createEmail.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    _reenterPassword.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    _name.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    _hometown.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    
    // to be in front of blur view
    [self.view bringSubviewToFront:_createUserName];
    [self.view bringSubviewToFront:_createEmail];
    [self.view bringSubviewToFront:_createPassword];
    [self.view bringSubviewToFront:_reenterPassword];
    [self.view bringSubviewToFront:_name];
    [self.view bringSubviewToFront:_hometown];
    
    /* Text field delegates*/
    _createPassword.delegate = self;
    _createUserName.delegate = self;
    _createEmail.delegate = self;
    _reenterPassword.delegate = self;
    _name.delegate = self;
    _hometown.delegate = self;

    // Tags
    _createUserName.tag = 4;
    _createPassword.tag = 5;
    _hometown.tag = 6;
    
    /* Background images */
    // Extend self.view.fram past the bounds of frame to account for perspective view
    CGRect newBackGroundFrame = CGRectMake(-20, -20, self.view.frame.size.width+35, self.view.frame.size.height+35);
    _backGroundPic = [[UIImageView alloc] initWithFrame:newBackGroundFrame];
    _backGroundPic.image = [UIImage imageNamed:@"parchmentBackground"];
    _backGroundPic.alpha = 0.9;
    _backGroundPic.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_backGroundPic];
    [self.view sendSubviewToBack:_backGroundPic];
    
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
    [_backGroundPic addMotionEffect:group];
    
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)createAccountButton:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Creating account..."];
    
    // Can't hit twice
    _createAccountButton.userInteractionEnabled = false;
    
    if (![self.createPassword.text isEqualToString:self.reenterPassword.text]) {
        [AlertView showAlertTab:@"Passwords do not match!" view:self.view];
        
        _createAccountButton.userInteractionEnabled = true; // something didn't work
        
        [SVProgressHUD dismiss];
        
    } else if (!_createUserName.hasErrorMessage && !_createPassword.hasErrorMessage && [_name.text length] != 0 && [_createUserName.text length] != 0 && [_createPassword.text length] != 0 && [_reenterPassword.text length] != 0 && [_createEmail.text length] != 0) {
        
        [Account loadAccount:kBaseURL userName:self.createUserName.text initialLoad:@"no" message:@"0"
                    callback:^(NSError *error, BOOL success, NSDictionary *responseAccount, NSInteger statusCode) {
                        /* Check if user name exists */
                        if (success && [responseAccount objectForKey:@"userName"] == nil) {
                            SPAM(("\nGot Account success\n"));
                            
                            [SVProgressHUD dismiss];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                /* Create an account with the correct attributes and call add account */
                                NSDate *currDate = [NSDate date]; // Get Date
                                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                [formatter setDateFormat:@"dd-MM-yyyy"];
                                NSString *stringFromDate = [formatter stringFromDate:currDate];
                                
                                [self.createAccount inituserName:self.createUserName.text name:self.name.text email:self.createEmail.text
                                                        password:self.createPassword.text hometown:_hometown.text lastLogOn:stringFromDate];
                                
                                /* Encrypt password */
                                NSString *encryptedPW = [Constants encryptPW:self.createAccount.password];
                                _createAccount.password = encryptedPW;
                                
                                /* Add account to DB */
                                [self.createAccount addAccount:kBaseURL message:@"0"];
                                
                                id<CreateAccountControllerDelegate> strongDelegate = self.delegate;
                                
                                if ([strongDelegate respondsToSelector:@selector(toTutorialUN:)]) {
                                    [strongDelegate toTutorialUN:_createAccount.userName];
                                }
                                
                                [self dismissViewControllerAnimated:YES completion:nil];
                            });
                            
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                // Dismiss loading animation
                                [SVProgressHUD dismiss];
                                if (!success) {
                                    /* Loading alert box */
                                    [AlertView showAlertControllerOkayOption:@"Trouble creating account" message:@"Please try again" view:self];
                                } else {
                                    [AlertView showAlertTab:@"User Name already exists!" view:self.view];
                                }
                                
                                _createAccountButton.userInteractionEnabled = true; // something didn't work
                            });
                        }
                    }];
        
    } else {
        
        [SVProgressHUD dismiss];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_name.text length] == 0) { // blank name
                [AlertView showAlertTab:@"Name is blank" view:self.view];
            } else if ([_createUserName.text length] == 0) { // blank username
                [AlertView showAlertTab:@"Username is blank" view:self.view];
            } else if ([_createPassword.text length] == 0) { // blank password
                [AlertView showAlertTab:@"Password is blank" view:self.view];
            } else if ([_reenterPassword.text length] == 0) { // blank reEnterPW
                [AlertView showAlertTab:@"Reenter password is blank" view:self.view];
            } else if ([_createEmail.text length] == 0) { // blank email
                [AlertView showAlertTab:@"Email is blank" view:self.view];
            } else { // error in one of the field
                /* Loading alert box */
                [AlertView showAlertControllerOkayOption:@"User Names and Passwords may only contain: A-Z(upper/lower case), 0-9, non leading/trailing spaces. Must be at least 4 characters, and less than 15!" message:nil view:self];
                
            }
            _createAccountButton.userInteractionEnabled = true; // something didn't work
        });
    }
}


/* Text Field Delegate method for SkyFloatingtextField Error */
-(BOOL)textField:(SkyFloatingLabelTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    
    NSMutableString *testString = [NSMutableString stringWithString:textField.text];
    [testString replaceCharactersInRange:range withString:string];
    
    // regex's
    NSError *error = NULL;
    
    NSRegularExpression *UNregex =
    [NSRegularExpression regularExpressionWithPattern:@"(^[a-zA-Z0-9])([a-zA-Z\\s0-9])*[a-zA-Z0-9]+$"
                                              options:0
                                                error:&error];
    
    NSUInteger numberOfMatchesUNPW = [UNregex numberOfMatchesInString:testString
                                                            options:0
                                                              range:NSMakeRange(0, [testString length])];
    
    if (textField.tag == 4) { // UN
        if ([testString length] < 4 || [testString length] >= 15 || numberOfMatchesUNPW == 0) {
            textField.errorMessage = @"Invalid";
        } else {
            textField.errorMessage = @"";
        }
    } else if (textField.tag == 5) { // PW
        if ([testString length] < 4|| [testString length] >= 15 || numberOfMatchesUNPW == 0) {
            textField.errorMessage = @"Invalid";
        } else {
            textField.errorMessage = @"";
        }
    }
    

    return true;
}

// Text Field Delegates -- scroll up when hometown is hit on a small phone!
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    SPAM(("%f", self.view.frame.size.height));
    
    // < 700.0 iphone SE/6,7,8 (not plus, X, or ipads)
    if (textField.tag == 6 && self.view.frame.size.height < 700.0) { // only do it for _homeTown TextField
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 200, 0.0);
        _scrollView.contentInset = contentInsets;
        _scrollView.scrollIndicatorInsets = contentInsets;
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        CGRect aRect = self.view.frame;
        aRect.size.height -= 200;
        
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            // ContentOffset  -- Scrolling to a specific top-left location (the contentOffset property).
            // contentView y = 0 is when screen is at top of scrollable area
            // contentView y = 80 moves the screen 80 points down the scrollable area
            [_scrollView setContentOffset: CGPointMake(0, 80.0)];
        } completion:nil];
        
    }
}

-(void)textFieldDidEndEditing:(UITextField*)textField {
    if (textField.tag == 6 && self.view.frame.size.height < 700.0) {
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            // Content insets allow you to scroll the screen PAST the scrollable area
            // So, you can add some extra space without changing the content size
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
            _scrollView.contentInset = contentInsets;
            _scrollView.scrollIndicatorInsets = contentInsets;
        } completion:^(BOOL finished) { }];
    }
}


/* Back to Login */
- (IBAction)voidAccount:(id)sender {
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
