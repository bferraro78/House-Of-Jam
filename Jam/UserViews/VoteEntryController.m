//
//  VoteEntryController.m
//  Jam
//
//  Created by Ben Ferraro on 9/6/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoteEntryController.h"

/* Amount of videos that should be pre loaded */
#define amountOfPreLoadedVideos 3

@implementation VoteEntryController

static NSString* const kEntryVideos = @"entryVideos";

NSInteger const videoLineViewTag = 100;
NSInteger const videoLineOneViewTag = 101;
NSInteger const videoLineTwoViewTag = 102;
NSInteger const videoLineThreeViewTag = 103;
NSInteger const screenBackgroundTag = 104;

-(void)viewDidLoad {
    [super viewDidLoad];
    SPAM(("Vote Controller\n"));

    /** Set Frames **/
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    // Buttons
    _backButton = [[UIButton alloc] init];
    [_backButton addTarget:self
                              action:@selector(backButton:)
                    forControlEvents:UIControlEventTouchUpInside];
    [_backButton setBackgroundImage:[UIImage imageNamed:@"backX"] forState:UIControlStateNormal];
    
    _voteVideoButton = [[UIButton alloc] init];
    [_voteVideoButton addTarget:self
                              action:@selector(voteVideoOne:)
                    forControlEvents:UIControlEventTouchUpInside];
    [_voteVideoButton setBackgroundImage:[UIImage imageNamed:@"voteIcon.png"] forState:UIControlStateNormal];
    
    // Nav Bar
    [NavigationView showNavView:@"Weekly Entries" leftButton:_backButton rightButton:_voteVideoButton view:self.view];
    
    
    // Video screen
    float videoScreenHeight = self.view.frame.size.height/1.5;
    CGFloat endOfNavBar = ([self.view viewWithTag:navBarViewTag].frame.origin.y + [self.view viewWithTag:navBarViewTag].frame.size.height);
    
    _videoScreen = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, endOfNavBar+1,
                                                                 self.view.frame.size.width,
                                                                 videoScreenHeight)];
    _videoScreen.backgroundColor = [UIColor clearColor];
    _videoScreen.contentMode = UIViewContentModeScaleAspectFill;
    _videoScreen.clipsToBounds = true;
    
    UIImageView *screenBG = [[UIImageView alloc] initWithFrame:CGRectMake(_videoScreen.frame.origin.x,
                                                                          _videoScreen.frame.origin.y,
                                                                          _videoScreen.frame.size.width,
                                                                          _videoScreen.frame.size.height)];
    screenBG.image = [UIImage imageNamed:@"parchment"]; 
    screenBG.contentMode = UIViewContentModeScaleAspectFill;
    screenBG.clipsToBounds = YES;
    screenBG.alpha = 0.8;
    screenBG.tag = screenBackgroundTag;
    
    // Line Picker
    UIView *videoNumberLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, (_videoScreen.frame.origin.y+videoScreenHeight+2.0),
                                                                       self.view.frame.size.width,
                                                                       8.0)];
    videoNumberLine.backgroundColor = [UIColor darkGrayColor];
    videoNumberLine.alpha = 0.5;
    videoNumberLine.tag = videoLineViewTag;
    
    float thirdOfScreen = self.view.frame.size.width/3;
    
    UIView *videoNumberLineOne = [[UIView alloc] initWithFrame:CGRectMake(0.0, (_videoScreen.frame.origin.y+videoScreenHeight+2.0),
                                                                          thirdOfScreen,
                                                                          8.0)];
    videoNumberLineOne.backgroundColor = [UIColor whiteColor];
    videoNumberLineOne.alpha = 0.7;
    videoNumberLineOne.tag = videoLineOneViewTag;
    
    UIView *videoNumberLineTwo = [[UIView alloc] initWithFrame:CGRectMake(thirdOfScreen+10.0,
                                                                          (_videoScreen.frame.origin.y+videoScreenHeight+2.0),
                                                                          thirdOfScreen,
                                                                          8.0)];
    videoNumberLineTwo.backgroundColor = [UIColor whiteColor];
    videoNumberLineTwo.alpha = 0.7;
    videoNumberLineTwo.tag = videoLineTwoViewTag;
    
    UIView *videoNumberLineThree = [[UIView alloc] initWithFrame:CGRectMake((thirdOfScreen*2)+10.0,
                                                                            (_videoScreen.frame.origin.y+videoScreenHeight+2.0),
                                                                            thirdOfScreen,
                                                                            8.0)];
    videoNumberLineThree.backgroundColor = [UIColor whiteColor];
    videoNumberLineThree.alpha = 0.8;
    videoNumberLineThree.tag = videoLineThreeViewTag;
    
    // Username
    _userName = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                          _videoScreen.frame.size.height-90.0,
                                                          self.view.frame.size.width, 40.0)];
    _userName.font = [UIFont fontWithName:@"Avenir-Black" size:26.0];
    _userName.textColor = [UIColor whiteColor];
    _userName.textAlignment = NSTextAlignmentLeft;

    _homeTown = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                          _videoScreen.frame.size.height-55.0,
                                                          self.view.frame.size.width, 40.0)];
    _homeTown.font = [UIFont fontWithName:@"Avenir" size:24.0];
    _homeTown.textColor = [UIColor whiteColor];
    _homeTown.textAlignment = NSTextAlignmentLeft;
    
    [_videoScreen addSubview:_userName];
    [_videoScreen addSubview:_homeTown];
    
    // Descriptipn Button
    _descriptionButton = [[UIButton alloc] init];
    _descriptionButton.frame = CGRectMake(self.view.frame.size.width-55.0,
                                          videoNumberLine.frame.origin.y+15.0, 50.0, 50.0);
    [_descriptionButton setImage:[UIImage imageNamed:@"acendArrow"] forState:UIControlStateNormal];
    [_descriptionButton addTarget:self
                      action:@selector(extendDescription)
            forControlEvents:UIControlEventTouchUpInside];
    
    // Description Label
    _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, videoNumberLine.frame.origin.y+15.0,
                                                                          screenWidth-20.0, 40.0)];
    _descriptionLabel.text = @"Description:";
    _descriptionLabel.font = [UIFont fontWithName:@"ActionMan" size:23.0];
    _descriptionLabel.textAlignment = NSTextAlignmentLeft;
    
    CGFloat entryDescriptionHeight = screenHeight-(_descriptionLabel.frame.origin.y+40.0);
    _entryDescription = [[UITextView alloc] initWithFrame:CGRectMake(10.0, _descriptionLabel.frame.origin.y+40.0,
                                                                                screenWidth-20.0,
                                                                                entryDescriptionHeight)];
    _entryDescription.editable = false;
    _entryDescription.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    
    // Play Button
    _playButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playButton"]];
    _playButton.frame = CGRectMake(self.view.frame.size.width/2-50.0,
                                  _videoScreen.frame.size.height/2+40.0, // 65.0 = height of nav bar
                                  100.0, 50.0);
    _playButton.contentMode = UIViewContentModeScaleAspectFit;
    _playButton.layer.zPosition = MAXFLOAT;
    
    [self.view addSubview:_videoScreen];
    [self.view insertSubview:screenBG belowSubview:_videoScreen];
    [self.view addSubview:_descriptionLabel];
    [self.view addSubview:_entryDescription];
    [self.view addSubview:_descriptionButton];
    [self.view addSubview:_playButton];
    [self.view bringSubviewToFront:_playButton];
    
    [self.view addSubview:videoNumberLine];
    [self.view addSubview:videoNumberLineOne];
    [self.view addSubview:videoNumberLineTwo]; videoNumberLineTwo.hidden = true;
    [self.view addSubview:videoNumberLineThree]; videoNumberLineThree.hidden = true;
    
    _playButton.hidden = true;
    
    /** Gesture Reconizers for Video **/
    // tap to enlarge, tap to play video, double tap to rotate
    UITapGestureRecognizer *tapGesturePlayVideo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVideo)];
    tapGesturePlayVideo.delegate = self;
    tapGesturePlayVideo.numberOfTapsRequired = 1;
    
    UITapGestureRecognizer *rotate = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rotate)];
    rotate.delegate = self;
    rotate.numberOfTapsRequired = 2;
    [tapGesturePlayVideo requireGestureRecognizerToFail:rotate];
    
    UISwipeGestureRecognizer *leftSwipe=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightVideo)];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    UISwipeGestureRecognizer *rightSwipe=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftVideo)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];

    [_videoScreen addGestureRecognizer:tapGesturePlayVideo];
    [_videoScreen addGestureRecognizer:rotate];
    [_videoScreen addGestureRecognizer:leftSwipe];
    [_videoScreen addGestureRecognizer:rightSwipe];
    
    /* Init arrays / dictionaries */
    _loadedEntriesList = [[NSMutableArray alloc] init];
    _loadedEntryThumbnailsList = [[NSMutableArray alloc] init];
    _loadedEntriesBufferMap = [[NSMutableDictionary alloc] init];
    _loadedEntryThumbnailsBufferMap = [[NSMutableDictionary alloc] init];
    _videoGroupBufferStatusMap = [[NSMutableDictionary alloc] init];
    _orderOfEntriesList = [[NSMutableArray alloc] init];
    _screenMode = [NSMutableString stringWithString:@"full"];
    
    /* Load initial boolean values */
    _errorLoadingInToBuffer = false;
    _videosToLoad = false; // starts off false, only goes to true if there are videos to load
    _bufferLoaded = true; // based on when user taps the vote button, if the buffer has been loaded
    // REMAINS TRUE ALL the TIME UNLESS THE USER HAS PRESSED THE VOTE BUTTON AND THE NEXT SET OF VIDEOS HAS NOT BEEN LOADED
    
    /* Disable button pressing */
    _videoScreen.userInteractionEnabled = false;
    _voteVideoButton.userInteractionEnabled = false;
    
    /* Initalize video  index markers*/
    _currentGroupNumber = [NSNumber numberWithInt:0]; // start at group number 0
    _currentVideoInGroup = 0; // start from first video
    _currentVideo = 0; // start at first video
    
    /* Set inital dailyVote number from account */
    int dailyVoteNumber = [_mainAccount.dailyVoteNumber intValue];
    
    [SVProgressHUD dismiss]; // dismiss loading entries
    
    /* First time load videos */
    [self loadVideosBufferdailyVoteNumber:dailyVoteNumber firstLoad:true callback:^(NSError *error, BOOL success, NSNumber *currGroupNumber) {
        
        [SVProgressHUD dismiss];
        
        [AlertView showAlertTab:@"Swipe to see the submitted entries!" view:self.view];
        
        /* Load correct videos from buffer */
        for (int i = 0; i < 3; i++) {
            NSString *videoID = [_orderOfEntriesList objectAtIndex:_currentVideo+i];
            SPAM(("ID: %s\n",[videoID UTF8String]));
            [_loadedEntriesList insertObject:_loadedEntriesBufferMap[videoID] atIndex:i];
            [_loadedEntryThumbnailsList insertObject:_loadedEntryThumbnailsBufferMap[videoID] atIndex:i];
        }
        
        // hide play button or not
        NSString *fileNameString = ((NSURL*)[_loadedEntriesList objectAtIndex:_currentVideoInGroup]).absoluteString;
        if ([fileNameString rangeOfString:@".mp4"].location == NSNotFound) {
            _playButton.hidden = true;
            _isVideo = false;
        } else {
            _playButton.hidden = false;
            _isVideo = true;
        }
        
        /* Load Thumbnails into UI */
        _videoScreen.image = [_loadedEntryThumbnailsList objectAtIndex:_currentVideoInGroup];
        
        _videoScreen.userInteractionEnabled = true;
        _voteVideoButton.userInteractionEnabled = true;
        
        int dailyVoteNumber = [_mainAccount.dailyVoteNumber intValue];
        VideoEntry *entry = [_Entries objectAtIndex:dailyVoteNumber+_currentVideoInGroup];
        _userName.text = [NSString stringWithFormat:@"%@", entry.username];
        _homeTown.text = [NSString stringWithFormat:@"%@", entry.hometown];
        _entryDescription.text = entry.entryDescription;
        
        /* Buffer next three videos!, if there are some to load */
        if (dailyVoteNumber + 6 <= [_Entries count]) {
            
            _videosToLoad = true;
            
            /* Auto load first buffer after first 3 inital videos are loaded */
            [self loadVideosBufferdailyVoteNumber:dailyVoteNumber+3 firstLoad:false callback:^(NSError *error, BOOL success, NSNumber *currGroupNumber) {
                
                if (!_bufferLoaded) { /* Load UI if user has been waiting on buffered videos to load */
                    
                    /* Error in loading into buffer, aka next 3 videos is not full */
                    if (_errorLoadingInToBuffer) {
                        // call delegate method
                        id<VotingDelegate> strongDelegate = self.delegate;
                        if ([strongDelegate respondsToSelector:@selector(returnToMainViewNoVideos:)]) {
                            [strongDelegate returnToMainViewNoVideos:@"2"]; // called from main view
                        }
                    }
                    
                    /* We are on correct video group */
                    if ([currGroupNumber intValue]*3 == _currentVideo+3) {
                        
                        /* Since the next three videos are loading into the buffer,
                         Get their video id's*/
                        _currentVideo += 3;
                        
                        [SVProgressHUD dismiss]; // dismiss HUD
                        
                        [self.view viewWithTag:videoLineOneViewTag].hidden = false;
                        [self.view viewWithTag:videoLineTwoViewTag].hidden = true;
                        [self.view viewWithTag:videoLineThreeViewTag].hidden = true;
                        
                        _currentVideoInGroup = 0;
                        
                        /* Load correct videos from buffer */
                        for (int i = 0; i < 3; i++) {
                            NSString *videoID = [_orderOfEntriesList objectAtIndex:_currentVideo+i];
                            SPAM(("ID: %s\n",[videoID UTF8String]));
                            [_loadedEntriesList insertObject:_loadedEntriesBufferMap[videoID] atIndex:i];
                            [_loadedEntryThumbnailsList insertObject:_loadedEntryThumbnailsBufferMap[videoID] atIndex:i];
                        }
                        
                        // hide play button or not
                        NSString *fileNameString = ((NSURL*)[_loadedEntriesList objectAtIndex:_currentVideoInGroup]).absoluteString;
                        if ([fileNameString rangeOfString:@".mp4"].location == NSNotFound) {
                            _playButton.hidden = true;
                            _isVideo = false;
                        } else {
                            _playButton.hidden = false;
                            _isVideo = true;
                        }
                        
                        /* Load Thumbnails into UI */
                        _videoScreen.image = [_loadedEntryThumbnailsList objectAtIndex:_currentVideoInGroup];
                        
                        int dailyVoteNumber = [_mainAccount.dailyVoteNumber intValue];
                        VideoEntry *entry = [_Entries objectAtIndex:dailyVoteNumber+_currentVideoInGroup];
                        _userName.text = [NSString stringWithFormat:@"%@", entry.username];
                        _homeTown.text = [NSString stringWithFormat:@"%@", entry.hometown];
                        _entryDescription.text = entry.entryDescription;
                        
                        /* Allow Button pressing again */
                        _videoScreen.userInteractionEnabled = true;
                        _voteVideoButton.userInteractionEnabled = true;
                        
                        _bufferLoaded = true;
                    }
                }
            }];
        } else {
            _videosToLoad = false;
        }
       
    }]; // end loadVideosdailyVoteNumber:
    
}

