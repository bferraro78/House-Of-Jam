//
//  SeshController.m
//  RailJam
//
//  Created by Ben Ferraro on 6/23/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SeshController.h"

@interface SeshController ()

@end


@implementation SeshController

NSInteger const explainViewTag = 123;

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    return 8; // Line spacing of 19 is roughly equivalent to 5 here.
}

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
    SPAM(("Sesh Controller\n"));
    
    [self setViewGestures];
    [self setBackgroundImage];
    
    /* Perspective View */
    [self setUpPerspectiveView];
    
    /* No Pictures loaded yet */
    _railPicture = false;
    _prizePicture = false;
    
    /* Check if editing or creating from fresh */
    if (_seshController == nil) {
        /* Initianlize session object / arrays */
        _seshController = [[Session alloc] init];
        _seshController.LeisureorComp = @"comp";
        _seshController.privateJam = @"public";
        _seshController.sessionPictures = [[NSMutableArray alloc] init];
        _seshController.sessionPictureIDs = [[NSMutableArray alloc] init];
        _seshController.invitedFriends = [[NSMutableArray alloc] init];
    } else {
        _editingJam = true; // this is an editing jam, not created from scratch
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
    
    if (_editingJam == false) {
        _pickerData = @[@"S-K-A-T-E", @"Best Trick", @"Best Line", @"Custom Game"];
    } else {
        _pickerData = @[_seshController.jamType];
    }
    _jamType.delegate = self;
    _jamType.dataSource = self;
    _jamType.layer.cornerRadius = 3; // rounded edges
    _jamType.clipsToBounds = YES;
    _jamType.layer.borderColor = [[UIColor redColor] CGColor];
    _jamType.layer.borderWidth = 1.5;
    
    /* Button Color/frame */
    _createRailJam.layer.cornerRadius = 10; // rounded edges
    _createRailJam.clipsToBounds = YES;
    [_createRailJam setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; // color and boarder
    _createRailJam.backgroundColor = [UIColor blackColor];
    _createRailJam.layer.borderColor = [[UIColor redColor] CGColor];
    _createRailJam.layer.borderWidth = 2.0;
    
    _inviteFriends.layer.cornerRadius = 3; // rounded edges
    _inviteFriends.clipsToBounds = YES;
    [_inviteFriends setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; // color and boarder
    _inviteFriends.layer.borderColor = [[UIColor redColor] CGColor];
    _inviteFriends.titleLabel.numberOfLines = 2;
    _inviteFriends.layer.borderWidth = 1.5;
    
    _privateGame.layer.cornerRadius = 3; // rounded edges
    _privateGame.clipsToBounds = YES;
    [_privateGame setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; // color and boarder
    _privateGame.layer.borderColor = [[UIColor redColor] CGColor];
    _privateGame.titleLabel.numberOfLines = 2;
    _privateGame.layer.borderWidth = 1.5;
    
    [_railUpload setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; // color and boarder
    _railUpload.layer.borderColor = [[UIColor redColor] CGColor];
    _railUpload.layer.borderWidth = 1.5;
    _railUpload.layer.cornerRadius = 3; // rounded edges
    _railUpload.clipsToBounds = YES;
    
    [_prizeUpload setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; // color and boarder
    _prizeUpload.layer.borderColor = [[UIColor redColor] CGColor];
    _prizeUpload.layer.borderWidth = 1.5;
    _prizeUpload.layer.cornerRadius = 3; // rounded edges
    _prizeUpload.clipsToBounds = YES;
    
    _explanationLabel.layer.cornerRadius = 10; // rounded edges
    _explanationLabel.clipsToBounds = YES;
    _explanationLabel.layer.borderColor = [[UIColor redColor] CGColor];
    _explanationLabel.layer.borderWidth = 1.0;
    _explanationLabel.userInteractionEnabled = true;

    /* Blur Effect Box */
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    
    /* Set up box views */
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = _sessionDescription.bounds;
    visualEffectView.backgroundColor = [UIColor clearColor];
    visualEffectView.alpha = 1.0;
    visualEffectView.clipsToBounds = true;
    
    _jamName.background = [self captureView:visualEffectView];
    _startTime.background = [self captureView:visualEffectView];
    _entryFee.background = [self captureView:visualEffectView];
    [_inviteFriends setBackgroundImage:[self captureView:visualEffectView] forState:UIControlStateNormal];
    [_privateGame setBackgroundImage:[self captureView:visualEffectView] forState:UIControlStateNormal];
    [_railUpload setBackgroundImage:[self captureView:visualEffectView] forState:UIControlStateNormal];
    [_prizeUpload setBackgroundImage:[self captureView:visualEffectView] forState:UIControlStateNormal];
    [_explanationLabel setBackgroundColor:[UIColor colorWithPatternImage:[self captureView:visualEffectView]]];
    [_sessionDescription setBackgroundColor:[UIColor colorWithPatternImage:[self captureView:visualEffectView]]];
    [_jamType setBackgroundColor:[UIColor colorWithPatternImage:[self captureView:visualEffectView]]];
    
    /* Setting Font & delegates */
    _jamName.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    _entryFee.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    _startTime.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    _sessionDescription.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    
    /* Text view place holder */
    _sessionDescription.delegate = self;
    _sessionDescription.text = @"Enter any extra details about location, custom game rules, etc here...";
    _sessionDescription.textColor = [UIColor darkGrayColor];
    _sessionDescription.layer.borderWidth = 1.5;
    _sessionDescription.layer.cornerRadius = 3; // rounded edges
    _sessionDescription.clipsToBounds = YES;
    _sessionDescription.layer.borderColor = [[UIColor redColor] CGColor];
    
    // Text fields
    _jamName.backgroundColor = [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.6];
    _jamName.layer.borderColor = [[UIColor redColor] CGColor];
    _jamName.layer.borderWidth = 1.0;
    _jamName.layer.cornerRadius = 3; // rounded edges
    _jamName.clipsToBounds = YES;
    _jamName.textAlignment = NSTextAlignmentCenter;
    _jamName.titleLabel.textAlignment = NSTextAlignmentCenter;
    _jamName.delegate = self;
    
    _entryFee.backgroundColor = [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.6];
    _entryFee.layer.borderColor = [[UIColor redColor] CGColor];
    _entryFee.layer.borderWidth = 1.0;
    _entryFee.textAlignment = NSTextAlignmentCenter;
    _entryFee.titleLabel.textAlignment = NSTextAlignmentCenter;
    _entryFee.layer.cornerRadius = 3; // rounded edges
    _entryFee.clipsToBounds = YES;
    _entryFee.delegate = self;
    
    _startTime.backgroundColor = [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.6];
    _startTime.layer.borderColor = [[UIColor redColor] CGColor];
    _startTime.layer.borderWidth = 1.0;
    _startTime.textAlignment = NSTextAlignmentCenter;
    _startTime.titleLabel.textAlignment = NSTextAlignmentCenter;
    _startTime.layer.cornerRadius = 3; // rounded edges
    _startTime.clipsToBounds = YES;
    _startTime.delegate = self;
    
    // Fill in details for fields if editing jam
    if (_editingJam)
        [self fillInTextField];

    // Set text attributes for explain text box rules
    self.explanView.attributedText = [self setUpExplainView]; // set text
    
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
    _backGroundPic.image = [UIImage imageNamed:@"compBack.jpg"];
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

/** Touching the "Change date" or "Done button calls this method **/
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

// Return cancels keyboard/datepicker
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
    _entryFee.text = _seshController.entryFee;
    [self setUpEditingProperties];
}

-(void)setUpEditingProperties {
    _railPicture = true; // so the user can edit a jam without being told to fill in more pictures
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



/** Game Type Rules **/
-(NSMutableAttributedString*)setUpExplainView {
    // Set Up text
    NSDictionary *attributesSmall = @{
                                      NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:15.0],
                                      NSForegroundColorAttributeName : [UIColor blackColor]
                                      };
    
    NSDictionary *attributesLarge = @{
                                      NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:20.0],
                                      NSForegroundColorAttributeName : [UIColor blackColor]
                                      };
    
    NSAttributedString *skate = [[NSAttributedString alloc] initWithString:@"S-K-A-T-E\n"
                                                                attributes:attributesLarge];
    NSAttributedString *bestLine = [[NSAttributedString alloc] initWithString:@"Best Line\n"
                                                                   attributes:attributesLarge];
    NSAttributedString *bestTrick = [[NSAttributedString alloc] initWithString:@"Best Trick\n"
                                                                    attributes:attributesLarge];
    NSAttributedString *entryFee = [[NSAttributedString alloc] initWithString:@"Entry Fee Rules\n"
                                                                   attributes:attributesLarge];
    
    NSAttributedString *skateDesc = [[NSAttributedString alloc] initWithString:@"Played the same as H-O-R-S-E. Choose an order of jammers. Jammer one chooses a feature, names a trick, and attempts to stomp it. If successful, all jammers in specified order gets one attempt at the trick. If they fail, take a letter. If the trick creator fails to complete the trick, the next jammer in the order creates the next trick. The winner is the last person to not have all 5 letters. It is of upmost importance that jammers honor all fellow jammers and respect the game.\n\n"
                                                                    attributes:attributesSmall];
    NSAttributedString *bestLineDesc = [[NSAttributedString alloc] initWithString:@"A designated line of features or flat ground is chosen. Each jammer has a chance to complete the designated line to the best of their ability. This game has 5 rounds. A round ends when each jammer has had one attempt at the chosen line. A line should be judged based on the level of difficulty of all tricks, quantity of tricks, and cleanest execution. It is recommended that each judge rates the line on a 1-10 scale and average the scores of each judge. Judges consist of each other jammer as well as any person that wishes to partake in judging the jam. The winner of this game is the jammer with the highest average score on a single line throughout all 5 rounds. It is of upmost importance that jammers use fair judgement, honor all fellow jammers, and respect the game.\n\n"
                                                                       attributes:attributesSmall];
    NSAttributedString *bestTrickDesc = [[NSAttributedString alloc] initWithString:@"Jammers attempt to do their best trick on the specified feature as chosen in the create jam form page. This game has 5 rounds. A round ends when each jammer has had one attempt at a trick of their choosing on the specified feature. Tricks should be judged based on the level of difficulty and cleanest execution. It is reccomended that each judge rates the trick on a 1-10 scale and average the scores of each judge. Judges consist of each other jammer as well as any person that wishes to partake in judging the jam. The winner of this game is the jammer with the highest average score on a single trick throuhgout all 5 rounds. It is of upmost importance that jammers use fair judgement, honor all fellow jammers, and respect the game.\n\n"
                                                                        attributes:attributesSmall];
    NSAttributedString *entryFeeDesc = [[NSAttributedString alloc] initWithString:@"If an entry fee is specified, all jammers must pay an entry fee to the jam's host. The host is in charge of holding onto the submitted fees. The winner of the jam is awarded the whole pot."
                                                                       attributes:attributesSmall];
    NSMutableAttributedString *explainText = [[NSMutableAttributedString alloc] init];
    [explainText appendAttributedString:skate];
    [explainText appendAttributedString:skateDesc];
    [explainText appendAttributedString:bestTrick];
    [explainText appendAttributedString:bestTrickDesc];
    [explainText appendAttributedString:bestLine];
    [explainText appendAttributedString:bestLineDesc];
    [explainText appendAttributedString:entryFee];
    [explainText appendAttributedString:entryFeeDesc];
    
    // Set Up Gestures
    [self setUpGameTypeGestures];
    
    return explainText;
}

-(void)setUpGameTypeGestures {
    /* Remove Explanation box gesture */
    _explanView = [[UITextView alloc] initWithFrame:CGRectMake(10.0, 35.0,
                                                               self.view.frame.size.width-20.0,
                                                               self.view.frame.size.height-75.0)];
    _explanView.layoutManager.delegate = self;
    
    UITapGestureRecognizer *tapExplanations = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showExplanations)];
    tapExplanations.cancelsTouchesInView = NO;
    [tapExplanations setDelegate:self];
    [_explanationLabel addGestureRecognizer:tapExplanations];

    UITapGestureRecognizer *removeExplainBox = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeExplain)];
    removeExplainBox.cancelsTouchesInView = NO;
    [removeExplainBox setDelegate:self];
    [_explanView addGestureRecognizer:removeExplainBox];
}

