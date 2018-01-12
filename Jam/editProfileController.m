//
//  editProfileController.m
//  RailJam
//
//  Created by Ben Ferraro on 7/12/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "editProfileController.h"
@implementation editProfileController

static NSString* const kAccountPictures = @"accountPictures";
static NSString* const kAccountVideos = @"accountVideos";

NSInteger const editPasswordTag = 1;
NSInteger const colorPickerTag = 100;

NSInteger const redTag = 101;
NSInteger const greenTag = 102;
NSInteger const blueTag = 103;

-(void)viewDidAppear:(BOOL)animated {
    /* Flash */
    [self performSelector:@selector(flashBar) withObject:nil afterDelay:0];
    [self performSelector:@selector(flashBar) withObject:nil afterDelay:2];
    [self performSelector:@selector(flashBar) withObject:nil afterDelay:4];
}

- (UIImage*)captureView:(UIView*)view {
    CGRect rect = [view bounds];
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

/* Flash bar */
-(void)flashBar {
    [_scrollView flashScrollIndicators];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    SPAM(("\nEditing Profile\n"));
    
    // For autoLogin toggle
    _toggleAutoLog = false;
    
    /* For chekcing if new prof pic / video is uploaded */
    _didUploadpic = false;
    _didUploadpVideo = false;
    
    /* For Dismissing keyboard */
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    
    
    /* Text view place holder */
    _bioField.delegate = self;
    if (self.editAccount.accountBio.length) {
        _bioField.text = self.editAccount.accountBio;
        _bioField.textColor = [UIColor blackColor];
    } else {
        _bioField.text = @"Enter any personal details here (intrests, available times, etc)\n\nEnter your social media IDs/handles here if you would like to contact another jammer";
        _bioField.textColor = [UIColor darkGrayColor];
    }
    _bioField.layer.borderWidth = 2.0;
    _bioField.layer.borderColor = [[UIColor blackColor] CGColor];
    _bioField.layer.cornerRadius = 3; // rounded edges
    _bioField.clipsToBounds = YES;
    
    
    /* Button Color/frame */
    
    // Buttons on right hand side that edit prof appearence
    _accountUploadPicture.layer.cornerRadius = 3; // rounded edges
    _accountUploadPicture.clipsToBounds = YES;
    [_accountUploadPicture setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _accountUploadPicture.layer.borderColor = [[UIColor blackColor] CGColor];
    _accountUploadPicture.layer.borderWidth = 2.0;
    
    _accountUploadVideo.layer.cornerRadius = 3; // rounded edges
    _accountUploadVideo.clipsToBounds = YES;
    [_accountUploadVideo setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _accountUploadVideo.layer.borderColor = [[UIColor blackColor] CGColor];
    _accountUploadVideo.layer.borderWidth = 2.0;

    _autoLogIn.layer.cornerRadius = 3; // rounded edges
    _autoLogIn.clipsToBounds = YES;
    [_autoLogIn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _autoLogIn.layer.borderColor = [[UIColor blackColor] CGColor];
    _autoLogIn.layer.borderWidth = 2.0;
    if ([_deleAcc.autoLogIn isEqualToString:@"Yes"]) {
        [_autoLogIn setTitle:@"Enabled" forState:UIControlStateNormal];
    } else {
        [_autoLogIn setTitle:@"Disabled" forState:UIControlStateNormal];
    }
    
    _profileBackGroundColor.layer.cornerRadius = 3; // rounded edges
    _profileBackGroundColor.clipsToBounds = YES;
    [_profileBackGroundColor setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _profileBackGroundColor.layer.borderColor = [[UIColor blackColor] CGColor];
    _profileBackGroundColor.layer.borderWidth = 2.0;
    
    _profileTextColor.layer.cornerRadius = 3; // rounded edges
    _profileTextColor.clipsToBounds = YES;
    _profileTextColor.titleLabel.numberOfLines = 2;
    [_profileTextColor setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _profileTextColor.layer.borderColor = [[UIColor blackColor] CGColor];
    _profileTextColor.layer.borderWidth = 2.0;
    
    /* Text Fields */
    _editEmail.selectedLineColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0]; // dank blue
    _editEmail.lineColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    _editEmail.selectedTitleColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    _editEmail.titleColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    _editEmail.textColor = [UIColor blackColor];
    _editEmail.placeholderColor = [UIColor darkGrayColor];
    _editEmail.clipsToBounds = YES;
    _editEmail.layer.cornerRadius = 3;
    _editEmail.textAlignment = NSTextAlignmentCenter;
    
    _editPassword.selectedLineColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0]; // dank blue
    _editPassword.lineColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    _editPassword.selectedTitleColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    _editPassword.titleColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    _editPassword.textColor = [UIColor blackColor];
    _editPassword.placeholderColor = [UIColor darkGrayColor];
    _editPassword.clipsToBounds = YES;
    _editPassword.layer.cornerRadius = 3;
    _editPassword.textAlignment = NSTextAlignmentCenter;
    
    _editReType.selectedLineColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0]; // dank blue
    _editReType.lineColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    _editReType.selectedTitleColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    _editReType.titleColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    _editReType.textColor = [UIColor blackColor];
    _editReType.placeholderColor = [UIColor darkGrayColor];
    _editReType.clipsToBounds = YES;
    _editReType.layer.cornerRadius = 3;
    _editReType.textAlignment = NSTextAlignmentCenter;
    
    
    /* Tags */
    _editPassword.tag = editPasswordTag;
    
    /* Text field delegates*/
    _editPassword.delegate = self;
    
    /* Blur Effect */
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    
    /* Blur View */
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = _editEmail.bounds;
    visualEffectView.backgroundColor = [UIColor clearColor];
    visualEffectView.alpha = 1.5;
    visualEffectView.clipsToBounds = true;
    visualEffectView.userInteractionEnabled = false;
    
    _editEmail.background = [self captureView:visualEffectView];
    _editPassword.background = [self captureView:visualEffectView];
    _editReType.background = [self captureView:visualEffectView];
    [_profileTextColor setBackgroundImage:[self captureView:visualEffectView] forState:UIControlStateNormal];
    [_profileBackGroundColor setBackgroundImage:[self captureView:visualEffectView] forState:UIControlStateNormal];
    [_accountUploadPicture setBackgroundImage:[self captureView:visualEffectView] forState:UIControlStateNormal];
    [_accountUploadVideo setBackgroundImage:[self captureView:visualEffectView] forState:UIControlStateNormal];
    [_autoLogIn setBackgroundImage:[self captureView:visualEffectView] forState:UIControlStateNormal];
    _bioField.backgroundColor = [UIColor colorWithPatternImage:[self captureView:visualEffectView]];
    
    _editEmail.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    _editPassword.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    _editReType.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    _profileTextColor.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    _profileBackGroundColor.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    _accountUploadPicture.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    _accountUploadVideo.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    _autoLogIn.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    
    /* Background Image */
    // Extend self.view.fram past the bounds of frame to account for perspective view
    CGRect newBackGroundFrame = CGRectMake(-20, -20, self.view.frame.size.width+35, self.view.frame.size.height+35);
    _backGroundPic = [[UIImageView alloc] initWithFrame:newBackGroundFrame];
    _backGroundPic.image = [UIImage imageNamed:@"editBackground.jpg"];
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
    
    
    /* Color Picker - Content View */
    _colorPickerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0,
                                                                0.0,
                                                                self.view.frame.size.width,
                                                                self.view.frame.size.height)];
    _colorPickerView.alpha = 0.0;
    _colorPickerView.tag = colorPickerTag;
    _colorPickerView.bounces = false;
    _colorPickerView.backgroundColor = [UIColor lightGrayColor];
    [_colorPickerView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    
    UIButton *cancelCreateJam = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-85.0,
                                                                           self.view.frame.size.height-50.0,
                                                                           75.0,
                                                                           30.0)];
    [cancelCreateJam setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelCreateJam.layer.cornerRadius = 10; // rounded edges
    cancelCreateJam.clipsToBounds = YES;
    [cancelCreateJam setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; // color and border
    cancelCreateJam.backgroundColor = [UIColor clearColor];
    cancelCreateJam.layer.borderColor = [[UIColor blackColor] CGColor];
    cancelCreateJam.layer.borderWidth = 2.0f;
    [cancelCreateJam addTarget:self action:@selector(cancelColor) forControlEvents:UIControlEventTouchDown];
    cancelCreateJam.titleLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    
    UIButton *chooseColor = [[UIButton alloc] initWithFrame:CGRectMake(10.0,
                                                                       self.view.frame.size.height-50.0,
                                                                       75.0,
                                                                       30.0)];
    [chooseColor setTitle:@"Choose" forState:UIControlStateNormal];
    chooseColor.layer.cornerRadius = 10; // rounded edges
    chooseColor.clipsToBounds = YES;
    [chooseColor setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; // color and border
    chooseColor.backgroundColor = [UIColor clearColor];
    chooseColor.layer.borderColor = [[UIColor blackColor] CGColor];
    chooseColor.layer.borderWidth = 2.0f;
    [chooseColor addTarget:self action:@selector(chooseColor) forControlEvents:UIControlEventTouchDown];
    chooseColor.titleLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    
    _red = [[SkyFloatingLabelTextField alloc]
                                      initWithFrame:CGRectMake(10.0,
                                                               self.view.frame.size.height-135.0,
                                                               60.0, 50.0)];
    _red.lineColor = [UIColor whiteColor];
    _red.title = @"Red";
    _red.text = @"255";
    _red.placeholderColor = [UIColor whiteColor];
    _red.placeholderFont = [UIFont fontWithName:@"ActionMan" size:20.0];
    _red.keyboardType = UIKeyboardTypeNumberPad;
    _red.tag = redTag;
    _red.delegate = self;
    
    _green = [[SkyFloatingLabelTextField alloc]
                                        initWithFrame:CGRectMake(self.view.frame.size.width/2-37.5,
                                                                 self.view.frame.size.height-135.0,
                                                                 75.0, 50.0)];
    _green.lineColor = [UIColor whiteColor];
    _green.text = @"255";
    _green.title = @"Green";
    _green.placeholderColor = [UIColor whiteColor];
    _green.placeholderFont = [UIFont fontWithName:@"ActionMan" size:20.0];
    _green.keyboardType = UIKeyboardTypeNumberPad;
    _green.tag = greenTag;
    _green.delegate = self;
    
    _blue = [[SkyFloatingLabelTextField alloc]
                                       initWithFrame:CGRectMake(self.view.frame.size.width-70.0,
                                                                self.view.frame.size.height-135.0,
                                                                60.0, 50.0)];
    _blue.lineColor = [UIColor whiteColor];
    _blue.text = @"255";
    _blue.title = @"Blue";
    _blue.placeholderColor = [UIColor whiteColor];
    _blue.placeholderFont = [UIFont fontWithName:@"ActionMan" size:20.0];
    _blue.keyboardType = UIKeyboardTypeNumberPad;
    _blue.tag = blueTag;
    _blue.delegate = self;
    
    _colorPreview = [[UIImageView alloc]
                                 initWithFrame:CGRectMake(10.0,
                                                          25.0,
                                                          self.view.frame.size.width-20.0,
                                                          self.view.frame.size.height/2)];
    
    _colorPreview.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    _colorPreview.layer.cornerRadius = 10; // rounded edges
    _colorPreview.clipsToBounds = YES;
    
    UILabel *numberMessage = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                                       self.view.frame.size.height/2+45.0,
                                                                       self.view.frame.size.width-20.0,
                                                                       40.0)];
    
    numberMessage.text = @"Number must be greater than 0 and less than 256";
    numberMessage.numberOfLines = 3;
    numberMessage.textAlignment = NSTextAlignmentCenter;
    numberMessage.font = [UIFont fontWithName:@"ActionMan" size:22.0];
    
    // Add views
    [_colorPickerView addSubview:cancelCreateJam];
    [_colorPickerView addSubview:chooseColor];
    [_colorPickerView addSubview:_red];
    [_colorPickerView addSubview:_green];
    [_colorPickerView addSubview:_blue];
    [_colorPickerView addSubview:_colorPreview];
    [_colorPickerView addSubview:numberMessage];
    
    // Start of no colors changed
    _didChangeTextColor = false;
    _didChangeBackGroundColor = false;
    
    // No video deleted yet
    _deletedVideoIDIndex = -1;
    
    // Nav Buttons
    _voidProfile = [[UIButton alloc] init];
    [_voidProfile setBackgroundImage:[UIImage imageNamed:@"backX"] forState:UIControlStateNormal];
    [_voidProfile addTarget:self
                     action:@selector(voidProfile:)
           forControlEvents:UIControlEventTouchUpInside];
    
    _saveProfile = [[UIButton alloc] init];
    [_saveProfile setTitle:@"Done" forState:UIControlStateNormal];
    [_saveProfile setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_saveProfile addTarget:self
                                    action:@selector(saveProfile:)
                          forControlEvents:UIControlEventTouchUpInside];
    
    // Show nav and set insets
    [NavigationView showNavView:@"Edit Profile" leftButton:_voidProfile rightButton:_saveProfile view:self.view];
    [_scrollView setContentInset:UIEdgeInsetsMake([self.view viewWithTag:navBarViewTag].frame.size.height, 0.0, 0.0, 0.0)];
    
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
    
    if (_changingColor) {
        double redD = [_red.text doubleValue];
        double greenD = [_green.text doubleValue];
        double blueD = [_blue.text doubleValue];
        
        if (redD > 255.0 || blueD > 255.0 || greenD > 255.0
            || redD < 0.0 || blueD < 0.0 || greenD < 0.0) {
            _colorPreview.backgroundColor = [UIColor whiteColor];
        } else {
            _colorPreview.backgroundColor = [UIColor colorWithRed:redD/255.0 green:greenD/255.0 blue:blueD/255.0 alpha:1.0];
        }
    }    
}

/** Button Actions **/
- (IBAction)changeLineColor:(id)sender {
    _textOrBGColor = false; // means Line Color
    _changingColor = true;
    
    _red.text = @"255";
    _blue.text = @"255";
    _green.text = @"255";
    _colorPreview.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    
    [self.view addSubview:_colorPickerView];
    [self.view bringSubviewToFront:_colorPickerView];
    
    [UIView transitionWithView:self.view
                      duration:0.3
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^ {
                        _colorPickerView.alpha = 1.0;
                    }
                    completion:nil];
}

- (IBAction)changeUserNameColor:(id)sender {
    _textOrBGColor = true; // means UN color
    _changingColor = true;

    _red.text = @"255";
    _blue.text = @"255";
    _green.text = @"255";
    _colorPreview.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    
    [self.view addSubview:_colorPickerView];
    [self.view bringSubviewToFront:_colorPickerView];
    
    [UIView transitionWithView:self.view
                      duration:0.3
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^ {
                        _colorPickerView.alpha = 1.0;
                    }
                    completion:nil];

}

-(void)cancelColor {
    _changingColor = false;

    [UIView transitionWithView:self.view
                      duration:0.3
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^ {
                        _colorPickerView.alpha = 0.0;
                    }
                    completion:^(BOOL fin) { [[self.view viewWithTag:colorPickerTag] removeFromSuperview]; } ];
}

-(void)chooseColor {
    
    _changingColor = false;
    
    double redD = [_red.text doubleValue];
    double greenD = [_green.text doubleValue];
    double blueD = [_blue.text doubleValue];
    
    if (redD > 255.0 || blueD > 255.0 || greenD > 255.0
        || redD < 0.0 || blueD < 0.0 || greenD < 0.0) {
        // Change nothing
    } else {
        if (_textOrBGColor) { // UN Color
            _didChangeTextColor = true;
        } else { // Line Color
            _didChangeBackGroundColor = true;
        }
        
        // Profile UN Color - Text Color
        if (_textOrBGColor) {
            
            _redTextColor = _red.text;
            _blueTextColor = _blue.text;
            _greenTextColor = _green.text;
            
            /* Change button to green */
            [_profileTextColor setTitleColor:[UIColor greenColor] forState:UIControlStateNormal]; // color and boarder
            _profileTextColor.layer.borderColor = [[UIColor greenColor] CGColor];
            
        } else { // Profile Line Color - BG Color
            
            _redBackGroundColor = _red.text;
            _blueBackGroundColor = _blue.text;
            _greenBackGroundColor = _green.text;
            
            /* Change button to green */
            [_profileBackGroundColor setTitleColor:[UIColor greenColor] forState:UIControlStateNormal]; // color and boarder
            _profileBackGroundColor.layer.borderColor = [[UIColor greenColor] CGColor];
        }
    
    }
    
    [UIView transitionWithView:self.view
                      duration:0.3
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^ {
                        _colorPickerView.alpha = 0.0;
                    }
                    completion:^(BOOL fin) { [[self.view viewWithTag:colorPickerTag] removeFromSuperview]; }];
}


/* Changing Account Pic */
- (IBAction)uploadAccountPicture:(id)sender {
    
    _vidOrPic = @"picture";
    
    /* Image/Video Picker */
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = true;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage,nil];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

/* Add Video */
- (IBAction)uploadFeatureVideo:(id)sender {
    
    _vidOrPic = @"video";
    
    /* Image/Video Picker */
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    videoPicker.delegate = self;
    videoPicker.allowsEditing = true;
    videoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    videoPicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,nil];
    videoPicker.title = @"Video";
    
    // ask which video to replace if to many videos
    if ([_editAccount.featureVideoIDs count] == 4) {
        
        // ASK WHICH INDEX TO REPLACE
        UIAlertController *alertControllerDeleteIndex = [UIAlertController
                                                           alertControllerWithTitle:@"Only 4 profile videos allowed! (For now)...Which number video should we erase."
                                                           message:nil
                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* one = [UIAlertAction actionWithTitle:@"1" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               // Check
                                                               if ([_editAccount.featureVideoIDs objectAtIndex:0] != nil) {
                                                                   _deletedVideoIDIndex = 0;
                                                               }
                                                               [self presentViewController:videoPicker animated:YES completion:nil];
                                                           }];
        
        UIAlertAction* two = [UIAlertAction actionWithTitle:@"2" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        // Check
                                                        if ([_editAccount.featureVideoIDs objectAtIndex:1] != nil) {
                                                            _deletedVideoIDIndex = 1;
                                                        }
                                                        [self presentViewController:videoPicker animated:YES completion:nil];
                                                    }];
        
        UIAlertAction* three = [UIAlertAction actionWithTitle:@"3" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          // Check
                                                          if ([_editAccount.featureVideoIDs objectAtIndex:2] != nil) {
                                                              _deletedVideoIDIndex = 2;
                                                          }
                                                          [self presentViewController:videoPicker animated:YES completion:nil];
                                                      }];
        
        UIAlertAction* four = [UIAlertAction actionWithTitle:@"4" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               // Check
                                                               if ([_editAccount.featureVideoIDs objectAtIndex:3] != nil) {
                                                                   _deletedVideoIDIndex = 3;
                                                               }
                                                               [self presentViewController:videoPicker animated:YES completion:nil];
                                                           }];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) { /* Do Nothing */}];
        
        [alertControllerDeleteIndex addAction:one];
        [alertControllerDeleteIndex addAction:two];
        [alertControllerDeleteIndex addAction:three];
        [alertControllerDeleteIndex addAction:four];
        [alertControllerDeleteIndex addAction:cancel];
        [self presentViewController:alertControllerDeleteIndex animated:NO completion:nil];
        
    } else { // just upload video
        [self presentViewController:videoPicker animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([_vidOrPic isEqualToString:@"picture"]) {

        /* Save Image in session object */
        self.editAccount.accountPicture = [info objectForKey:UIImagePickerControllerEditedImage];
        
        /* Pic loaded */
        _didUploadpic = true;
        
        /* Change button to green */
        [_accountUploadPicture setTitleColor:[UIColor greenColor] forState:UIControlStateNormal]; // color and boarder
        _accountUploadPicture.layer.borderColor = [[UIColor greenColor] CGColor];
    
    } else { // Videos
        NSURL *videoUrl = (NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
                              
        float videoSize = (float)videoData.length/1024.0f/1024.0f; // MB
        if (videoSize < allowedVideoSize) {
            _uploadedFeatureVideo = videoData;
            /* Pic loaded */
            _didUploadpVideo = true;
            
            /* Change button to green */
            [_accountUploadVideo setTitleColor:[UIColor greenColor] forState:UIControlStateNormal]; // color and boarder
            _accountUploadVideo.layer.borderColor = [[UIColor greenColor] CGColor];
        } else {
            [AlertView showAlertTab:@"Video can not be greater than 70 MB" view:self.view];
        }
    }
}

- (IBAction)autoLogIn:(id)sender {
    if ([_autoLogIn.titleLabel.text isEqualToString:@"Disabled"]) {
        [_autoLogIn setTitle:@"Enabled" forState:UIControlStateNormal];
    } else {
        [_autoLogIn setTitle:@"Disabled" forState:UIControlStateNormal];
    }
    _toggleAutoLog = true;
}


/* Update Accounts user info */
- (IBAction)saveProfile:(id)sender {
    
    /* Gets the account picture an ID, then saves the Bio and PicID to the DB */
    if (([self.bioField.text isEqualToString:@"Enter any personal details here (intrests, available times, etc)\n\nEnter your social media IDs/handles here if you would like to contact another jammer"] ||
        [self.bioField.text isEqualToString:_editAccount.accountBio]) && _didUploadpic == false && !_editEmail.text.length
            && !_editPassword.text.length && !_editReType.text.length && _didChangeBackGroundColor == false && _didChangeTextColor == false && _didUploadpVideo == false && _toggleAutoLog == false) {
        
        // Change back screen to normal to avoid funky aniamtion due to perspective view
        _backGroundPic.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width+35, self.view.frame.size.height+35);
        
        // Go back to main Screen
        id<EditProfileDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(endEdit:)]) {
            [strongDelegate endEdit:@"0"];
        }
    } else {
        if ([_editPassword.text isEqualToString:_editReType.text] && !_editPassword.hasErrorMessage) {
        
            /* Update account fields */
            [self updateAccountInfo];
            
            // Change back screen to normal to avoid funky aniamtion due to perspective view
            _backGroundPic.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width+35, self.view.frame.size.height+35);
            // Go back to main Screen
            id<EditProfileDelegate> strongDelegate = self.delegate;
            if ([strongDelegate respondsToSelector:@selector(endEdit:)]) {
                [strongDelegate endEdit:@"1"];
            }
        } else {
            [AlertView showAlertTab:@"password not matching or invalid" view:self.view];
        }
    }
}

