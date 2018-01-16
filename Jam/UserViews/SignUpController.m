//
//  SignUpController.m
//  RailJam
//
//  Created by Ben Ferraro on 7/4/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignUpController.h"

@interface SignUpController ()

@end

@implementation SignUpController


static NSString* const kMarkers = @"markers";
static NSString* const kFiles = @"files";

- (void)viewDidLoad {

}


/* Move view with taps */
-(void)moveView:(UITapGestureRecognizer *)gestureRecognizer {
    
    if(gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        if (_tapNumber == 1) { // full screen
            _jamPhotosScroll.hidden = false; // reveal images
            _jamPhotosLabel.hidden = false;
            
            _scrollView.scrollEnabled = true;
            _scrollViewFullScreen = true;
            [UIView transitionWithView:self.view
                              duration:0.3
                               options:UIViewAnimationOptionCurveEaseIn
                            animations:^ {
                                if (self.view.frame.size.height == 812.0) { // iphoneX top tab
                                    self.view.frame = CGRectMake(0.0, 45.0, self.view.frame.size.width, self.view.frame.size.height);
                                } else {
                                    self.view.frame = CGRectMake(0.0, 20.0, self.view.frame.size.width, self.view.frame.size.height);
                                }
                            }
                            completion:nil];
            
            UILabel *lineViewExplain = (UILabel*)[self.view viewWithTag:10]; // extend vs remove text
            lineViewExplain.text = @"Tap dot to remove";
            lineViewExplain.textColor = _textLabelColor;
            _tapNumber -= 1;
        } else if (_tapNumber == 0) {
            [UIView transitionWithView:self.view
                              duration:0.3
                               options:UIViewAnimationOptionCurveEaseIn
                            animations:^ {
                                self.view.frame = CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                            }
                            completion:^(BOOL finished) {
                                // remove bot view
                                id<SignUpDelegate> strongDelegate = self.delegate;
                                
                                // Our delegate method is optional, so we should
                                // check that the delegate implements it
                                if ([strongDelegate respondsToSelector:@selector(removeBotView)]) {
                                    [strongDelegate removeBotView];
                                }
                            } ];
        }
    }
}

