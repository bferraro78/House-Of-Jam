//
//  SeshLeisureController.m
//  RailJam
//
//  Created by Ben Ferraro on 7/12/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SeshLeisureController.h"

@implementation SeshLeisureController

-(void)viewDidAppear:(BOOL)animated {
    /* Flash */
    [self performSelector:@selector(flashBar) withObject:nil afterDelay:0];
    [self performSelector:@selector(flashBar) withObject:nil afterDelay:2];
    [self performSelector:@selector(flashBar) withObject:nil afterDelay:4];
}

/* Flash bar */
-(void)flashBar {
    [_scrollView flashScrollIndicators];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    SPAM(("Sesh Leisure Controller\n"));
    
    [self setViewGestures];
    [self setBackgroundImage];
    
    /* Perspective View */
    [self setUpPerspectiveView];
    
    /* Check if editing or creating from fresh */
    if (_seshController == nil) {
        /* Initianlize session object / arrays */
        _seshController = [[Session alloc] init];
        _seshController.LeisureorComp = @"leisure";
        _seshController.privateJam = @"public";
        _seshController.sessionPictures = [[NSMutableArray alloc] init];
        _seshController.sessionPictureIDs = [[NSMutableArray alloc] init];
        _seshController.invitedFriends = [[NSMutableArray alloc] init];
    } else { // This is an editing jam, not created from scratch
        _editingJam = true;
    }
    
    /* Date Picker */
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 250)];
    _datePicker.layer.cornerRadius = 10; // rounded edges
    _datePicker.clipsToBounds = YES;
    _datePicker.tag = datePickerViewTag;
    _datePicker.datePickerMode = UIDatePickerModeDate;
    _datePicker.backgroundColor = [UIColor whiteColor];
    [_datePicker setMinimumDate: [NSDate date]];
    if (_editingJam) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        _datePicker.date = [dateFormatter dateFromString:_seshController.jamDate];
    } else {
        _datePicker.date = [NSDate date];
    }
    
    /* Picker Data */
    if (!_editingJam) {
        _pickerData = @[@"Jam Type", @"Basketball", @"Biking", @"Cricket", @"Fishing", @"Golf", @"Hiking", @"Lacrosse", @"Motorcycle Ride", @"Roller Blading", @"Rock Climbing", @"Running", @"Rugby", @"Soccer", @"Skate", @"Ski/Snowboard", @"Surf", @"Yoga", @"Tennis", @"XC Ski", @"Hang Out", @"Other Event/Activity"];
    } else {
        _pickerData = @[_seshController.jamType];
    }
    _jamType.delegate = self;
    _jamType.dataSource = self;
    _jamType.layer.cornerRadius = 3; // rounded edges
    _jamType.clipsToBounds = YES;
    _jamType.layer.borderColor = [[UIColor blueColor] CGColor];
    _jamType.layer.borderWidth = 1.5;
    
    /* Button Color/frame */
    _createRailJam.layer.cornerRadius = 10; // rounded edges
    _createRailJam.clipsToBounds = YES;
    [_createRailJam setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; // color and boarder
    _createRailJam.backgroundColor = [UIColor blackColor];
    _createRailJam.layer.borderColor = [[UIColor blueColor] CGColor];
    _createRailJam.layer.borderWidth = 2.0;
    
    _inviteFriends.layer.cornerRadius = 3; // rounded edges
    _inviteFriends.clipsToBounds = YES;
    [_inviteFriends setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _inviteFriends.layer.borderColor = [[UIColor blueColor] CGColor];
    _inviteFriends.layer.borderWidth = 1.5;
    _inviteFriends.titleLabel.numberOfLines = 2;
    
    _privateGame.layer.cornerRadius = 3; // rounded edges
    _privateGame.clipsToBounds = YES;
    [_privateGame setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _privateGame.layer.borderColor = [[UIColor blueColor] CGColor];
    _privateGame.layer.borderWidth = 1.5;
    _privateGame.titleLabel.numberOfLines = 2;
    
    [_locPicUpload setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; // color and boarder
    _locPicUpload.layer.borderColor = [[UIColor blueColor] CGColor];
    _locPicUpload.layer.borderWidth = 1.5;
    _locPicUpload.layer.cornerRadius = 3; // rounded edges
    _locPicUpload.clipsToBounds = YES;

    _changeDate.layer.cornerRadius = 3; // rounded edges
    _changeDate.clipsToBounds = YES;
    [_changeDate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; // color and boarder
    _changeDate.layer.borderColor = [[UIColor blueColor] CGColor];
    _changeDate.layer.borderWidth = 1.5;
    
    /* Setting Font / background color */
    _jamName.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    _startTime.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    _jamTypeText.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    _sessionDescription.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    
    /* Blur Effect Box */
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    
    /* Set up box views */
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = _jamName.bounds;
    visualEffectView.backgroundColor = [UIColor clearColor];
    visualEffectView.alpha = 1.0;
    visualEffectView.clipsToBounds = true;
    
    _jamName.background = [self captureView:visualEffectView];
    _startTime.background = [self captureView:visualEffectView];
    _jamTypeText.background = [self captureView:visualEffectView];
    [_changeDate setBackgroundImage:[self captureView:visualEffectView] forState:UIControlStateNormal];
    [_inviteFriends setBackgroundImage:[self captureView:visualEffectView] forState:UIControlStateNormal];
    [_privateGame setBackgroundImage:[self captureView:visualEffectView] forState:UIControlStateNormal];
    [_locPicUpload setBackgroundImage:[self captureView:visualEffectView] forState:UIControlStateNormal];
    _sessionDescription.backgroundColor = [UIColor colorWithPatternImage:[self captureView:visualEffectView]];
    _jamType.backgroundColor = [UIColor colorWithPatternImage:[self captureView:visualEffectView]];
    
    _changeDate.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.6];
    _inviteFriends.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.6];
    _privateGame.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.6];
    _locPicUpload.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.6];
    
    /* Text view place holder for Session Description Text View */
    _sessionDescription.delegate = self;
    _sessionDescription.text = @"Enter any extra details about location, activity, etc here...";
    _sessionDescription.textColor = [UIColor darkGrayColor];
    _sessionDescription.layer.borderWidth = 1.5;
    _sessionDescription.layer.cornerRadius = 3; // rounded edges
    _sessionDescription.clipsToBounds = YES;
    _sessionDescription.layer.borderColor = [[UIColor blueColor] CGColor];
    
    // Text fields
    _jamName.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.6];
    _jamName.clipsToBounds = YES;
    _jamName.layer.cornerRadius = 3;
    _jamName.layer.borderColor = [[UIColor blueColor] CGColor];
    _jamName.layer.borderWidth = 0.5;
    _jamName.textAlignment = NSTextAlignmentCenter;
    _jamName.titleLabel.textAlignment = NSTextAlignmentCenter;
    _jamName.delegate = self;
    
    _startTime.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.6];
    _startTime.clipsToBounds = YES;
    _startTime.layer.cornerRadius = 3;
    _startTime.layer.borderColor = [[UIColor blueColor] CGColor];
    _startTime.layer.borderWidth = 0.5;
    _startTime.textAlignment = NSTextAlignmentCenter;
    _startTime.titleLabel.textAlignment = NSTextAlignmentCenter;
    _startTime.delegate = self;
    
    _jamTypeText.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.6];
    _jamTypeText.clipsToBounds = YES;
    _jamTypeText.layer.cornerRadius = 3;
    _jamTypeText.layer.borderColor = [[UIColor blueColor] CGColor];
    _jamTypeText.layer.borderWidth = 0.5;
    _jamTypeText.textAlignment = NSTextAlignmentCenter;
    _jamTypeText.titleLabel.textAlignment = NSTextAlignmentCenter;
    _jamTypeText.delegate = self;
    
    // Fill in details for fields if editing jam
    if (_editingJam) 
        [self fillInTextField];
    
    // Navigation view
    [self setUpNavBar];
}