-(void)updateAccountInfo {
    /* Update account fields */
    if (_toggleAutoLog) {
        if ([_autoLogIn.titleLabel.text isEqualToString:@"Disabled"]) {
            _deleAcc.autoLogIn = @"No";
        } else {
            _deleAcc.autoLogIn = @"Yes";
        }
        /* Save default account to NSUserDefaults */
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:_deleAcc]; // calls Account.m encodeWithCoder
        [defaults setObject:encodedObject forKey:@"defaultAccount"];
    }
    
    // Email
    if (_editEmail.text.length) {
        _editAccount.email = _editEmail.text;
    } else {
        // do nothing
    }
    
    // PW
    if (_editPassword.text.length) {
        /* Encrypt password */
        NSString *encryptedPW = [Constants encryptPW:_editPassword.text];
        _editAccount.password = encryptedPW;
    } else {
        // do nothing
    }
    
    // Bio
    if ([self.bioField.text isEqualToString:@"Enter any personal details here (intrests, available times, etc)\n\nEnter your social media IDs/handles here if you would like to contact another jammer"]) {
        // do nothing
    } else {
        self.editAccount.accountBio = self.bioField.text;
    }
    
    // Text Color
    if (_didChangeTextColor) {
        [_editAccount.profileUNColor replaceObjectAtIndex:0 withObject:_redTextColor];
        [_editAccount.profileUNColor replaceObjectAtIndex:1 withObject:_greenTextColor];
        [_editAccount.profileUNColor replaceObjectAtIndex:2 withObject:_blueTextColor];
    }
    
    // Details (BG color)
    if (_didChangeBackGroundColor) {
        [_editAccount.profileLineColor replaceObjectAtIndex:0 withObject:_redBackGroundColor];
        [_editAccount.profileLineColor replaceObjectAtIndex:1 withObject:_greenBackGroundColor];
        [_editAccount.profileLineColor replaceObjectAtIndex:2 withObject:_blueBackGroundColor];
    }
    
    
    /* Check if uploaded pic or video, if not just update account fields */
    if (_didUploadpic) {
        [self saveNewLocationImageFirst]; // this function will upload video also and update account
    }  else if (_didUploadpVideo) {
        [self saveNewLocationVideoFirst];
    } else {
        /* Just Update account */
        [self.editAccount updateAccount:kBaseURL message:_editAccount._accountid];
    }
}