-(void)loadSessionContent:(NSMutableDictionary*)localSignUpPictureCache {
    [super viewDidLoad];
    SPAM(("\nLoading Sign Up Controller\n"));

    /* Update userLat/userLong for signing up range */
    LocationManager *sharedLocationManager = [LocationManager sharedLocationManager];
    [sharedLocationManager setLocationCoord:^(NSError *error, BOOL success) { }];
    
    
    _scrollViewFullScreen = false;
    
    [_scrollView flashScrollIndicators];
    
    /** Set Frames **/
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    BOOL isHost = [_loggedInSignUpAccount.userName isEqualToString:_mainSignUpSession.sessionHostName]; // user is the host!
    
    if ([_mainSignUpSession.privateJam isEqualToString:@"private"] && !isHost) {
        _textLabelColor = [UIColor whiteColor];
    } else {
        _textLabelColor = [UIColor blackColor];
    }
    
    // Host name label
    _signUpHostName = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 35.0, 146.0, 33.0)];
    _signUpHostName.textAlignment = NSTextAlignmentLeft;
    _signUpHostName.font = [UIFont fontWithName:@"ActionMan" size:18.0];
    _signUpHostName.textColor = _textLabelColor;
    
    // Start time/date name label
    _signUpStartTime = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-140.0, 35.0, 130.0, 33.0)];
    _signUpStartTime.textAlignment = NSTextAlignmentRight;
    _signUpStartTime.font = [UIFont fontWithName:@"ActionMan" size:18.0];
    _signUpStartTime.textColor = _textLabelColor;
    
    // Game type name label
    _signUpGameType = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 71.0, 207.0, 33.0)];
    _signUpGameType.textAlignment = NSTextAlignmentLeft;
    _signUpGameType.font = [UIFont fontWithName:@"ActionMan" size:18.0];
    _signUpGameType.textColor = _textLabelColor;
    
    // Entry Fee label
    _signUpEntryFee = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-140.0, 71.0, 130.0, 33.0)];
    _signUpEntryFee.textAlignment = NSTextAlignmentRight;
    _signUpEntryFee.font = [UIFont fontWithName:@"ActionMan" size:18.0];
    _signUpEntryFee.textColor = _textLabelColor;
    
    // Jammers label
    _jammersLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 103.0, 146.0, 33.0)];
    _jammersLabel.text = @"Jammers Signed Up:";
    _jammersLabel.font = [UIFont fontWithName:@"ActionMan" size:16.0];
    _jammersLabel.textColor = _textLabelColor;
    
    // number of jammers label
    _numOfJammers = [[UILabel alloc] initWithFrame:CGRectMake(162.0, 109.0, 86.0, 21.0)];
    _numOfJammers.font = [UIFont fontWithName:@"ActionMan" size:16.0];
    _numOfJammers.textColor = _textLabelColor;

    // SignUp / withdraw Button
    _SignUpButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 146.0,
                                                               screenWidth-20.0, 40.0)];
    _SignUpButton.clipsToBounds = YES;
    _SignUpButton.layer.cornerRadius = 3;
    
    // Scroll Image View / Label
    _jamPhotosLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,(_SignUpButton.frame.origin.y+_SignUpButton.frame.size.height+10.0),
                                                                         screenWidth-20.0, 35.0)];
    _jamPhotosLabel.text = @"Jam Photos:";
    _jamPhotosLabel.font = [UIFont fontWithName:@"ActionMan" size:22.0];
    _jamPhotosLabel.hidden = true;
    _jamPhotosLabel.textColor = _textLabelColor;

    _jamPhotosScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0,(_jamPhotosLabel.frame.origin.y+_jamPhotosLabel.frame.size.height+10.0),
                                                                      screenWidth, screenHeight/1.5)];
    _jamPhotosScroll.showsHorizontalScrollIndicator = true;
    _jamPhotosScroll.pagingEnabled=YES;
    _jamPhotosScroll.backgroundColor = [UIColor clearColor];
    
    // no images label
    _noImages = [[UILabel alloc] initWithFrame:CGRectMake(0.0, (_jamPhotosScroll.frame.origin.y + _jamPhotosScroll.frame.size.height/2),
                                                          screenWidth, 25.0)];
    _noImages.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    _noImages.text = @"No Images";
    _noImages.textAlignment = NSTextAlignmentCenter;
    _noImages.textColor = _textLabelColor;
    
    UILabel *jammerListLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,(_jamPhotosScroll.frame.origin.y+_jamPhotosScroll.frame.size.height+10.0),
                                                                        screenWidth-20.0, 35.0)];
    jammerListLabel.text = @"Jammers: ";
    jammerListLabel.font = [UIFont fontWithName:@"ActionMan" size:22.0];
    jammerListLabel.textColor = _textLabelColor;
    
    // Table view
    _jammerTable = [[UITableView alloc] initWithFrame:CGRectMake(10.0, (jammerListLabel.frame.origin.y+jammerListLabel.frame.size.height+5.0),
                                                                      screenWidth-20.0, screenHeight/2)];
    _jammerTable.delegate = self;
    _jammerTable.dataSource = self;
    _jammerTable.clipsToBounds = YES;
    _jammerTable.layer.cornerRadius = 3;
    _jammerTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _jammerTable.layer.borderColor = [[UIColor colorWithRed:255.0/255 green:130.0/255 blue:102.0/255.0 alpha:1.0] CGColor];
    _jammerTable.layer.borderWidth = 2.0;
    _jammerTable.backgroundColor = [UIColor clearColor];
    _jammerTable.userInteractionEnabled = YES;
    _jammerTable.bounces = NO;
    
    UILabel *extraWordsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,(_jammerTable.frame.origin.y+_jammerTable.frame.size.height+10.0),
                                                                         screenWidth-20.0, 35.0)];
    extraWordsLabel.text = @"Extra Details: ";
    extraWordsLabel.font = [UIFont fontWithName:@"ActionMan" size:22.0];
    extraWordsLabel.textColor = _textLabelColor;
    
    // Extra words
    _extraWords = [[UITextView alloc] initWithFrame:CGRectMake(10.0,
                                                (extraWordsLabel.frame.origin.y+extraWordsLabel.frame.size.height+5.0),
                                                            screenWidth-20.0, 200.0)];
    if ([_mainSignUpSession.seshDescription length] == 0) {
        _extraWords.text = @"No Extra Details";
    } else {
        _extraWords.text = _mainSignUpSession.seshDescription;
    }
    _extraWords.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    _extraWords.textAlignment = NSTextAlignmentCenter;
    _extraWords.backgroundColor = [UIColor clearColor];
    _extraWords.textColor = _textLabelColor;
    _extraWords.editable = false;
    
    /* Top dot for tapping */
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-5.0, 10.0, 10.0, 10.0)];
    lineView.backgroundColor = [UIColor blackColor];
    lineView.alpha = 0.5;
    lineView.layer.cornerRadius = 5; // rounded edges
    lineView.clipsToBounds = YES;
    
    /* Top line explain */
    UILabel *lineViewExplain = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-50.0, 23.0, 100.0, 10.0)];
    lineViewExplain.text = @"Tap dot to extend";
    lineViewExplain.textAlignment = NSTextAlignmentCenter;
    lineViewExplain.font = [UIFont fontWithName:@"ActionMan" size:11.0];
    lineViewExplain.tag = 10;
    lineViewExplain.textColor = _textLabelColor;
    
    // Scroll view -- calculate content size!
    CGFloat contentSizeCalculated = _extraWords.frame.origin.y + _extraWords.frame.size.height+40.0;
    _scrollView.frame = CGRectMake(0.0, 0.0, screenWidth, contentSizeCalculated);
    [_scrollView setContentSize:CGSizeMake(screenWidth, contentSizeCalculated)];
    _scrollView.bounces = false;
    _scrollView.scrollEnabled = false;
    
    [_scrollView addSubview:lineViewExplain];
    [_scrollView addSubview:lineView];
    [_scrollView addSubview:_signUpHostName];
    [_scrollView addSubview:_signUpStartTime];
    [_scrollView addSubview:_signUpGameType];
    [_scrollView addSubview:_signUpEntryFee];
    [_scrollView addSubview:_jammersLabel];
    [_scrollView addSubview:_numOfJammers];
    [_scrollView addSubview:_noImages];
    [_scrollView addSubview:_jamPhotosScroll];
    [_scrollView addSubview:_jamPhotosLabel];
    [_scrollView addSubview:_SignUpButton];
    [_scrollView addSubview:jammerListLabel];
    [_scrollView addSubview:_jammerTable];
    [_scrollView addSubview:extraWordsLabel];
    [_scrollView addSubview:_extraWords];

    /* Set Move Gestures (Swipe Up, Tap) */
    _tapNumber = 1;
    UITapGestureRecognizer *tapGestureMoveView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveView:)];
    tapGestureMoveView.delegate = self;
    _swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveView:)];
    _swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:_swipeUp];
    [self.view addGestureRecognizer:tapGestureMoveView];
    
    /* Load Pics */
    if ([_mainSignUpSession.sessionPictureIDs count] == 0) {
        _noImages.hidden = false;
    } else {
        _noImages.text = [NSString stringWithFormat:@"Loading %lu images...", (unsigned long)[_mainSignUpSession.sessionPictureIDs count]];
        
        /* This session has pics that have not been loaded,
           sessionPictures array will work at a local cache */
        if ([[localSignUpPictureCache objectForKey:_mainSignUpSession._id] isEqualToString:@"false"]) {
            _mainSignUpSession.sessionPictures = [[NSMutableArray alloc] init]; // allocate room for pictures 
            [self loadImage:_mainSignUpSession localSignUpPictureCache:localSignUpPictureCache]; // load images
        } else {
            // Populate Scroll view
            [self populateJamImages];
        }
    }
    
    
    /* Text Labels */
    _signUpHostName.text = _mainSignUpSession.sessionHostName;
    _signUpGameType.text = _mainSignUpSession.jamType;
    
    /* Check Date and set to date or time */
    NSDate *date = [NSDate date]; // Get Date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    NSString *stringFromDate = [formatter stringFromDate:date];
    NSString *currDate = stringFromDate;
    if ([currDate isEqualToString:_mainSignUpSession.jamDate]) {
        _signUpStartTime.text = _mainSignUpSession.startTime;
    } else {
        _signUpStartTime.text = _mainSignUpSession.jamDate;
    }
    
    /* Entry fee */
    if ([_mainSignUpSession.entryFee length] == 0) {
        if ([_mainSignUpSession.LeisureorComp isEqualToString:@"comp"]) { // print only if comp
            _signUpEntryFee.text = @"No Entry Fee";
        } else {
            _signUpEntryFee.text = @"N/A";
        }
    } else {
        _signUpEntryFee.text = _mainSignUpSession.entryFee;
    }
    
    /* List of Sessions Jammers */
    if ([_mainSignUpSession.jammers count] == 0) { // No jammers Signed Up
        _jammerTable.hidden = true;
    }
    _numOfJammers.text = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[_mainSignUpSession.jammers count]]; // set number of jammers number
    
    
    /* Button Color */
    [_SignUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; // color and boarder
    _SignUpButton.titleLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    _SignUpButton.backgroundColor = [UIColor colorWithRed:255.0/255 green:130.0/255 blue:102.0/255.0 alpha:1.0];
    _SignUpButton.layer.borderColor = [[UIColor colorWithRed:255.0/255 green:130.0/255 blue:102.0/255.0 alpha:1.0] CGColor];
    _SignUpButton.layer.borderWidth = 2.0;
    if ([_mainSignUpSession.sessionHostName isEqualToString:self.loggedInSignUpAccount.userName]) {
        [_SignUpButton setTitle:@"Edit Jam Info" forState:UIControlStateNormal];
        [_SignUpButton addTarget:self action:@selector(EditJam:) forControlEvents:UIControlEventTouchUpInside];
    } else if (![_mainSignUpSession.jammers containsObject:self.loggedInSignUpAccount.userName]) {
        [_SignUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
        [_SignUpButton addTarget:self action:@selector(SignUp:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [_SignUpButton setTitle:@"Withdraw" forState:UIControlStateNormal];
        [_SignUpButton addTarget:self action:@selector(SignUp:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    /* Set background */
    if (isHost) { 
        self.view.backgroundColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0]; // dank blue
    } else {
        self.view.backgroundColor = [UIColor clearColor];
    }
    
    /* Blur effect!! */
    // create effect
    UIBlurEffect *blur;
    if ([_mainSignUpSession.privateJam isEqualToString:@"private"] && !isHost) { // dark color -- private
        blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    } else { // regular color -- public
        blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    }
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    // add the effect view to the image view
    [self.view addSubview:effectView];
    [self.view sendSubviewToBack:effectView];
}

/* Fulls screen */
-(void)fullScreen:(UIGestureRecognizer *)gestureRecognizer {
    SPAM(("\nFull Screen\n"));
    
    if (_isFullScreen) { // shrink image back down

        /* Remove swipe gestures */
        [self.view addGestureRecognizer:_swipeUp];
        [self.view addGestureRecognizer:_swipeDown];
        
        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
            [self.view sendSubviewToBack:_jamPhotosScroll];
            _jamPhotosScroll.backgroundColor = [UIColor clearColor];
            _jamPhotosScroll.frame = _oldScrollFrame;
            [_scrollView setContentSize:_oldContentSize];
            
            int index = 0;
            for (UIImageView *imgView in [_jamPhotosScroll subviews]) {
                CGRect someRect = [[_oldImageFrames objectAtIndex:index] CGRectValue];
                imgView.frame = someRect;
                index += 1;
            }
            
            
        } completion:^(BOOL finished) {
            _isFullScreen = false;
        }];

    } else { // make full screen

        /* For full screen images */
        _oldImageFrames = [[NSMutableArray alloc] init];
        
        /* Remove swipe gestures */
        [self.view removeGestureRecognizer:_swipeUp];
        [self.view removeGestureRecognizer:_swipeDown];

        _oldScrollFrame = _jamPhotosScroll.frame;
        
        for (UIImageView *imgView in [_jamPhotosScroll subviews]) {
            CGRect tmpFrame = CGRectMake(imgView.frame.origin.x, imgView.frame.origin.y,
                                           imgView.frame.size.width, imgView.frame.size.height);
            [_oldImageFrames addObject:[NSValue valueWithCGRect:tmpFrame]];
        }
                
        _oldContentSize = _scrollView.contentSize;

        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
            [_scrollView bringSubviewToFront:_jamPhotosScroll];
            [_scrollView setContentSize:CGSizeMake(0.0, 0.0)];
            _jamPhotosScroll.backgroundColor = [UIColor blackColor];
            _jamPhotosScroll.frame = CGRectMake(0.0, 0.0, _scrollView.frame.size.width, _scrollView.frame.size.height);
            for (UIImageView *imgView in [_jamPhotosScroll subviews]) {
                CGFloat imageViewX = imgView.frame.origin.x;
                CGFloat imageViewY = imgView.frame.origin.y;
                imgView.frame = CGRectMake(imageViewX, imageViewY, _scrollView.frame.size.width, _scrollView.frame.size.height);
            }

        } completion:^(BOOL finished) {
            _isFullScreen = true;
        }];
    }
}

-(IBAction)EditJam:(id)sender {
    
    // Create new session object from _mainSignUpSession, so local session is never changed
    // pass both objects all the way to finishEditingJam in ViewController
    // Only if the editJam call to the DB returns success, then you update the user's
    // local session object
    
    Session *editSession = [[Session alloc] initWithDictionary:[self.mainSignUpSession toDictionary]];
    editSession.sessionPictures = [[NSMutableArray alloc] init];
    editSession.sessionPictureIDs = [[NSMutableArray alloc] init];
    
    id<SignUpDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(editJam:editSession:)]) {
        [strongDelegate editJam:_mainSignUpSession editSession:editSession]; // called from main view
    }
}

