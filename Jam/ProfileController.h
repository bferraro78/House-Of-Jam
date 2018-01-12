//
//  ProfileController.h
//  RailJam
//
//  Created by Ben Ferraro on 7/9/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef ProfileController_h
#define ProfileController_h
#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "Account.h"
#import "AlertView.h"
#import "Constants.h"
#import "NavigationView.h"
#import "ProfileVideosController.h"
#import "FriendListView.h"
#import "DataBaseCalls.h"

@interface ProfileController : UIViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate, GMSMapViewDelegate>

/* Accounts */
@property Account *profileAccount; // account of profile you are viewing
@property Account *loggedInAccount; // logged in account

@property BOOL ownProfile; // For accessing friends list vs adding a friend

/* Map */
@property GMSMapView *mapView;

/* Labels */
@property (strong, nonatomic) IBOutlet UILabel *noProfilePic;
@property (strong, nonatomic) IBOutlet UILabel *homeTown;

/* Prof Pic View / Background Pic View*/
@property (strong, nonatomic) IBOutlet UIImageView *loadedProfile;

/* Buttons */
@property (strong, nonatomic) IBOutlet UIButton *leaveProfileButton;
@property (strong, nonatomic) IBOutlet UIButton *addFriend;
@property (strong, nonatomic) IBOutlet UIButton *videoPage;

/* Scroll View */
@property(strong, nonatomic) IBOutlet UIScrollView *scrollView;

/* Text Labels */
@property (strong, nonatomic) IBOutlet UILabel *winsLabel;
@property (strong, nonatomic) IBOutlet UILabel *winsNumber;
@property (strong, nonatomic) IBOutlet UILabel *placesLabel;
@property (strong, nonatomic) IBOutlet UILabel *placesNumber;
@property (strong, nonatomic) IBOutlet UILabel *sessionsLabel;
@property (strong, nonatomic) IBOutlet UILabel *sessionsNumber;
@property (strong, nonatomic) IBOutlet UILabel *entryVotesLabel;
@property (strong, nonatomic) IBOutlet UILabel *entryVotesNumber;

// Methods
-(void)loadImage:(Account *)profileAccount;
-(void)placeMarkers:(CGFloat)mapStart screenWidth:(CGFloat)screenWidth;

@end

#endif /* ProfileController_h */
