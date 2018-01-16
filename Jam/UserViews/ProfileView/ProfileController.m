//
//  ProfileController.m
//  RailJam
//
//  Created by Ben Ferraro on 7/9/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProfileController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ProfileController

static NSString* const kAccountPictures = @"accountPictures"; // Holds Account Pictures
static NSString* const kAccountVideos = @"accountVideos"; // Hold Account Videos

-(void)viewDidAppear:(BOOL)animated {
    /* Flash */
    [self performSelector:@selector(flashBar) withObject:nil afterDelay:0];
    [self performSelector:@selector(flashBar) withObject:nil afterDelay:2];
    [self performSelector:@selector(flashBar) withObject:nil afterDelay:4];
    
    /* Load Account Videos, make sure all videos are loaded */
    if ([_profileAccount.featureVideos count] != [_profileAccount.featureVideoIDs count]) {
        [self loadVideos];
    }
}

/* Flash bar */
-(void)flashBar {
    [_scrollView flashScrollIndicators];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set Delegate
    _scrollView.delegate = self;
    
    // Get Profile Colors
    CGFloat redLine = [[_profileAccount.profileLineColor objectAtIndex:0] doubleValue]; // lineColor = BG color
    CGFloat greenLine = [[_profileAccount.profileLineColor objectAtIndex:1] doubleValue];
    CGFloat blueLine = [[_profileAccount.profileLineColor objectAtIndex:2] doubleValue];
    
    CGFloat redUN = [[_profileAccount.profileUNColor objectAtIndex:0] doubleValue]; // UNColor = textColor
    CGFloat greenUN = [[_profileAccount.profileUNColor objectAtIndex:1] doubleValue];
    CGFloat blueUN = [[_profileAccount.profileUNColor objectAtIndex:2] doubleValue];
    
    /** Set Frames **/
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.bounces = false;
    [self.view addSubview:_scrollView];
    
    if (screenHeight > 1000.0) { // ipads
        _scrollView.frame = CGRectMake(0.0, 0.0, screenWidth, screenHeight);
        [_scrollView setContentSize:CGSizeMake(screenWidth, screenHeight+1000.0)];
        
    } else { // not ipads (Iphone 7plus is height = 736.0)
        _scrollView.frame = CGRectMake(0.0, 0.0, screenWidth, screenHeight);
        [_scrollView setContentSize:CGSizeMake(screenWidth, screenHeight+800.0)];
    }
    
    _videoPage = [[UIButton alloc] initWithFrame:CGRectMake(10.0,
                                                            screenHeight+30.0,
                                                            screenWidth-20.0, 50.0)];
    
    // BIO
    UILabel *bioText = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                                 _videoPage.frame.origin.y+70.0,
                                                                 screenWidth-20.0,
                                                                 30.0)];
    bioText.text = @"Bio:";
    bioText.textAlignment = NSTextAlignmentLeft;
    bioText.font = [UIFont fontWithName:@"ActionMan" size:24.0];
    
    UITextView *bioDescription = [[UITextView alloc] initWithFrame:CGRectMake(10.0,
                                                                             bioText.frame.origin.y+35.0,
                                                                             screenWidth-20.0, 195.0)];
    if ([_profileAccount.accountBio length] == 0) {
        bioDescription.text = @"No Bio";
    } else {
        bioDescription.text = _profileAccount.accountBio;
    }
    bioDescription.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    bioDescription.editable = false;
    bioDescription.layer.cornerRadius = 3;
    bioDescription.clipsToBounds = true;
    bioDescription.textColor = [UIColor colorWithRed:redUN/255.0 green:greenUN/255.0 blue:blueUN/255.0 alpha:1.0];
    bioDescription.backgroundColor = [UIColor clearColor];
    
    // STATS
    UILabel *statsText = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                                   bioDescription.frame.origin.y+203.0,
                                                                   screenWidth-20.0,
                                                                   30.0)];
    statsText.text = @"Stats:";
    statsText.textAlignment = NSTextAlignmentLeft;
    statsText.font = [UIFont fontWithName:@"ActionMan" size:24.0];

    // NumberOfSessionsAttended
    UILabel *sessionAttendedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                                              statsText.frame.origin.y+35.0,
                                                                              screenWidth-20.0,
                                                                              30.0)];
    sessionAttendedLabel.text = @"Total Jams Attended";
    sessionAttendedLabel.textAlignment = NSTextAlignmentLeft;
    sessionAttendedLabel.textColor = [UIColor colorWithRed:redUN/255.0 green:greenUN/255.0 blue:blueUN/255.0 alpha:1.0];
    sessionAttendedLabel.font = [UIFont fontWithName:@"ActionMan" size:18.0];
    UILabel *sessionAttendedNumber = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                                               statsText.frame.origin.y+35.0,
                                                                               screenWidth-20.0,
                                                                               30.0)];
    sessionAttendedNumber.text = [_profileAccount.numberOfSessionsAttended stringValue];
    sessionAttendedNumber.textAlignment = NSTextAlignmentRight;
    sessionAttendedNumber.textColor = [UIColor colorWithRed:redUN/255.0 green:greenUN/255.0 blue:blueUN/255.0 alpha:1.0];
    sessionAttendedNumber.font = [UIFont fontWithName:@"ActionMan" size:18.0];
    
    // Competitive Wins
    UILabel *winsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                                   sessionAttendedLabel.frame.origin.y+35.0,
                                                                   screenWidth-20.0,
                                                                   30.0)];
    winsLabel.text = @"Competitive Wins";
    winsLabel.textAlignment = NSTextAlignmentLeft;
    winsLabel.textColor = [UIColor colorWithRed:redUN/255.0 green:greenUN/255.0 blue:blueUN/255.0 alpha:1.0];
    winsLabel.font = [UIFont fontWithName:@"ActionMan" size:18.0];
    UILabel *winsNumber = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                                    sessionAttendedLabel.frame.origin.y+35.0,
                                                                    screenWidth-20.0,
                                                                    30.0)];
    winsNumber.text = [_profileAccount.wins stringValue];
    winsNumber.textAlignment = NSTextAlignmentRight;
    winsNumber.textColor = [UIColor colorWithRed:redUN/255.0 green:greenUN/255.0 blue:blueUN/255.0 alpha:1.0];
    winsNumber.font = [UIFont fontWithName:@"ActionMan" size:18.0];

    // Total Entry Votes
    UILabel *entryVotesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                                         winsLabel.frame.origin.y+35.0,
                                                                         screenWidth-20.0,
                                                                         30.0)];
    entryVotesLabel.text = @"Total Entry Votes";
    entryVotesLabel.textAlignment = NSTextAlignmentLeft;
    entryVotesLabel.textColor = [UIColor colorWithRed:redUN/255.0 green:greenUN/255.0 blue:blueUN/255.0 alpha:1.0];
    entryVotesLabel.font = [UIFont fontWithName:@"ActionMan" size:18.0];
    UILabel *entryVotesNumber = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                                          winsLabel.frame.origin.y+35.0,
                                                                          screenWidth-20.0,
                                                                          30.0)];
    entryVotesNumber.text = [_profileAccount.totalVideoVotes stringValue];
    entryVotesNumber.textAlignment = NSTextAlignmentRight;
    entryVotesNumber.textColor = [UIColor colorWithRed:redUN/255.0 green:greenUN/255.0 blue:blueUN/255.0 alpha:1.0];
    entryVotesNumber.font = [UIFont fontWithName:@"ActionMan" size:18.0];
    
    // Places Jammed Map
    UILabel *placesJammed = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                                      entryVotesLabel.frame.origin.y+40.0,
                                                                      screenWidth-20.0, 30.0)];
    placesJammed.text = @"Jams Around the World:";
    placesJammed.textAlignment = NSTextAlignmentLeft;
    placesJammed.font = [UIFont fontWithName:@"ActionMan" size:24.0];
    
    // Place markers / Set up map view
    [self placeMarkers:placesJammed.frame.origin.y+45.0 screenWidth:screenWidth];

    // Line and total points / friends stats
    UIView *lineDivider = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2-1.5,
                                                                   screenHeight-100.0,
                                                                   3.0, 75.0)];
    lineDivider.backgroundColor = [UIColor colorWithRed:redUN/255.0 green:greenUN/255.0 blue:blueUN/255.0 alpha:1.0];
    lineDivider.clipsToBounds = YES;
    lineDivider.layer.cornerRadius = 5.0;
    
    UILabel *totalFriends = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/4-50.0, lineDivider.frame.origin.y-10.0,
                                                                      100.0, 40.0)];
    totalFriends.font = [UIFont fontWithName:@"ActionMan" size:22.0];
    totalFriends.textColor = [UIColor colorWithRed:redUN/255.0 green:greenUN/255.0 blue:blueUN/255.0 alpha:1.0];
    totalFriends.textAlignment = NSTextAlignmentCenter;
    // Friends List Gesture // underline
    UITapGestureRecognizer *tapGestureFriendsList = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFriendsList)];
    tapGestureFriendsList.delegate = self;
    totalFriends.userInteractionEnabled = YES;
    [totalFriends addGestureRecognizer:tapGestureFriendsList];
    
    NSMutableAttributedString *friendsString = [[NSMutableAttributedString alloc] initWithString:@"Friends"];
    [friendsString addAttribute:NSUnderlineStyleAttributeName
                           value:[NSNumber numberWithInt:7]
                           range:(NSRange){0,[friendsString length]}];
    totalFriends.attributedText = friendsString; // underlined string
    
    UILabel *totalPointsVotes = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth*0.75)-65.0, lineDivider.frame.origin.y-10.0,
                                                                      130.0, 40.0)];
    totalPointsVotes.text = @"Total Points";
    totalPointsVotes.font = [UIFont fontWithName:@"ActionMan" size:22.0];
    totalPointsVotes.textColor = [UIColor colorWithRed:redUN/255.0 green:greenUN/255.0 blue:blueUN/255.0 alpha:1.0];
    totalPointsVotes.textAlignment = NSTextAlignmentCenter;
    totalPointsVotes.numberOfLines = 2;

    UILabel *totalFriendsNumber = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/4-50.0,
                                                                            lineDivider.frame.origin.y+35.0,
                                                                            100.0, 30.0)];
    totalFriendsNumber.text = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[_profileAccount.friendsList count]];
    totalFriendsNumber.font = [UIFont fontWithName:@"ActionMan" size:24.0];
    totalFriendsNumber.textColor = [UIColor colorWithRed:redUN/255.0 green:greenUN/255.0 blue:blueUN/255.0 alpha:1.0];
    totalFriendsNumber.textAlignment = NSTextAlignmentCenter;
    
    UILabel *totalPointsNumber = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth*0.75)-65.0,
                                                                               lineDivider.frame.origin.y+35.0,
                                                                               130.0, 30.0)];
    
    totalPointsNumber.text = [[NSString alloc] initWithFormat:@"%@", _profileAccount.totalPoints];
    totalPointsNumber.font = [UIFont fontWithName:@"ActionMan" size:24.0];
    totalPointsNumber.textColor = [UIColor colorWithRed:redUN/255.0 green:greenUN/255.0 blue:blueUN/255.0 alpha:1.0];
    totalPointsNumber.textAlignment = NSTextAlignmentCenter;
    
    /* Home Town Label */
    _homeTown = [[UILabel alloc] init];
    if (![_profileAccount.hometown isEqualToString:@""]) { // No Home Town
        _homeTown.text = _profileAccount.hometown;
    } else {
        _homeTown.hidden = true;
        
    }
    _homeTown.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
    _homeTown.font = [UIFont fontWithName:@"ActionMan" size:18.0];
    _homeTown.numberOfLines = 0; // 0 - means will take as many lines as needed
    _homeTown.preferredMaxLayoutWidth = screenWidth-35.0; // when to wrap words
    _homeTown.lineBreakMode = NSLineBreakByWordWrapping;
    
    // Leave room for house Icon, else there already is room fo icon
    CGFloat endOfNavBar = ([self.view viewWithTag:navBarViewTag].frame.origin.y + [self.view viewWithTag:navBarViewTag].frame.size.height);
    CGFloat statusBarSize = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    /* Set up and Load Profile Picture */
    CGRect frameLoadpic = CGRectMake(-2.0, endOfNavBar-statusBarSize, // x, y
                                     self.view.frame.size.width+4.0, // width
                                     ((totalFriends.frame.origin.y-45.0)-(endOfNavBar-statusBarSize))); // height
    _loadedProfile = [[UIImageView alloc] initWithFrame:frameLoadpic];
    _loadedProfile.contentMode = UIViewContentModeScaleAspectFill;
    _loadedProfile.clipsToBounds = true;
    _loadedProfile.layer.borderWidth = 1.0;
    _loadedProfile.layer.borderColor = [[UIColor blackColor] CGColor];
    
    [_scrollView addSubview:_loadedProfile];
    [_scrollView sendSubviewToBack:_loadedProfile];
    
    // No Profile picture label
    _noProfilePic = [[UILabel alloc] initWithFrame:CGRectMake(0.0, (endOfNavBar + _loadedProfile.frame.size.height/2-45.0),
                                                              screenWidth, 45.0)];
    _noProfilePic.textAlignment = NSTextAlignmentCenter;
    _noProfilePic.numberOfLines = 2;
    _noProfilePic.font = [UIFont fontWithName:@"ActionMan" size:15.0];
    
    /* Home Town / Profile House Icon */
    
    // Space left will never be negative because the homeTown wraps text
    // so the width will never be greater than the screenWidth!
    // spaceLeft/2 - will put the homeTown in the center of the space left
    CGFloat spaceLeft = screenWidth-_homeTown.intrinsicContentSize.width;
    _homeTown.frame = CGRectMake(spaceLeft/2, totalFriends.frame.origin.y-45.0, _homeTown.intrinsicContentSize.width, 40.0);

    UIImageView *locationIcon = [[UIImageView alloc] init];
    locationIcon.frame = CGRectMake(_homeTown.frame.origin.x-22.0, (_homeTown.frame.origin.y+8.0), 20.0, 20.0);
    locationIcon.image = [UIImage imageNamed:@"profileLocation.png"];
    if (_homeTown.hidden) {
        locationIcon.hidden = true;
    }
    
    /* Add Subviews */
    [_scrollView addSubview: _videoPage];
    [_scrollView addSubview: _noProfilePic];
    [_scrollView addSubview: _homeTown];
    [_scrollView addSubview: locationIcon];
    [_scrollView addSubview: _mapView];
    [_scrollView addSubview: placesJammed];
    [_scrollView addSubview: lineDivider];
    [_scrollView addSubview: totalFriends];
    [_scrollView addSubview: totalPointsVotes];
    [_scrollView addSubview: totalFriendsNumber];
    [_scrollView addSubview: totalPointsNumber];
    [_scrollView addSubview: bioText];
    [_scrollView addSubview: bioDescription];
    [_scrollView addSubview: statsText];
    [_scrollView addSubview: sessionAttendedLabel];
    [_scrollView addSubview: sessionAttendedNumber];
    [_scrollView addSubview: winsLabel];
    [_scrollView addSubview: winsNumber];
    [_scrollView addSubview: entryVotesLabel];
    [_scrollView addSubview: entryVotesNumber];

    /* Profile Videos */
    _videoPage.layer.cornerRadius = 3; // rounded edges
    _videoPage.clipsToBounds = YES;
    [_videoPage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; // color and boarder
    _videoPage.titleLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    [_videoPage addTarget:self
                            action:@selector(videoPage:)
                  forControlEvents:UIControlEventTouchUpInside];
    if ( [_profileAccount.featureVideoIDs count] == 0) {
        [_videoPage setTitle:@"No Videos!" forState:UIControlStateNormal];
        _videoPage.backgroundColor = [UIColor redColor];
        _videoPage.userInteractionEnabled = false;
    } else if ([_profileAccount.featureVideos count] == [_profileAccount.featureVideoIDs count]) {
        [_videoPage setTitle:@"View Videos" forState:UIControlStateNormal];
        _videoPage.backgroundColor = [UIColor greenColor];
        _videoPage.userInteractionEnabled = true;
    } else {
        [_videoPage setTitle:@"Loading Videos..." forState:UIControlStateNormal];
        _videoPage.backgroundColor = [UIColor grayColor];
        _videoPage.userInteractionEnabled = false;
    }
    
    /* Profile Picture */
    if (_profileAccount.accountPictureID.length) {
        
        _scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite; // set indicator color
        
        /* Only load if the profiles pic has not been set */
        if (_profileAccount.accountPicture == nil) {
            _noProfilePic.text = @"Loading Profile Picture...";
            [self loadImage:_profileAccount];
        } else {
            _loadedProfile.image = _profileAccount.accountPicture;
       
            [self.view sendSubviewToBack: _loadedProfile];
            
            /* Rid of label */
            _noProfilePic.hidden = true;
        }
    } else {
        _scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack; // set indicator color
        _noProfilePic.text = @"No Profile Picture";
        _loadedProfile.hidden = true;
    }
    
    /* Nav button set up */
    _leaveProfileButton = [[UIButton alloc] init];
    [_leaveProfileButton setBackgroundImage:[UIImage imageNamed:@"backX"] forState:UIControlStateNormal];
    [_leaveProfileButton addTarget:self
                            action:@selector(leaveProfile:)
                  forControlEvents:UIControlEventTouchUpInside];
    _leaveProfileButton.contentMode = UIViewContentModeScaleAspectFit;
    
    _addFriend = [[UIButton alloc] init];
    _addFriend.contentMode = UIViewContentModeScaleAspectFit;
    [_addFriend addTarget:self
                   action:@selector(addFriend:)
         forControlEvents:UIControlEventTouchUpInside];
    
    // Looking at your own profile? Things change
    _ownProfile = [_profileAccount.userName isEqualToString:_loggedInAccount.userName];
    
    if (!_ownProfile) {
        BOOL alreadyFriends = false;
        // Nav Bar right image
        // Check if already friends
        for (NSString *friend in _loggedInAccount.friendsList) {
            if ([friend isEqualToString:_profileAccount.userName]) {
                alreadyFriends = true;
                [_addFriend setBackgroundImage:[UIImage imageNamed:@"alreadyFriends"] forState:UIControlStateNormal];
                break;
            }
        }
        
        // If not already friends, make this the background
        if (!alreadyFriends) {
            [_addFriend setBackgroundImage:[UIImage imageNamed:@"addFriend"] forState:UIControlStateNormal];
        }
    } else {
        _addFriend = nil;
    }
    
    // Nav Bar set up
    [NavigationView showNavView:_profileAccount.userName leftButton:_leaveProfileButton rightButton:_addFriend view:self.view];

    
    
    /* Set background color */
    UIColor *bgColor = [UIColor colorWithRed:redLine/255.0 green:greenLine/255.0 blue:blueLine/255.0 alpha:1.0];
    
    UIView *bgColorView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _scrollView.contentSize.width, _scrollView.contentSize.height)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = bgColorView.bounds;
    gradient.colors = @[(id)[UIColor whiteColor].CGColor, (id)bgColor.CGColor];
    
    [bgColorView.layer insertSublayer:gradient atIndex:0];
    [self.view addSubview:bgColorView];
    [self.view sendSubviewToBack:bgColorView];
}