- (void)showExplanations {
    SPAM(("Show explain...\n"));
    if ([self.view viewWithTag:explainViewTag] == nil) {
        self.explanView.layer.borderWidth = 2.0f;
        self.explanView.layer.borderColor = [[UIColor redColor] CGColor];
        self.explanView.backgroundColor = [UIColor whiteColor];
        self.explanView.textColor = [UIColor blackColor];
        self.explanView.center = self.view.center;
        self.explanView.alpha = 0.0;
        self.explanView.clipsToBounds = YES;
        self.explanView.layer.cornerRadius = 10.0f;
        self.explanView.tag = explainViewTag;
        self.explanView.bounces = false;
        
        self.explanView.editable = false;
        
        [self.view addSubview:self.explanView];
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             _explanView.alpha = 0.95;
                         }
                         completion:^(BOOL finished){ }];
    }
}

/* Remove Game Type Rules */
-(void)removeExplain {
    [UIView animateWithDuration:0.3
                     animations:^{ _explanView.alpha = 0.0; }
                     completion:^(BOOL finished){ [[self.view viewWithTag:explainViewTag]removeFromSuperview]; }];
}

/** Upload Picture Rail and Prize Buttons **/
-(IBAction)railUpload:(id)sender {
    /* Set pic type */
    self.pictureType = @"rail";
    [self presentViewController:[self setUpImagePickerController] animated:YES completion:NULL];
}