/* Add account name to list of Sessions jammers */
-(IBAction)SignUp:(id)sender {
    SPAM(("Signing up"));
    
    /* Add account name to jammers, if name doesn't exist */
    if (![_mainSignUpSession.jammers containsObject:self.loggedInSignUpAccount.userName]) {
        
        LocationManager *sharedLocationManager = [LocationManager sharedLocationManager];
        /* Must be within 20 miles to sing up for a jam! */
        CGFloat jamLat = [_mainSignUpSession.sessionLat doubleValue];
        CGFloat jamLong = [_mainSignUpSession.sessionLong doubleValue];
        CLLocation *jamLoc = [[CLLocation alloc] initWithLatitude:jamLat longitude:jamLong];
        CLLocation *userLoc = [[CLLocation alloc] initWithLatitude:sharedLocationManager.userLat longitude:sharedLocationManager.userLong];
        
        if ([jamLoc distanceFromLocation:userLoc] < 321867.0 || _fromAppDelegateSignUp) { // within 20 miles or if coming from AppDelegate.m
            [_mainSignUpSession.jammers addObject:self.loggedInSignUpAccount.userName]; // add to local object
            
            /* Update DB */
            [Session updateJammer:kBaseURL seshID:_mainSignUpSession._id userName:self.loggedInSignUpAccount.userName actionMode:@"add" message:_loggedInSignUpAccount._accountid callback:^(NSError *error, BOOL success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success && error == nil) {
                        // refresh map
                        id<SignUpDelegate> strongDelegate = self.delegate;
                        if ([strongDelegate respondsToSelector:@selector(refreshMarker:)]) {
                            [strongDelegate refreshMarker:_mainSignUpSession._id]; // called from main view
                        }
                    } else {
                        
                        // Remove jammer from local object!
                        [_mainSignUpSession.jammers removeObject:_mainSignUpSession.jammers.lastObject];
                        
                        /* Loading alert box */
                        [AlertView showAlertControllerOkayOption:@"Trouble joining Jam" message:@"Try again -- This is either a network issue or the Jam has been ended or cancelled." view:self];
                    }
                });
            }];
        } else {
            /* Loading alert box */
            [AlertView showAlertControllerOkayOption:@"Too Far Out" message:@"Must be within 20 miles of a Jam to sign up" view:self];
        }
    } else {
        SPAM(("Withdrawing\n"));
        /* Remove jammer from jammers list */
        [_mainSignUpSession.jammers removeObject:self.loggedInSignUpAccount.userName];
        
        [Session updateJammer:kBaseURL seshID:_mainSignUpSession._id userName:self.loggedInSignUpAccount.userName actionMode:@"remove" message:_loggedInSignUpAccount._accountid callback:^(NSError *error, BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    // refresh map
                    id<SignUpDelegate> strongDelegate = self.delegate;
                    if ([strongDelegate respondsToSelector:@selector(refreshMarker:)]) {
                        [strongDelegate refreshMarker:_mainSignUpSession._id]; // called from main view
                    }
                } else {
                    
                    // Re-Add jammer from local object!
                    [_mainSignUpSession.jammers addObject:self.loggedInSignUpAccount.userName];
                    
                    /* Loading alert box */
                    [AlertView showAlertControllerOkayOption:@"Trouble withdrawing from Jam" message:@"Try again -- This is either a network issue or the Jam has been ended or cancelled." view:self];
                }
            });
        }];
    }
    
    // remove bot view
    id<SignUpDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(removeBotView)]) {
        [strongDelegate removeBotView]; // called from main view
    }
    
}