/* Handles the voting of an entry */
- (IBAction)voteVideoOne:(id)sender {
    
    /* Loading alert box */
    UIAlertController *alertControllerVote = [UIAlertController
                                              alertControllerWithTitle:@"Vote for this entry?"
                                              message:nil
                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) { /* Do nothing */ }];
    
    UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           
           /* Disable button pressing */
           _videoScreen.userInteractionEnabled = false;
           _voteVideoButton.userInteractionEnabled = false;
           
           /* Voted for this video, update that entry */
           int dailyVoteNumber = [_mainAccount.dailyVoteNumber intValue];
           VideoEntry *winningEntry = [_Entries objectAtIndex:dailyVoteNumber+_currentVideoInGroup];
           
           // Update in DB -- HANDLES UPDATING THE POSTER'S ACCOUNT totalVideoVote ON SERVER
           // - Increments the loggedIn user's daily counter  by 3
           // - Increments votes of onlineEntry object by 1
           [winningEntry updateEntry:kBaseURL mainUser:_mainAccount.userName entryPoster:winningEntry.username message:_mainAccount._accountid];
           
           if (!_videosToLoad) {
               
               // NO VIDEOS TO SHOW, call delegate to dismiss
               // Local object daily vote number increased by 3 in ViewController delegate
               id<VotingDelegate> strongDelegate = self.delegate;
               if ([strongDelegate respondsToSelector:@selector(returnToMainViewNoVideos:)]) {
                   [strongDelegate returnToMainViewNoVideos:@"1"]; // called from main view
               }
               
           } else if (_errorLoadingInToBuffer) { // error in loading into buffer, aka a video failed to load
               // call delegate method
               id<VotingDelegate> strongDelegate = self.delegate;
               if ([strongDelegate respondsToSelector:@selector(returnToMainViewNoVideos:)]) {
                   [strongDelegate returnToMainViewNoVideos:@"2"]; // called from main view
               }
               
           } else {
               
               /* Advance daily counter */
               _mainAccount.dailyVoteNumber = [NSNumber numberWithInt:dailyVoteNumber + 3];
               
               NSNumber *grpNum = [NSNumber numberWithInt:(_currentVideo+3)/3]; // check if next group of vids has loaded yet
               
               if ([_videoGroupBufferStatusMap[grpNum] isEqualToString:@"1"]) { // buffer has not loaded yet, load shit in callback method
                   
                   _bufferLoaded = false;
                   // progress circle
                   [SVProgressHUD showWithStatus:@"Loading Videos..."];
                   
               } else {
                   
                   _currentVideo += 3;
                   
                   [self.view viewWithTag:videoLineOneViewTag].hidden = false;
                   [self.view viewWithTag:videoLineTwoViewTag].hidden = true;
                   [self.view viewWithTag:videoLineThreeViewTag].hidden = true;
                   
                   _currentVideoInGroup = 0;
                   
                   /* Load correct videos from buffer */
                   for (int i = 0; i < 3; i++) {
                       NSString *videoID = [_orderOfEntriesList objectAtIndex:_currentVideo+i];
                       SPAM(("ID: %s\n",[videoID UTF8String]));
                       [_loadedEntriesList insertObject:_loadedEntriesBufferMap[videoID] atIndex:i];
                       [_loadedEntryThumbnailsList insertObject:_loadedEntryThumbnailsBufferMap[videoID] atIndex:i];
                   }
                   
                   // hide play button or not
                   NSString *fileNameString = ((NSURL*)[_loadedEntriesList objectAtIndex:_currentVideoInGroup]).absoluteString;
                   if ([fileNameString rangeOfString:@".mp4"].location == NSNotFound) {
                       _playButton.hidden = true;
                       _isVideo = false;
                   } else {
                       _playButton.hidden = false;
                       _isVideo = true;
                   }
                   
                   /* Reset the video screen */
                   _videoScreen.image = [_loadedEntryThumbnailsList objectAtIndex:_currentVideoInGroup];
                   
                   int dailyVoteNumber = [_mainAccount.dailyVoteNumber intValue];
                   VideoEntry *entry = [_Entries objectAtIndex:dailyVoteNumber+_currentVideoInGroup];
                   _userName.text = [NSString stringWithFormat:@"%@", entry.username];
                   _homeTown.text = [NSString stringWithFormat:@"%@", entry.hometown];
                   _entryDescription.text = entry.entryDescription;
                   
                   /* Allow Button pressing again */
                   _videoScreen.userInteractionEnabled = true;
                   _voteVideoButton.userInteractionEnabled = true;
                   
                   _bufferLoaded = true;
               }
               
               
               /** Check further in advance, for loop to call loadVideosBufferdailyVoteNumber multiple times --
                if we want to load more than 1 video group ahead at a time   **/
               
               /* Buffer next three videos!, if there are some to load */
               dailyVoteNumber = [_mainAccount.dailyVoteNumber intValue];
               if (dailyVoteNumber + 6 <= [_Entries count]) {
                   
                   _videosToLoad = true;
                   
                   /* Begin loading next buffer*/
                   [self loadVideosBufferdailyVoteNumber:dailyVoteNumber+3 firstLoad:false callback:^(NSError *error, BOOL success, NSNumber *currGroupNumber) {
                       
                       /* Load UI if user has been waiting on buffered videos to load -- user is ready for next set of loaded buffer videos */
                       if (!_bufferLoaded) {
                           
                           /* Error in loading into buffer, aka next 3 videos is not full */
                           if (_errorLoadingInToBuffer) {
                               // call delegate method
                               id<VotingDelegate> strongDelegate = self.delegate;
                               if ([strongDelegate respondsToSelector:@selector(returnToMainViewNoVideos:)]) {
                                   [strongDelegate returnToMainViewNoVideos:@"2"]; // called from main view
                               }
                               
                           }
                           
                           /* We are on correct video group, if a group of three videos loads before the current group.
                            We will wait until the current 3 group of videos is done. */
                           if ([currGroupNumber intValue]*3 == _currentVideo+3) {
                               
                               _currentVideo += 3;
                               
                               [SVProgressHUD dismiss];
                               
                               [self.view viewWithTag:videoLineOneViewTag].hidden = false;
                               [self.view viewWithTag:videoLineTwoViewTag].hidden = true;
                               [self.view viewWithTag:videoLineThreeViewTag].hidden = true;
                               
                               _currentVideoInGroup = 0;
                               
                               /* Load correct videos from buffer */
                               for (int i = 0; i < 3; i++) {
                                   NSString *videoID = [_orderOfEntriesList objectAtIndex:_currentVideo+i];
                                   SPAM(("ID: %s\n",[videoID UTF8String]));
                                   [_loadedEntriesList insertObject:_loadedEntriesBufferMap[videoID] atIndex:i];
                                   [_loadedEntryThumbnailsList insertObject:_loadedEntryThumbnailsBufferMap[videoID] atIndex:i];
                               }
                               
                               // hide play button or not
                               NSString *fileNameString = ((NSURL*)[_loadedEntriesList objectAtIndex:_currentVideoInGroup]).absoluteString;
                               if ([fileNameString rangeOfString:@".mp4"].location == NSNotFound) {
                                   _playButton.hidden = true;
                                   _isVideo = false;
                               } else {
                                   _playButton.hidden = false;
                                   _isVideo = true;
                               }
                               
                               /* Reset the video screen */
                               _videoScreen.image = [_loadedEntryThumbnailsList objectAtIndex:_currentVideoInGroup];
                               
                               int dailyVoteNumber = [_mainAccount.dailyVoteNumber intValue];
                               VideoEntry *entry = [_Entries objectAtIndex:dailyVoteNumber+_currentVideoInGroup];
                               _userName.text = [NSString stringWithFormat:@"%@", entry.username];
                               _homeTown.text = [NSString stringWithFormat:@"%@", entry.hometown];
                               _entryDescription.text = entry.entryDescription;
                               
                               /* Allow Button pressing again */
                               _videoScreen.userInteractionEnabled = true;
                               _voteVideoButton.userInteractionEnabled = true;
                               
                               _bufferLoaded = true;
                           }
                       }
                   }];
                   
               } else {
                   _videosToLoad = false;
               }
               
           }
           
       }]; // end OKAY action for alert controller
    
    [alertControllerVote addAction:okayAction];
    [alertControllerVote addAction:cancelAction];
    [self presentViewController:alertControllerVote animated:YES completion:nil];
}