-(IBAction)prizeUpload:(id)sender {
    /* Set pic type */
    self.pictureType = @"prize";
    [self presentViewController:[self setUpImagePickerController] animated:YES completion:NULL];
}

-(QBImagePickerController*)setUpImagePickerController {
    /* Image Picker */
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
    return imagePickerController;
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
                            if ([self.pictureType isEqual: @"rail"]) {
                                [self setUpJamPicture:image];
                            } else { // It is a prize
                                [self setUpPrizePicture:image];
                            }
                        }];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)setUpJamPicture:(UIImage*)image {
    _railPicture = true;
    // Save Image in session object
    (_editingJam) ? [_extraPicturesArr addObject:image] : [self.seshController.sessionPictures addObject:image];
    /* Change button to green */
    [_railUpload setTitleColor:[UIColor greenColor] forState:UIControlStateNormal]; // color and boarder
    _railUpload.layer.borderColor = [[UIColor greenColor] CGColor];
}

-(void)setUpPrizePicture:(UIImage*)image {
    _prizePicture = true;
    // Save Image in session object
    (_editingJam) ? [_extraPicturesArr addObject:image] : [self.seshController.sessionPictures addObject:image];;
    /* Change button to green */
    [_prizeUpload setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    _prizeUpload.layer.borderColor = [[UIColor greenColor] CGColor];
}

-(void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/** Create Competitive Jam **/
-(IBAction)createRailJam:(id)sender {
    // Check if it is a private jam, if so must have at least one invite friend
    [self checkIfPrivateAndInvitedFrined];
}

-(void)checkIfPrivateAndInvitedFrined {
    if ([_privateGame.titleLabel.text isEqualToString:@"private"] && [_seshController.invitedFriends count] < 1
        && [_extraFriendsArr count] < 1) {
        [AlertView showAlertTab:@"Must invite at least one friend if hosting a private jam" view:self.view];
    } else {
        [self checkIfValidCompetitiveJam];
    }
}

-(void)checkIfValidCompetitiveJam {
    if (_railPicture && !([self.startTime.text isEqualToString:@""]) && !([self.jamName.text isEqualToString:@""])) {
        [self backToMainView:self];
        [self setUpSessionObjectWithInfo];
    } else {
        [AlertView showAlertTab:@"Must have a jam name, start time and features image!" view:self.view];
    }
}

/* SAVE DATA ABOUT RAIL JAM SESH IN Session object */
-(void)setUpSessionObjectWithInfo {
    /* Get from UITextFields */
    self.seshController.jamName= self.jamName.text;
    self.seshController.entryFee = self.entryFee.text;
    self.seshController.startTime = self.startTime.text;
    self.seshController.sessionHostName = self.mainAccountUsername;
    
    if ([self.sessionDescription.text isEqualToString:@"Enter any extra details about location, custom game rules, etc here..."]) {
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
    id<SeshDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(finishEditingJam:editSession:extraPicturesArr:extraFriendsArr:)]) {
        [strongDelegate finishEditingJam:_mainLocalSession editSession:self.seshController extraPicturesArr:self.extraPicturesArr extraFriendsArr:_extraFriendsArr];
    }
}

-(void)placeMarkerDelegate {
    id<SeshDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(placeMarker:)]) {
        [strongDelegate placeMarker:self.seshController];
    }
}