-(void)signUpFromAppDele {
    /* Add account name to jammers, if name doesn't exist */
    if (![_mainSignUpSession.jammers containsObject:self.loggedInSignUpAccount.userName]) {
        
        [_mainSignUpSession.jammers addObject:self.loggedInSignUpAccount.userName]; // add to DB
        
        /* Update DB */
        [Session updateJammer:kBaseURL seshID:_mainSignUpSession._id userName:self.loggedInSignUpAccount.userName actionMode:@"add" message:_loggedInSignUpAccount._accountid callback:^(NSError *error, BOOL success) {
            if (error) {
                // Remove jammer from local object!
                [_mainSignUpSession.jammers removeObject:_mainSignUpSession.jammers.lastObject];
            }
        }];
        
    }
}

#pragma mark UITableViewDelegate
#pragma mark UIGestureRecognizerDelegate methods
/* For scrolling on table view vs scrolling on _scrollView */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.jammerTable]) {
        return NO;
    } else {
        // Check if scroll view is full screen, else do not allow scrolling
        if (_scrollViewFullScreen) {
            _scrollView.scrollEnabled = true;
        }
    }
    return YES;
}

/** Table View Delegates **/
/* Side swipe kick Jammer table delegates */
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL cellEditable = false;
    if ([_mainSignUpSession.sessionHostName isEqualToString:_loggedInSignUpAccount.userName]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath]; // Cell
        NSString *cellText = cell.textLabel.text; // userName
        if ([cellText rangeOfString:@"Host"].location == NSNotFound) {
            // Search for "Host" in cell text, can't kick yourself
            cellEditable = true;
        }
    }
    return cellEditable;
}