/* Go back to main view */
-(IBAction)voidProfile:(id)sender {
    // Change back screen to normal to avoid funky aniamtion due to perspective view
    _backGroundPic.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width+35, self.view.frame.size.height+35);
    [self dismissViewControllerAnimated:YES completion:nil];
}

/* Text Field Delegate method for SkyFloatingtextField Error */
-(BOOL)textField:(SkyFloatingLabelTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSMutableString *testString = [NSMutableString stringWithString:textField.text];
    [testString replaceCharactersInRange:range withString:string];
    
    // regex check
    NSError *error = NULL;
    NSRegularExpression *PWregex =
    [NSRegularExpression regularExpressionWithPattern:@"(^[a-zA-Z0-9])([a-zA-Z\\s0-9])*[a-zA-Z0-9]+$"
                                              options:0
                                                error:&error];
    
    NSUInteger numberOfMatchesPW = [PWregex numberOfMatchesInString:testString
                                                            options:0
                                                              range:NSMakeRange(0, [testString length])];
    if (textField.tag == editPasswordTag) { // PW Check
        if ([testString length] < 4 || numberOfMatchesPW == 0) {
            textField.errorMessage = @"Invalid";
        } else {
            textField.errorMessage = @"";
        }
        
    }
    
    return true;
}

// Text Field Delegates
// Text Field Delegates -- scroll up when hometown is hit on a small phone!
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    SPAM(("%f", self.view.frame.size.height));
    
    // < 700.0 iphone SE/6,7,8 (not plus, X, or ipads)
    if ((textField.tag == redTag || textField.tag == greenTag || textField.tag == blueTag)
        && self.view.frame.size.height < 700.0) { // only do it for _homeTown TextField
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 200, 0.0);
        _colorPickerView.contentInset = contentInsets;
        _colorPickerView.scrollIndicatorInsets = contentInsets;
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        CGRect aRect = self.view.frame;
        aRect.size.height -= 200;
        
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            // ContentOffset  -- Scrolling to a specific top-left location (the contentOffset property).
            // contentView y = 0 is when screen is at top of scrollable area
            // contentView y = 80 moves the screen 80 points down the scrollable area
            
            [_colorPickerView setContentOffset: CGPointMake(0, 145.0)];
        } completion:nil];
        
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if ((textField.tag == redTag || textField.tag == greenTag || textField.tag == blueTag)
        && self.view.frame.size.height < 700.0) {
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            // Content insets allow you to scroll the screen PAST the scrollable area
            // So, you can add some extra space without changing the content size
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
            _colorPickerView.contentInset = contentInsets;
            _colorPickerView.scrollIndicatorInsets = contentInsets;
        } completion:^(BOOL finished) { }];
    }
}

