//
//  ViewController.h
//  RailJam
//
//  Created by Ben Ferraro on 6/22/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <MobileCoreServices/UTCoreTypes.h>

// View Controllers
#import "LogInController.h"
#import "TutorialControllerMain.h"
#import "SeshController.h"
#import "SeshLeisureController.h"
#import "SignUpController.h"
#import "editProfileController.h"
#import "SelectWinnerController.h"
#import "ProfileController.h"
#import "VoteEntryController.h"
#import "InfoViewController.h"
#import "MonthlyRewardsController.h"
#import "DojoTutorial.h"
#import "MainMenuController.h"
#import "MainMenuRight.h"
#import "SearchView.h"
#import "FilterView.h"
#import "MarketplaceController.h"

// NSObject classes
#import "Account.h"
#import "Session.h"
#import "VideoEntry.h"
#import "AlertView.h"
#import "DailyMessage.h"
#import "ImageVideoUploader.h"
#import "Constants.h"
#import "DataBaseCalls.h"

#import "LocationManager.h"

#import <Foundation/Foundation.h>

@import GooglePlaces;
@import SVProgressHUD;
@import SideMenu;
@import StoreKit;

@interface ViewController : UIViewController <GMSMapViewDelegate, SeshDelegate, SeshLeisureDelegate, SignUpDelegate, VotingDelegate, MenuDelegate, MenuRightDelegate, EditProfileDelegate, SelectWinnerDelegate, InfoViewControllerDelegate, MonthlyRewardsControllerDelegate, SearchViewDelegate, FilterViewDelegate, NSLayoutManagerDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GMSAutocompleteViewControllerDelegate, SKStoreProductViewControllerDelegate>


@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;

/* Daily message recieved from DB */
@property NSMutableString *dailyMessage;

/* Bot View */
@property SignUpController *botView;
@property SearchView *searchView;
@property FilterView *filterView;

/* Map View */
@property GMSMapView *mapView;
@property CLLocationDegrees centerLat; // center of map view (not the user location)
@property CLLocationDegrees centerLong;

/* Account */
@property Account *mainAccount;

/* Date */
@property (strong, nonatomic) NSString *currDate;

/* Marker and Session objects arrays */
@property (nonatomic, strong) NSMutableArray* jamSessions; // Array of Jam Sesh's from server
@property (nonatomic, strong) NSMutableDictionary* jamSesssionMarkers; // Dic of Markers added to map, key is _id --> marker object

/* Local Cache Session id --> true/false (if pics have been loaded this log in) */
@property NSMutableDictionary *localSignUpPictureCache;

/* Buttons */
@property (strong, nonatomic) IBOutlet UIButton *seshButton;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIButton *marketPlaceButton;
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UIButton *mapLegendButton;
@property (strong, nonatomic) IBOutlet UIButton *filterButton;
@property (strong, nonatomic) IBOutlet UIButton *IGButton;
@property (strong, nonatomic) IBOutlet UIButton *centerOfMapPointer;

/* Filter Dictionary */
@property NSMutableDictionary *jamFilters;

/* Quote of Log in Label */
@property UILabel *quoteLabel;
@property BOOL showQuote;

/* Marker and Session objects passed into the Sign Up Controller/Select Winner Controller */
@property Session *tmpSession;

/* For saving Entries */
@property NSData *entryData;
@property NSString *imageOrVideo;

/* If updating profile after jam ended doesn't work */
@property int timesWinnerSubmitted;


// METHODS
- (void)viewDidLoad;
-(void)setUpUI;

// Set up map, places markere
-(void)parseAndAddLocations:(NSArray*)locations toArray:(NSMutableArray*)destinationArray;
-(void)createAndAddMarkers:(BOOL)isFromPersist;
-(void)importJamsFromDB:(void (^)(NSError *error, BOOL success, NSArray *responseArray))callback;

// Ending a Jam successfully
-(void)clearJam:(Session *)session index:(int)index winner:(NSString *)winner;

// Tapping Jam Marker
-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker;
-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker;

// Sign Up Sheet
-(void)showSignUpView:(NSString*)seshID;

// Creating a Jam
-(void)sendAPNInvitedJammers:(Session*)jam extraFriendsArr:(NSMutableArray*)extraFriendsArr;
-(void)placeMarker:(GMSMarker*)marker;
-(void)addJamToDB:(Session*)session callback:(void (^)(NSError *error, BOOL success, NSArray *responseArray))callback; // inserts Session object into DB
-(void)saveNewLocationImageFirst:(Session*)session;

// Entry Submission
-(void)submitEntryWithDesc:(UIButton*)sender;
-(void)getEntryDescription;
-(void)saveEntryVideo:(NSData*)videoData imageOrVideo:(NSString *)imageOrVideo entryDescription:(NSString*)entryDescription;

// Side Menu
-(void)menuOption:(NSString *)option;

@end