-(NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Must be host to kick jammers!
    if ([_mainSignUpSession.sessionHostName isEqualToString:_loggedInSignUpAccount.userName]) {
        
        UITableViewRowAction *kickJammer = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Kick" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath]; // Cell
            NSString *userName = cell.textLabel.text; // cell text
            
            UIAlertController *alertControllerKick = [UIAlertController
                                                      alertControllerWithTitle:@"Kick Jammer?"
                                                      message:nil
                                                      preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   
                                                                   // Kick Jammer
                                                                   [AlertView showAlertTab:@"Kicking Jammer..." view:self.view];
                                                                   
                                                                   // Update DB and local session object
                                                                   [Session updateJammer:kBaseURL seshID:_mainSignUpSession._id userName:userName actionMode:@"remove" message:_loggedInSignUpAccount._accountid callback:^(NSError *error, BOOL success) {
                                                                       if (success) {
                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                               if ([_mainSignUpSession.jammers containsObject:userName]) {
                                                                                   [_mainSignUpSession.jammers removeObject:userName];
                                                                                   [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                                                                   _numOfJammers.text = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[_mainSignUpSession.jammers count]];
                                                                               }
                                                                           });
                                                                       } else {
                                                                           // Kick Jammer
                                                                           [AlertView showAlertTab:@"Could not kick jammer try again" view:self.view];
                                                                       }
                                                                   }];
                                                               }];
            
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) { /* Do nothing */ }];
            
            [alertControllerKick addAction:okayAction];
            [alertControllerKick addAction:cancelAction];
            
            [self presentViewController:alertControllerKick animated:YES completion:nil];
        }];
        
        kickJammer.backgroundColor = [UIColor redColor];
        return @[kickJammer];
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text; // userName
    
    // Check if there is "host involved"
    if ([cellText containsString:@"Host"]) {
        NSArray *array = [cellText componentsSeparatedByString:@" - "];
        cellText = [array objectAtIndex:1];
    }
 
    self.tmpAccount = [[Account alloc] init];
    
    [AlertView showAlertTab:@"Loading profile..." view:self.view];
    
    [Account loadAccount:kBaseURL userName:cellText initialLoad:@"no" message:_loggedInSignUpAccount._accountid
                callback:^(NSError *error, BOOL success, NSDictionary *responseAccount, NSInteger statusCode) {
                    /* Must do segue in main thread */
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success && [responseAccount objectForKey:@"userName"] != nil) {
                            SPAM(("Got Account success"));

                            /* Init tmpAccount with Sign Up's account info */
                            [self.tmpAccount initWithDictionary:responseAccount];
                            
                            /* Go to profile */
                            [self performSegueWithIdentifier:@"viewProfileSegue" sender:nil];
                        } else {
                            if (!success) {
                                [AlertView showAlertTab:@"Could not load account..." view:self.view];
                            } else {
                                [AlertView showAlertTab:@"No Accout with that Username, kick this jammer!" view:self.view];
                            }
                        }
                    });
                }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