/* Text View Delegates */
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Enter any personal details here (intrests, available times, etc)\n\nEnter your social media IDs/handles here if you would like to contact another jammer"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 200, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= 200;
    [_scrollView scrollRectToVisible:_bioField.frame animated:YES];

}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Enter any personal details here (intrests, available times, etc)\n\nEnter your social media IDs/handles here if you would like to contact another jammer";
        textView.textColor = [UIColor darkGrayColor];
    }
    [textView resignFirstResponder];
    
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(65.0, 0.0, 0.0, 0.0);
        _scrollView.contentInset = contentInsets;
        _scrollView.scrollIndicatorInsets = contentInsets;
    } completion:^(BOOL finished) {
        
    }];
}

/** DB Methods **/
/* Saves profile picture, also updates account */
-(void)saveNewLocationImageFirst {
    SPAM(("saveNewLocationImageFirst -- Edit profile\n"));

    NSData* bytesRail = UIImageJPEGRepresentation(self.editAccount.accountPicture, 0.8);
    
    [ImageVideoUploader getImageIDDB:kBaseURL collection:kAccountPictures objData:bytesRail VideoOrImg:@"image" message:_editAccount._accountid callback:^(NSError *error, BOOL success, NSDictionary *responseDic) {
        
        if (success && responseDic != nil) {
            SPAM(("Account Pic ID Retrived\n"));
        
            /* Delete init pro pic from DB, which also deletes local file on computer */
            if (_editAccount.accountPictureID.length) {
                [DataBaseCalls deleteFromCollection:kAccountPictures entity:_editAccount.accountPictureID message:_editAccount._accountid];
            }
            
            _editAccount.accountPictureID = responseDic[@"_id"]; // set account picture ID for account
            
            /* If Uploaded video, the upload video will take care of updating account */
            if (_didUploadpVideo) {
                [self saveNewLocationVideoFirst]; // updates account
            } else {
                /* Update account */
                [self.editAccount updateAccount:kBaseURL message:_editAccount._accountid];
            }
            
        } else {
            /* Loading alert box */
            [AlertView showAlertControllerOkayOption:@"Trouble saving profile picture" message:@"Please try again" view:self];
        }
    }];
}

