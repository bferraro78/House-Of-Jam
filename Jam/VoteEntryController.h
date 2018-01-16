//
//  VoteEntryController.h
//  Jam
//
//  Created by Ben Ferraro on 9/6/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef VoteEntryController_h
#define VoteEntryController_h
#import <UIKit/UIKit.h>
#import "AVFoundation/AVFoundation.h"
#import <AVKit/AVKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Account.h"
#import "VideoEntry.h"
#import "AlertView.h"
#import "Constants.h"
#import "DataBaseCalls.h"
#import "NavigationView.h"

@import SVProgressHUD;

@protocol VotingDelegate;

@interface VoteEntryController : UIViewController <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id <VotingDelegate> delegate;

/** Advances in the MAINACCOUNTS _dailyVotedNumber number are done in increments of 3.
 Only advance the number when a user has voted on a set of vidoes. **/
@property Account *mainAccount;

// Loaded from ViewController
@property NSMutableArray *Entries; // holds Video Entry Objects, -- STAYS STATIC THROUGHOUT VOTING SESSION

/* These two properties will be loaded into through session, objects inserted in the front!! */
@property NSMutableArray *loadedEntriesList; // Will hold list of local URL files (in temp dir) loaded from DB
@property NSMutableArray *loadedEntryThumbnailsList; // Will hold list of UImages

@property NSMutableDictionary *loadedEntriesBufferMap; // DB videoID --> localURL file
@property NSMutableDictionary *loadedEntryThumbnailsBufferMap; // DB videoID --> UIImage of thumbnail

// Holds correct order of DB VideoID's, loaded from scratch starting at _mainAccount.dailyVoteNumber in videoEntries[index].videoID
@property NSMutableArray *orderOfEntriesList;
@property NSNumber *currentGroupNumber; // marker in the array above, starts at 0
@property NSMutableDictionary *videoGroupBufferStatusMap; // Video Group number --> 1/0 (if buffer is done loading, 1 = not ready, 0 = ready)

@property int currentVideo; // pointer to current video in orderOfEntries
@property int currentVideoInGroup; // values between 0-2 only

@property BOOL videosToLoad; // determines if there are more videos to load
@property BOOL bufferLoaded; // used in the loadBuffer: callback methods, to determine if UI needs to be updated with buffered material
@property BOOL errorLoadingInToBuffer; // error in one of the videos loading into the buffer, call error

// Buttons
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *voteVideoButton;
@property UIButton *descriptionButton;

// Other UI (Labels, Imageviews)
@property UILabel *descriptionLabel;
@property NSMutableString *screenMode;

@property (strong, nonatomic) IBOutlet UIImageView *videoScreen;

@property (strong, nonatomic) IBOutlet UIImageView *playButton;

@property CGRect oldFrame;
@property BOOL isFullScreen;
@property BOOL isVideo;

@property UILabel *userName;
@property UILabel *homeTown;
@property UITextView *entryDescription;


// Methods
-(void)loadVideosBufferdailyVoteNumber:(int)dailyVoteNumber firstLoad:(BOOL)firstLoad callback:(void (^)(NSError *error, BOOL success, NSNumber *currGroupNumber))callback;

@end

@protocol VotingDelegate <NSObject>
-(void)returnToMainViewNoVideos:(NSString*)tag;
@end


#endif /* VoteEntryController_h */