/* Entry Description Extent/Contract */
-(void)extendDescription {
    
    float videoScreenHeight;
    if ([_screenMode isEqualToString:@"full"]) {
        _screenMode = [NSMutableString stringWithString:@"short"];
        [_descriptionButton setImage:[UIImage imageNamed:@"descArrow"] forState:UIControlStateNormal];
        videoScreenHeight = self.view.frame.size.height/2.5;
        _userName.hidden = true;
        _homeTown.hidden = true;
    } else {
        _screenMode = [NSMutableString stringWithString:@"full"];
        [_descriptionButton setImage:[UIImage imageNamed:@"acendArrow"] forState:UIControlStateNormal];
        videoScreenHeight = self.view.frame.size.height/1.5;
        _userName.hidden = false;
        _homeTown.hidden = false;
    }
    
    CGFloat endOfNavBar = ([self.view viewWithTag:navBarViewTag].frame.origin.y + [self.view viewWithTag:navBarViewTag].frame.size.height);
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         _videoScreen.frame = CGRectMake(0.0, endOfNavBar+1, self.view.frame.size.width, videoScreenHeight);
                         // Update all views
                         [self updateViews:videoScreenHeight];
                     }
                     completion:^(BOOL finished) { }];
}

/* Update views based on new height of video screen */
-(void)updateViews:(float)videoScreenHeight {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    _playButton.frame = CGRectMake(self.view.frame.size.width/2-50.0,
                                   _videoScreen.frame.size.height/2+40.0, // 65.0 = height of nav bar
                                   100.0, 50.0);
    
    [self.view viewWithTag:screenBackgroundTag].frame = CGRectMake(_videoScreen.frame.origin.x, // screen BG
                                                   _videoScreen.frame.origin.y,
                                                   _videoScreen.frame.size.width,
                                                   _videoScreen.frame.size.height);
    
    [self.view viewWithTag:videoLineViewTag].frame = CGRectMake(0.0, (_videoScreen.frame.origin.y+videoScreenHeight+2.0),
                                                                       self.view.frame.size.width,
                                                                       8.0);
    
    float thirdOfScreen = self.view.frame.size.width/3;
    
    [self.view viewWithTag:videoLineOneViewTag].frame = CGRectMake(0.0, (_videoScreen.frame.origin.y+videoScreenHeight+2.0),
                                                                          thirdOfScreen,
                                                                          8.0);
    
    [self.view viewWithTag:videoLineTwoViewTag].frame = CGRectMake(thirdOfScreen+10.0, (_videoScreen.frame.origin.y+videoScreenHeight+2.0),
                                                                          thirdOfScreen,
                                                                          8.0);

    [self.view viewWithTag:videoLineThreeViewTag].frame = CGRectMake((thirdOfScreen*2)+10.0, (_videoScreen.frame.origin.y+videoScreenHeight+2.0),
                                                                            thirdOfScreen,
                                                                            8.0);
    
    _descriptionLabel.frame = CGRectMake(10.0, [self.view viewWithTag:videoLineViewTag].frame.origin.y+15.0,
                                                                  screenWidth-20.0, 40.0);
    
    _descriptionButton.frame = CGRectMake(self.view.frame.size.width-55.0,
                                          [self.view viewWithTag:videoLineViewTag].frame.origin.y+15.0, 45.0, 45.0);
    
    CGFloat entryDescriptionHeight = screenHeight-(_descriptionLabel.frame.origin.y+40.0);
    _entryDescription.frame = CGRectMake(10.0, _descriptionLabel.frame.origin.y+40.0,
                                                                     screenWidth-20.0,
                                                                     entryDescriptionHeight);
}