// This will tell your UITableView how many rows you wish to have in each section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.mainSignUpSession.jammers count];
}

// This will tell your UITableView what data to put in which cells in your table.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifer = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    // Using a cell identifier will allow your app to reuse cells as they come and go from the screen.
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifer];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    // Deciding which data to put into this particular cell.
    // If it the first row, the data input will be "Data1" from the array.
    NSUInteger row = [indexPath row];
    if ([self.mainSignUpSession.sessionHostName isEqualToString:[self.mainSignUpSession.jammers objectAtIndex:row]]) {
        // This is the host
        NSString* hostString = [NSString stringWithFormat:@"Host - %@", [self.mainSignUpSession.jammers objectAtIndex:row]];
        cell.textLabel.text = hostString;
    } else {
        cell.textLabel.text = [self.mainSignUpSession.jammers objectAtIndex:row];
    }
    cell.textLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    cell.textLabel.textColor =_textLabelColor;
    
    return cell;
}


/* Populates the scroll view with images */
-(void)populateJamImages {
    SPAM(("\nPOPULATING IMAGES\n"));
    int x=0;
    _noImages.hidden = true;
    
    for (int i = 0; i < _mainSignUpSession.sessionPictures.count; i++) {
        UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(x, 0.0,[[UIScreen mainScreen] bounds].size.width, _jamPhotosScroll.frame.size.height)];
        UIImage *image = (UIImage*)[_mainSignUpSession.sessionPictures objectAtIndex:i];
        img.image = image;
        img.userInteractionEnabled = true;
        img.contentMode = UIViewContentModeScaleAspectFit;
        x = x + [[UIScreen mainScreen] bounds].size.width;
        [_jamPhotosScroll addSubview:img];
        
        UITapGestureRecognizer *fullScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreen:)];
        fullScreen.delegate = self;
        [img addGestureRecognizer:fullScreen];
        
    }
    
    _jamPhotosScroll.contentSize=CGSizeMake(x, _jamPhotosScroll.frame.size.height);
    _jamPhotosScroll.contentOffset=CGPointMake(0, 0);
    
}