-(UIImage*)captureView:(UIView*)view {
    CGRect rect = [view bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

/* Background images */
-(void)setBackgroundImage {
    // Extend self.view.fram past the bounds of frame to account for perspective view
    CGRect newBackGroundFrame = CGRectMake(-20, -20, self.view.frame.size.width+35, self.view.frame.size.height+35);
    _backGroundPic = [[UIImageView alloc] initWithFrame:newBackGroundFrame];
    _backGroundPic.image = [UIImage imageNamed:@"leisureBack.jpg"];
    _backGroundPic.alpha = 0.8;
    [self.view addSubview:_backGroundPic];
    [self.view sendSubviewToBack:_backGroundPic];
}

/** View Gestures **/
-(void)setViewGestures {
    /* For Dismissing keyboard -- touch the screen */
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
}
/* Touching the "Change date" or "Done button calls this method */
-(void)dismissKeyboard {
    [self.view endEditing:YES];
    [self dismissDatePicker];
}
-(void)dismissDatePicker {
    if ([self.view viewWithTag:datePickerViewTag] != nil) { // date picker cancel
        [UIView transitionWithView:self.view
                          duration:0.2
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^ {
                            _datePicker.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 250);
                        }
                        completion: ^(BOOL finished){ [[self.view viewWithTag:datePickerViewTag] removeFromSuperview];
                            [_changeDate setTitle:@"Change Date" forState:UIControlStateNormal]; // change back from "Done"
                        }];
    }
}

// Text Field Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)setUpPerspectiveView {
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

/** Editing Features **/
-(void)fillInTextField {
    [_privateGame setTitle:_seshController.privateJam forState:UIControlStateNormal];
    _sessionDescription.text = _seshController.seshDescription;
    _sessionDescription.textColor = [UIColor blackColor];
    _jamName.text = _seshController.jamName;
    _startTime.text = _seshController.startTime;
    _jamTypeText.text = [_pickerData firstObject]; // there is only one element in _pickerData if editing jam
    _jamTypeText.hidden = true;
    [self setUpEditingProperties];
}

-(void)setUpEditingProperties {
    _extraPicturesArr = [[NSMutableArray alloc] init];
    _extraFriendsArr = [[NSMutableArray alloc] init];
    [_createRailJam setTitle:@"Finish Editing" forState:UIControlStateNormal];
}

/** Nav Bar **/
-(void)setUpNavBar {
    NSString *jamFormString = [self navBarButtonTitle];
    [NavigationView showNavView:jamFormString leftButton:_voidJam rightButton:_changeDate view:self.view];
    [_scrollView setContentInset:UIEdgeInsetsMake([self.view viewWithTag:navBarViewTag].frame.size.height, 0.0, 0.0, 0.0)];
}

-(NSString*)navBarButtonTitle {
    _voidJam = [[UIButton alloc] init];
    [_voidJam setBackgroundImage:[UIImage imageNamed:@"backX"] forState:UIControlStateNormal];
    [_voidJam addTarget:self
                 action:@selector(backToMainView:)
       forControlEvents:UIControlEventTouchUpInside];
    
    _changeDate = [[UIButton alloc] init];
    [_changeDate setTitle:@"Change Date" forState:UIControlStateNormal];
    [_changeDate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _changeDate.titleLabel.numberOfLines = 2;
    [_changeDate addTarget:self
                    action:@selector(datePickerBtnAction:)
          forControlEvents:UIControlEventTouchUpInside];
    
    NSString *jamFormString;
    if (_editingJam) {
        jamFormString = @"Edit Jam Form";
    } else {
        jamFormString = @"Jam Form";
    }
    
    return jamFormString;
}

/** Jam Image **/
- (IBAction)uploadLocation:(id)sender {
    /* Image/Video Picker */
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 7;
    imagePickerController.showsNumberOfSelectedAssets = YES;
    imagePickerController.mediaType = QBImagePickerMediaTypeImage;
    imagePickerController.assetCollectionSubtypes = @[
                                                      @(PHAssetCollectionSubtypeSmartAlbumUserLibrary), // Camera Roll
                                                      @(PHAssetCollectionSubtypeAlbumMyPhotoStream), // My Photo Stream
                                                      @(PHAssetCollectionSubtypeSmartAlbumPanoramas), // Panoramas
                                                      @(PHAssetCollectionSubtypeSmartAlbumBursts), // Bursts
                                                      @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
                                                      @(PHAssetCollectionSubtypeAlbumImported)
                                                      ];
    
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
    
    self.requestOptions = [[PHImageRequestOptions alloc] init];
    self.requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    self.requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    self.requestOptions.synchronous = true;
    
    PHImageManager *manager = [PHImageManager defaultManager];
    
    for (PHAsset *asset in assets) {
        [manager requestImageForAsset:asset
                           targetSize:PHImageManagerMaximumSize
                          contentMode:PHImageContentModeDefault
                              options:self.requestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                            [self setUpJamPicture:image];
                        }];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)setUpJamPicture:(UIImage*)image {
    /* Save Image in session object */
    (_editingJam) ? [_extraPicturesArr addObject:image] : [self.seshController.sessionPictures addObject:image];
    /* Change button to green */
    [_locPicUpload setTitleColor:[UIColor greenColor] forState:UIControlStateNormal]; // color and boarder
    _locPicUpload.layer.borderColor = [[UIColor greenColor] CGColor];
}

-(void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/** Creating Leisure Jam **/
- (IBAction)createLeisure:(id)sender {
    // Check if it is a private jam, if so must have at least one invite friend
    [self checkIfPrivateAndInvitedFrined];
}

-(void)checkIfPrivateAndInvitedFrined {
    if ([_privateGame.titleLabel.text isEqualToString:@"private"] && [_seshController.invitedFriends count] < 1
            && [_extraFriendsArr count] < 1) {
        [AlertView showAlertTab:@"Must invite at least one friend if hosting a private jam" view:self.view];
    } else {
        [self checkIfValidLeisureJam];
    }
}

-(void)checkIfValidLeisureJam {
    if (!([self.startTime.text isEqualToString:@""]) && !([self.jamTypeText.text isEqualToString:@""])
        && !([self.jamName.text isEqualToString:@""]) && !([self.jamTypeText.text isEqualToString:@"Jam Type"])) {
        [self backToMainView:self];
        [self setUpSessionObjectWithInfo];
    } else {
         [AlertView showAlertTab:@"Must have a jam name, start time, and jam type!" view:self.view];
    }
}

/* SAVE DATA ABOUT RAIL JAM SESH IN Session object */
-(void)setUpSessionObjectWithInfo {
    /* Get from UITextFields */
    self.seshController.jamName= self.jamName.text;
    self.seshController.startTime = self.startTime.text;
    self.seshController.sessionHostName = self.mainAccountUsername;
    self.seshController.jamType = _jamTypeText.text;
    self.seshController.entryFee = @""; // not available for leisure Jam...
    
    if ([self.sessionDescription.text isEqualToString:@"Enter any extra details about location, activity, etc here..."]) {
        self.seshController.seshDescription = @"";
    } else {
        self.seshController.seshDescription = self.sessionDescription.text;
    }
    
    // set new date selected
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    NSString *strDate = [formatter stringFromDate:_datePicker.date];
    self.seshController.jamDate = strDate; // If date has changed by user
    
    // Finish Up Call correct delegate
    (_editingJam) ? [self finishEditingDelegate] : [self placeMarkerDelegate];
    
}

-(void)finishEditingDelegate {
    id<SeshLeisureDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(finishEditingJam:editSession:extraPicturesArr:extraFriendsArr:)]) {
        [strongDelegate finishEditingJam:_mainLocalSession editSession:self.seshController extraPicturesArr:self.extraPicturesArr extraFriendsArr:_extraFriendsArr];
    }
}

-(void)placeMarkerDelegate {
    id<SeshLeisureDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(placeMarker:)]) {
        [strongDelegate placeMarker:self.seshController];
    }
}