// Call delegate method with tag 3
-(IBAction)backButton:(id)sender {
    id<VotingDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(returnToMainViewNoVideos:)]) {
        [strongDelegate returnToMainViewNoVideos:@"3"]; // called from main view
    }

}

-(void)rotate {
    if (!_isVideo) {
        UIImage *i = _videoScreen.image;
        _videoScreen.image = [self rotateUIImage:i clockwise:true];
    }
}

// Rotate helper method
- (UIImage*)rotateUIImage:(UIImage*)sourceImage clockwise:(BOOL)clockwise {
    CGSize size = sourceImage.size;
    UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
    [[UIImage imageWithCGImage:[sourceImage CGImage] scale:1.0 orientation:clockwise ? UIImageOrientationRight : UIImageOrientationLeft] drawInRect:CGRectMake(0,0,size.height ,size.width)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

/* Plays Video or Enlarges picture */
-(void)playVideo {
    if (_isVideo) {
        NSURL *videoURL = [_loadedEntriesList objectAtIndex:_currentVideoInGroup];
        
        AVPlayer *player = [AVPlayer playerWithURL:videoURL];
        
        if (player != nil) {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [player seekToTime:kCMTimeZero];
            AVPlayerViewController *playerViewController = [AVPlayerViewController new];
            playerViewController.player = player;
            
            [self presentViewController:playerViewController animated:YES completion:^{
                [player play];
            }];
        }
    } else { // image
        
        if (_isFullScreen) {
            [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
                [self.view viewWithTag:navBarViewTag].hidden = false; // nav bar
                _userName.hidden = false;
                _homeTown.hidden = false;
                _videoScreen.backgroundColor = [UIColor clearColor];
                _videoScreen.frame = _oldFrame;
                _videoScreen.layer.cornerRadius = 10;
            } completion:^(BOOL finished) {
                _isFullScreen = false;
                _videoScreen.contentMode = UIViewContentModeScaleAspectFill;
            }];
            
        } else { // not full screen
            _oldFrame = _videoScreen.frame;
            
            _videoScreen.contentMode = UIViewContentModeScaleAspectFill;
            
            [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
                [self.view viewWithTag:navBarViewTag].hidden = true; // nav bar
                [self.view bringSubviewToFront:_videoScreen];
                _userName.hidden = true;
                _homeTown.hidden = true;
                _videoScreen.backgroundColor = [UIColor blackColor];
                _videoScreen.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
                _videoScreen.layer.cornerRadius = 0;
            } completion:^(BOOL finished) {
                _isFullScreen = true;
            }];
            
        }
    }
}