/* Add Friend to logged in account's friendsList && update DB */
- (IBAction)addFriend:(id)sender {
    BOOL okayFriend = true;
    
    /* Add a friend */
    for (NSString *friend in _loggedInAccount.friendsList) {
        if ([friend isEqualToString:_profileAccount.userName]) {
            okayFriend = false; // already has friend added to friendsList
            break;
        }
    }
    
    if (okayFriend) {
        [_loggedInAccount.friendsList insertObject:_profileAccount.userName atIndex:0];
        _addFriend.userInteractionEnabled = false;
        
        [AlertView showAlertTab:@"Added Friend!" view:self.view];
        
        [_addFriend setBackgroundImage:[UIImage imageNamed:@"alreadyFriends"] forState:UIControlStateNormal];
        
        /* Update account with new friend */
        [_loggedInAccount updateAccount:kBaseURL message:_profileAccount._accountid];
    } else {
        _addFriend.userInteractionEnabled = false;
        [AlertView showAlertTab:@"Already Friends..." view:self.view];
    }
}

-(void)showFriendsList {
    FriendListView *friendListView = [[FriendListView alloc] init];
    friendListView.loggedInAccount = _profileAccount;
    friendListView.ownProfile = _ownProfile;
    
    [self presentViewController:friendListView animated:true completion:nil];
}