/** Picker View **/
// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _pickerData.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        tView.font = [UIFont fontWithName:@"ActionMan" size:17.0];
        tView.text = _pickerData[row];
        tView.textAlignment = NSTextAlignmentCenter;
        _jamTypeText.text = _pickerData[row];
        
    }
    // Fill the label text here
    return tView;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _jamTypeText.text = _pickerData[row];
}

/** Date Picker **/
-(IBAction)datePickerBtnAction:(id)sender {
    if ([_changeDate.titleLabel.text isEqualToString:@"Done"]) {

    } else { // normal action - show date picker
        [self.view addSubview:_datePicker];
        [self.view bringSubviewToFront:_datePicker];
        
        [_changeDate setTitle:@"Done" forState:UIControlStateNormal]; // Give the user an option to be "Done" with changing date
        
        [UIView transitionWithView:self.view
                          duration:0.2
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^ {
                            _datePicker.frame = CGRectMake(0, self.view.frame.size.height-250.0, self.view.frame.size.width, 250.0);
                        }
                        completion:nil];
    }
}

/* Go to invite friend view */
-(IBAction)inviteFriends:(id)sender {
    [self performSegueWithIdentifier:@"inviteFriendSegue" sender:self];
}

/* Change between public and private jam */
- (IBAction)privateJam:(id)sender {
    if ([_privateGame.titleLabel.text isEqualToString:@"public"]) {
        [_privateGame setTitle:@"private" forState:UIControlStateNormal];
        _seshController.privateJam = @"private";
    } else {
        [_privateGame setTitle:@"public" forState:UIControlStateNormal];
        _seshController.privateJam = @"public";
    }
}