/* Saves Video, also updates account */
-(void)saveNewLocationVideoFirst {
    SPAM(("saveNewLocationVideoFirst -- Edit profile\n"));
    
    NSData* bytesVideo = _uploadedFeatureVideo; // NSData element for the video
    
    [ImageVideoUploader getImageIDDB:kBaseURL collection:kAccountVideos objData:bytesVideo VideoOrImg:@"video" message:_editAccount._accountid callback:^(NSError *error, BOOL success, NSDictionary *responseDic) {
        
        if (error == nil && responseDic != nil) {
            SPAM(("Account Video ID Retrived\n"));
            
            // Check if we need to remove a video
            [self deleteExtraProfileVideo];
            
            [_editAccount.featureVideoIDs addObject:responseDic[@"_id"]]; //6
            
            /* Update account */
            [self.editAccount updateAccount:kBaseURL message:_editAccount._accountid];
            
        } else {
            NSLog(@"ERROR: %@\n", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                /* Loading alert box */
                [AlertView showAlertControllerOkayOption:@"Trouble saving profile feature video" message:@"Please try again" view:self];
            });
        }
    }]; // end getID
}

-(void)deleteExtraProfileVideo {
    if (_deletedVideoIDIndex != -1) {
        // update DB
        [DataBaseCalls deleteFromCollection:kAccountVideos entity:[_editAccount.featureVideoIDs objectAtIndex:_deletedVideoIDIndex] message:_editAccount._accountid];
        // update local object for later update
        [_editAccount.featureVideoIDs removeObjectAtIndex:_deletedVideoIDIndex];
        [_editAccount.featureVideos removeAllObjects]; // clear the array so it reloads videos for user
    }
}

/* Button Selection Code */
-(IBAction)buttonNormal:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.titleLabel.textColor = [UIColor whiteColor];
    button.backgroundColor = [UIColor clearColor];
}

-(IBAction)buttonDown:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.titleLabel.textColor = [UIColor whiteColor];
    button.backgroundColor = [UIColor blackColor];
}


@end