-(IBAction)leaveProfile:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)videoPage:(id)sender {
    
    if ([_profileAccount.featureVideos count] == [_profileAccount.featureVideoIDs count]) {
        
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        ProfileVideosController *pc = [storyboard instantiateViewControllerWithIdentifier:@"ProfileVideosController"];
        
        pc.profileAccountFeatureVideos = _profileAccount.featureVideos;
        pc.profileAccountFeatureVideoIDs = _profileAccount.featureVideoIDs;
        pc.profileAccountFeatureVideoThumbnails = _profileAccount.featureVideoThumbnails;
        
        [self presentViewController:pc animated:true completion:nil];
    } else {
        SPAM(("\nVideos Not Loaded\n"));
    }

}

/*** DB Methods ***/

/* Gets IOS's temp dir*/
- (NSString *)documentsPathForFileName:(NSString *)name {
    NSString *documentsPath = NSTemporaryDirectory();
    return [documentsPath stringByAppendingPathComponent:name];
}

/* Load all videos and get thumbnails */
-(void)loadVideos {
    SPAM(("\nLoading Videos\n"));

    // RESET VIDEO ARRAY
    _profileAccount.featureVideos = [[NSMutableDictionary alloc] initWithCapacity:4];
    _profileAccount.featureVideoThumbnails = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    for (NSString* _id in _profileAccount.featureVideoIDs) {
        /* Full path of collection and entity */
        NSString *collectionAndEntity = [NSString stringWithFormat:@"%@/%@", kAccountVideos, _id];
        NSString *locations = [kBaseURL stringByAppendingPathComponent:collectionAndEntity];
        
        NSString * encodedString = [locations stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        
        NSURL* url = [NSURL URLWithString:encodedString];
        
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"GET";
        [request addValue:@"video/mp4" forHTTPHeaderField:@"Content-Type"];
        // Set Up Auth
        [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:_loggedInAccount._accountid];
        
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
        
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            
            if (error == nil && [httpResponse statusCode] == 200 && data != nil) {
                
                NSString *videoName = [[NSString alloc] initWithFormat:@"%@.mp4", _id];
                NSString *filePath = [self documentsPathForFileName:videoName];
                [data writeToFile:filePath atomically:YES];
                NSURL *videoFileURL =  [NSURL fileURLWithPath:filePath];
                
                NSNumber *idIndex = [NSNumber numberWithInteger:[_profileAccount.featureVideoIDs indexOfObject:_id]];
                
                if (videoFileURL != nil  && [[videoFileURL absoluteString] length] != 0) {
                    [_profileAccount.featureVideos setObject:videoFileURL forKey:idIndex];
                }
                
                // Create thumbnail
                AVAsset *asset = [AVAsset assetWithURL:videoFileURL];
                AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
                CMTime thumbnailTime = [asset duration];
                thumbnailTime.value = 0;
                CGImageRef imgRef = [imageGenerator copyCGImageAtTime:thumbnailTime actualTime:NULL error:nil];
                UIImage *i = [[UIImage alloc] initWithCGImage:imgRef scale:UIViewContentModeScaleAspectFit orientation:UIImageOrientationUp];
                
                if (i != nil) {
                    [_profileAccount.featureVideoThumbnails setObject:i forKey:idIndex];
                }
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        /* Update UI in main thread */
                        if ([_profileAccount.featureVideos count] == [_profileAccount.featureVideoIDs count]) {
                            [_videoPage setTitle:@"View Videos" forState:UIControlStateNormal];
                            _videoPage.backgroundColor = [UIColor greenColor];
                            _videoPage.userInteractionEnabled = true;
                        }
                    });
                });
                
            } else {
                NSLog(@"Error loading profile videos: %@\n", [error localizedDescription]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [AlertView showAlertTab:@"Could not load videos at the moment" view:self.view];
                    [_videoPage setTitle:@"Could not load videos" forState:UIControlStateNormal];
                });
            }
        }];
        
        [dataTask resume]; //8
        
    } // end for loop
}