/* Swipe Functions */
-(void)leftVideo {
    if (_currentVideoInGroup == 0) {
        
    } else {
        _currentVideoInGroup -= 1;
        _videoScreen.image = [_loadedEntryThumbnailsList objectAtIndex:_currentVideoInGroup];
        
        int dailyVoteNumber = [_mainAccount.dailyVoteNumber intValue];
        VideoEntry *entry = [_Entries objectAtIndex:dailyVoteNumber+_currentVideoInGroup];
        _userName.text = [NSString stringWithFormat:@"%@", entry.username];
        _homeTown.text = [NSString stringWithFormat:@"%@", entry.hometown];
        _entryDescription.text = entry.entryDescription;
        
        // hide play button or not
        NSString *fileNameString = ((NSURL*)[_loadedEntriesList objectAtIndex:_currentVideoInGroup]).absoluteString;
        if ([fileNameString rangeOfString:@".mp4"].location == NSNotFound) { // photo
            _playButton.hidden = true;
            _isVideo = false;
        } else { // Video
            _playButton.hidden = false;
            _isVideo = true;
            
            /* Minimize screen if full screen */
            if (_isFullScreen) {
                [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
                    [self.view viewWithTag:navBarViewTag].hidden = false; // nav bar
                    _userName.hidden = false;
                    _homeTown.hidden = false;
                    _videoScreen.backgroundColor = [UIColor clearColor];
                    _videoScreen.frame = _oldFrame;
                    _videoScreen.layer.cornerRadius = 10;
                } completion:^(BOOL finished) {
                    _isFullScreen = false;
                    _videoScreen.contentMode = UIViewContentModeScaleAspectFill;
                }];
            }
        }
        
        // Update Line segments
        if (_currentVideoInGroup == 0) {
            [self.view viewWithTag:videoLineOneViewTag].hidden = false;
            [self.view viewWithTag:videoLineTwoViewTag].hidden = true;
            [self.view viewWithTag:videoLineThreeViewTag].hidden = true;
        } else if (_currentVideoInGroup == 1) {
            [self.view viewWithTag:videoLineOneViewTag].hidden = true;
            [self.view viewWithTag:videoLineTwoViewTag].hidden = false;
            [self.view viewWithTag:videoLineThreeViewTag].hidden = true;
        }
    }
}