/** Picker stuff **/
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
    if (!tView) {
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        tView.font = [UIFont fontWithName:@"ActionMan" size:17.0];
        tView.text = _pickerData[row];
        tView.textAlignment = NSTextAlignmentCenter;
        self.seshController.jamType = _pickerData[row];
    }
    // Fill the label text here
    return tView;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.seshController.jamType = _pickerData[row];
}

/** Date Picker **/
-(IBAction)datePickerBtnAction:(id)sender {
    if ([_changeDate.titleLabel.text isEqualToString:@"Done"]) { // dismiss keyboard instead

    } else { // normal action - show date picker
        [self.view addSubview:_datePicker];
        [self.view bringSubviewToFront:_datePicker];
        
        [_changeDate setTitle:@"Done" forState:UIControlStateNormal]; // Give the user an option to be "Done" with changing date
        
        [UIView transitionWithView:self.view
                          duration:0.2
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^ {
                            _datePicker.frame = CGRectMake(0, self.view.frame.size.height-250, self.view.frame.size.width, 250);
                        }
                        completion:nil];
    }
}

-(IBAction)inviteFriends:(id)sender {
    [self performSegueWithIdentifier:@"inviteFriendSegue" sender:self];
}

/* Change between public/private jam */
- (IBAction)privateJam:(id)sender {
    if ([_privateGame.titleLabel.text isEqualToString:@"public"]) {
        [_privateGame setTitle:@"private" forState:UIControlStateNormal];
        _seshController.privateJam = @"private";
    } else {
        [_privateGame setTitle:@"public" forState:UIControlStateNormal];
        _seshController.privateJam = @"public";
    }
}

// Delegate from InviteFriendsController.m
-(void)endInviteFriends {
    /* Change button to green */
    [_inviteFriends setTitleColor:[UIColor greenColor] forState:UIControlStateNormal]; // color and boarder
    _inviteFriends.layer.borderColor = [[UIColor greenColor] CGColor];
}

- (IBAction)backToMainView:(id)sender {
    // CALL BACK, NO JAM
    _backGroundPic.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width+35, self.view.frame.size.height+35);
    [self dismissViewControllerAnimated:YES completion:nil];
}


/* Text View Delegates */
- (void)textViewDidBeginEditing:(UITextView *)textView {
    SPAM(("begin edit\n"));
    if ([textView.text isEqualToString:@"Enter any extra details about location, custom game rules, etc here..."]) {
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
        textView.text = @"Enter any extra details about location, custom game rules, etc here...";
        textView.textColor = [UIColor darkGrayColor];
    }
    [textView resignFirstResponder];
    
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(65.0, 0.0, 0.0, 0.0);
        _scrollView.contentInset = contentInsets;
        _scrollView.scrollIndicatorInsets = contentInsets;
    } completion:^(BOOL finished) { }];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