/* Load profile picture */
-(void)loadImage:(Account *)profileAccount {
    SPAM(("\nLoad profile picture\n"));
    
    NSURL* url = [NSURL URLWithString:[[kBaseURL stringByAppendingPathComponent:kAccountPictures] stringByAppendingPathComponent:profileAccount.accountPictureID]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    // Set Up Auth
    [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:_loggedInAccount._accountid];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([httpResponse statusCode] == 404 || data == nil) {
                        _noProfilePic.text = @"Could not load profile picture :(";
                        [AlertView showAlertTab:@"Could not load profile picture at the moment" view:self.view];
                    } else {
                        SPAM(("Succussfully getting profile picture\n"));
                        
                        NSData* imageData = data;
                        
                        /* Update UI in main thread */
                
                        /* Save profile accounts picture */
                        _profileAccount.accountPicture = [UIImage imageWithData:imageData];
                
                        _loadedProfile.image = [UIImage imageWithData:imageData];
                
                        /* Rid of label */
                        _noProfilePic.hidden = true;
                
                        [self.view sendSubviewToBack: _loadedProfile];
                    }
                });
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [AlertView showAlertTab:@"Could not load profile picture at the moment" view:self.view];
                _noProfilePic.text = @"Could not load profile picture :(";
            });
        }
    }];
    
    [task resume]; 
}