-(void)rightVideo {
    if (_currentVideoInGroup == 2) {

    } else {
        _currentVideoInGroup += 1;
        _videoScreen.image = [_loadedEntryThumbnailsList objectAtIndex:_currentVideoInGroup];
        
        int dailyVoteNumber = [_mainAccount.dailyVoteNumber intValue];
        VideoEntry *entry = [_Entries objectAtIndex:dailyVoteNumber+_currentVideoInGroup];
        _userName.text = [NSString stringWithFormat:@"%@", entry.username];
        _homeTown.text = [NSString stringWithFormat:@"%@", entry.hometown];
        _entryDescription.text = entry.entryDescription;
        
        // hide play button or not
        NSString *fileNameString = ((NSURL*)[_loadedEntriesList objectAtIndex:_currentVideoInGroup]).absoluteString;
        if ([fileNameString rangeOfString:@".mp4"].location == NSNotFound) { // Photo
            _playButton.hidden = true;
            _isVideo = false;
        } else { // Video
            _playButton.hidden = false;
            _isVideo = true;
            
            /* Minimize screen if full screen */
            if (_isFullScreen) {
                [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
                    [self.view viewWithTag:navBarViewTag].hidden = false; // nav bar
                    _userName.hidden = false;
                    _homeTown.hidden = false;
                    _videoScreen.backgroundColor = [UIColor clearColor];
                    _videoScreen.frame = _oldFrame;
                    _videoScreen.layer.cornerRadius = 10;
                } completion:^(BOOL finished) {
                    _isFullScreen = false;
                    _videoScreen.contentMode = UIViewContentModeScaleAspectFill;
                }];
            }
        }
        
        // Update Line segments
        if (_currentVideoInGroup == 1) {
            [self.view viewWithTag:videoLineOneViewTag].hidden = true;
            [self.view viewWithTag:videoLineTwoViewTag].hidden = false;
            [self.view viewWithTag:videoLineThreeViewTag].hidden = true;
        } else if (_currentVideoInGroup == 2) {
            [self.view viewWithTag:videoLineOneViewTag].hidden = true;
            [self.view viewWithTag:videoLineTwoViewTag].hidden = true;
            [self.view viewWithTag:videoLineThreeViewTag].hidden = false;
        }
    }
}