/** DB METHODS **/

/* Load Rail and Prize image */
-(void)loadImage:(Session*)session localSignUpPictureCache:(NSMutableDictionary*)localSignUpPictureCache {
    SPAM(("\nloadImage\n"));
    
    localSignUpPictureCache[_mainSignUpSession._id] = @"true"; // pictures are being loaded!
    
    __block UIImage *image;
    
    for (NSString *imageID in session.sessionPictureIDs) {
        NSURL* url = [NSURL URLWithString:[[kBaseURL stringByAppendingPathComponent:kFiles] stringByAppendingPathComponent:imageID]]; 
        
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"GET";
        // Set Up Auth
        [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:_loggedInSignUpAccount._accountid];
        
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* URLsession = [NSURLSession sessionWithConfiguration:config];
        
        NSURLSessionDataTask* task = [URLsession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                
                if (!error && data != nil && [httpResponse statusCode] != 404) {
                
                    SPAM(("Succussfully getting image - %s\n", [imageID UTF8String]));
                
                    image = [UIImage imageWithData:data];
                    
                    // Just add too array - make sure image is not already there
                    if (![session.sessionPictures containsObject:image]) {
                        [session.sessionPictures addObject:image];
                        [self populateJamImages];
                    }
                } else {
                    NSLog(@"Error while loading Location or Prize pictures...%@\n",[error localizedDescription]);
                    /* Loading alert box */
                    [AlertView showAlertControllerOkayOption:@"Trouble loading Jam photos" message:nil view:self];
                }
            });
        }];
        
        [task resume]; 
    }
}


/* SEGUE CODE */
// Pass in info to next page
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"viewProfileSegue"]) {
        ProfileController *vc = [segue destinationViewController];
        vc.profileAccount = self.tmpAccount; // user of profile we clicked on (loaded from DB)
        vc.loggedInAccount = self.loggedInSignUpAccount; // logged in user
    }
}


@end