/* Parses placesIveJammed Array and creates Markers on map */
-(void)placeMarkers:(CGFloat)mapStart screenWidth:(CGFloat)screenWidth {
    SPAM(("\nPlacing Markers\n"));
    
    GMSCameraPosition *camera;
    int count = 0;
    
    camera = [GMSCameraPosition cameraWithLatitude:41.1491
                                         longitude:-73.705
                                              zoom:4];
    
    CGRect bounds = CGRectMake(0.0, mapStart,
                               screenWidth,
                               _scrollView.contentSize.height-mapStart);
    _mapView = [GMSMapView mapWithFrame:bounds camera:camera];
    [_mapView setMinZoom:2 maxZoom:17]; // set min/max zoom
    _mapView.myLocationEnabled = YES;
    _mapView.delegate = self;
    
    for (NSString *placeStr in _profileAccount.placesIveJammed) {
        NSArray *tmp = [placeStr componentsSeparatedByString: @","];
        NSString* city = [tmp objectAtIndex: 0];
        NSString* country = [tmp objectAtIndex: 1];
        NSString* latitude = [tmp objectAtIndex: 2];
        NSString* longitude = [tmp objectAtIndex: 3];
    
        if (count == 0) { // set camera to first coord
            _mapView.camera = [GMSCameraPosition cameraWithLatitude:[latitude doubleValue]
                                                 longitude:[longitude doubleValue]
                                                      zoom:3];
            
            count += 1;
        }
        
        NSString *title;
        if ([country length] == 0 && [city length] == 0) {
            title = @"";
        } else if ([city length] == 0) {
            title = [[NSString alloc] initWithFormat:@"%s", [country UTF8String]];
        } else if ([country length] == 0) {
            title = [[NSString alloc] initWithFormat:@"%s", [city UTF8String]];
        } else {
            title = [[NSString alloc] initWithFormat:@"%s, %s", [city UTF8String], [country UTF8String]];
        }
        
        // 1. Create Marker object & load its userData
        GMSMarker *tmpMarker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(
                                                                                        [latitude doubleValue], [longitude doubleValue])];
        // Set Title to (City, Country)
        tmpMarker.title = title;
        
        // Set Color
        tmpMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
        
        // Set map
        tmpMarker.map  = _mapView;
        
    } // end for
}


/* SEGUE CODE */
// Pass in info to next page
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    /* Open world map of markers */
//    if ([[segue identifier] isEqualToString:@"embeddedSegue"]) {
//
//    }
}



@end