/** DB METHODS **/

/* Gets IOS's temp dir*/
- (NSString *)documentsPathForFileName:(NSString *)name {
    NSString *documentsPath = NSTemporaryDirectory();
    return [documentsPath stringByAppendingPathComponent:name];
}

-(void)loadVideosBufferdailyVoteNumber:(int)dailyVoteNumber firstLoad:(BOOL)firstLoad callback:(void (^)(NSError *error, BOOL success, NSNumber *currGroupNumber))callback {
    SPAM(("Loading Videos Buffer\n"));
    
    if (firstLoad) {
        [SVProgressHUD showWithStatus:@"Loading Entries..."];
    }
    
    __block int videosLoaded = 0; // how many videos loaded in this iteration
    
    __block NSNumber *currentGroupNumber = _currentGroupNumber; // holds the specific buffered groups group number
    
    // add status of buffer loading
    _videoGroupBufferStatusMap[currentGroupNumber] = @"1"; // 1 is not read - 0 is ready
    
    /* Increase currentGroupNumber */
    int ogGrpNum = [_currentGroupNumber intValue];
    _currentGroupNumber =  [NSNumber numberWithInt:ogGrpNum+1];
    
    for (int index = dailyVoteNumber; index < amountOfPreLoadedVideos+dailyVoteNumber; index++) {
        
        VideoEntry *videoEntry = [_Entries objectAtIndex:index];
        
        /* Full path of collection and entity */
        NSString *collectionAndEntity = [NSString stringWithFormat:@"%@/%@", kEntryVideos, videoEntry.videoID];
        NSString *locations = [kBaseURL stringByAppendingPathComponent:collectionAndEntity];
        
        SPAM(("--VID: %s\n", [videoEntry.videoID UTF8String]));
        [_orderOfEntriesList addObject:videoEntry.videoID];
        
        NSString * encodedString = [locations stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        
        NSURL* url = [NSURL URLWithString:encodedString];
        
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"GET";
        // Set Up Auth
        [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:_mainAccount._accountid];
        
        // determine if pic or video
        if ([videoEntry.contentType isEqualToString:@"video"]) {
            [request addValue:@"video/mp4" forHTTPHeaderField:@"Content-Type"];
        } else {
            [request addValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
        }
        
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
        
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            // For status code
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            
            if (error == nil && [httpResponse statusCode] == 200 && data != nil) {
                SPAM(("Loaded a video into Buffer - %s\n", [videoEntry.videoID UTF8String]));
                
                NSString *videoName;
                if ([videoEntry.contentType isEqualToString:@"video"]) {
                    videoName = [[NSString alloc] initWithFormat:@"%@.mp4", videoEntry.videoID];
                } else { // image
                    videoName = [[NSString alloc] initWithFormat:@"%@.jpeg", videoEntry.videoID];
                }
                
                
                NSString *filePath = [self documentsPathForFileName:videoName];
                [data writeToFile:filePath atomically:YES];
                NSURL *videoFileURL =  [NSURL fileURLWithPath:filePath]; // local file path
                
                if (videoFileURL != nil  && [[videoFileURL absoluteString] length] != 0) {
                    _loadedEntriesBufferMap[videoEntry.videoID] = videoFileURL;
                } else {
                    _errorLoadingInToBuffer = true;
                }
                
                
                if ([videoEntry.contentType isEqualToString:@"video"]) {
                    // Create thumbnail
                    AVAsset *asset = [AVAsset assetWithURL:videoFileURL];
                    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
                    CMTime thumbnailTime = [asset duration];
                    thumbnailTime.value = 0;
                    CGImageRef imgRef = [imageGenerator copyCGImageAtTime:thumbnailTime actualTime:NULL error:nil];
                    UIImage *i = [[UIImage alloc] initWithCGImage:imgRef scale:UIViewContentModeScaleAspectFit orientation:UIImageOrientationUp];
                    
                    if (i != nil) {
                        _loadedEntryThumbnailsBufferMap[videoEntry.videoID] = i;
                    }
                } else { // image
                    NSData* imageData = [NSData dataWithContentsOfURL:videoFileURL]; 
                    UIImage* i = [UIImage imageWithData:imageData];
                    
                    _loadedEntryThumbnailsBufferMap[videoEntry.videoID] = i;
                }
                

                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        /* Update UI in main thread */
                        
                        videosLoaded+=1;
                        
                        if (videosLoaded == 3) {
                            /* Change the status of the group of videos loading status */
                            _videoGroupBufferStatusMap[currentGroupNumber] = @"0";
                            callback(error, YES, currentGroupNumber);
                        }
                    });
                });
                
            } else {
                NSLog(@"Error loading into buffer %@",[error localizedDescription]);
                
                if (firstLoad) {
                    [SVProgressHUD dismiss];
                    
                    // can't load videos rn, call delegate to dismiss view
                    id<VotingDelegate> strongDelegate = self.delegate;
                    if ([strongDelegate respondsToSelector:@selector(returnToMainViewNoVideos:)]) {
                        [strongDelegate returnToMainViewNoVideos:@"2"]; // called from main view
                    }
                } else { // a buffer load
                    _errorLoadingInToBuffer = true;
                }
            }
        }];
        
        [dataTask resume]; //8
        
    } // end for loop
}

@end