// Delegate
-(void)endInviteFriends {
    /* Change button to green */
    [_inviteFriends setTitleColor:[UIColor greenColor] forState:UIControlStateNormal]; // color and boarder
    _inviteFriends.layer.borderColor = [[UIColor greenColor] CGColor];
}

-(IBAction)backToMainView:(id)sender {
    // CALL BACK, NO JAM
    _backGroundPic.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width+35, self.view.frame.size.height+35);
    [self dismissViewControllerAnimated:YES completion:nil];
}


/* Text View Delegates */
- (void)textViewDidBeginEditing:(UITextView *)textView {
    SPAM(("begin edit\n"));
    
    if ([textView.text isEqualToString:@"Enter any extra details about location, activity, etc here..."]) {
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
    [_scrollView scrollRectToVisible:_sessionDescription.frame animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Enter any extra details about location, activity, etc here...";
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

/* SEGUE CODE */
// Pass in info to next page
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"inviteFriendSegue"]) {
        InviteFriendsController *ic = [segue destinationViewController];
        ic.addFriendsSession = _seshController;
        ic.accountsFriendList = _mainAccountFriendList;
        ic.editingJam = _editingJam;
        ic.extraFriendsArr = _extraFriendsArr;
        ic.delegate = self;
    }
}

@end
