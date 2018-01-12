//
//  SeshController.h
//  RailJam
//
//  Created by Ben Ferraro on 6/23/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef SeshController_h
#define SeshController_h
#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <QBImagePickerController/QBImagePickerController.h> // multiple image picker
#import "Session.h"
#import "Account.h"
#import "InviteFriendsController.h"
#import "AlertView.h"
#import "NavigationView.h"
#import "Constants.h"

@import SkyFloatingLabelTextField;

@protocol SeshDelegate;

@interface SeshController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSLayoutManagerDelegate, QBImagePickerControllerDelegate, InviteFriendsDelegate>

@property (weak, nonatomic) id <SeshDelegate> delegate;

@property Session *seshController;
@property Session *mainLocalSession; // represents the unmodified local session when editing

/* Account Properties */
//@property Account *seshAccount;
@property NSMutableArray *mainAccountFriendList;
@property NSString *mainAccountUsername;

/* BOOL */
@property BOOL editingJam;

/* Bool */
@property BOOL railPicture;
@property BOOL prizePicture;

/* Text Fields*/
@property (strong, nonatomic) IBOutlet SkyFloatingLabelTextField *jamName;
@property (strong, nonatomic) IBOutlet SkyFloatingLabelTextField *entryFee;
@property (strong, nonatomic) IBOutlet SkyFloatingLabelTextField *startTime;
@property (strong, nonatomic) IBOutlet UITextView *sessionDescription;

/* Image Picker */
@property PHImageRequestOptions *requestOptions;

/* Jam type picker */
@property (strong, nonatomic) IBOutlet UIPickerView *jamType;
@property NSArray *pickerData;

/* Background Image View */
@property (strong, nonatomic) IBOutlet UIImageView *backGroundPic;

/* Rail and Prize Buttons */
@property (strong, nonatomic) IBOutlet UIButton *railUpload;
@property (strong, nonatomic) IBOutlet UIButton *prizeUpload;
@property NSString *pictureType; // Deciding which Image View to upload picture to

/* Buttons */
@property (strong, nonatomic) IBOutlet UIButton *createRailJam;
@property (strong, nonatomic) IBOutlet UIButton *voidJam;
@property (strong, nonatomic) IBOutlet UIButton *inviteFriends;
@property (strong, nonatomic) IBOutlet UIButton *privateGame;
@property (strong, nonatomic) IBOutlet UIButton *changeDate;


/* Add extra pics */
@property NSMutableArray *extraPicturesArr;
/* Invite Extra Friends */
@property NSMutableArray *extraFriendsArr;

/* Date Picker */
@property UIDatePicker *datePicker;

/* Labels */
@property (strong, nonatomic) IBOutlet UILabel *explanationLabel;
@property (strong, nonatomic) UITextView *explanView;

/* Scroll View */
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;


// METHODS
- (void)viewDidLoad;
-(IBAction)railUpload:(id)sender;
-(IBAction)prizeUpload:(id)sender;
-(IBAction)createRailJam:(id)sender;

@end

@protocol SeshDelegate <NSObject>
-(void)placeMarker:(Session *)session;
-(void)finishEditingJam:(Session *)mainSession editSession:(Session *)editSession extraPicturesArr:(NSMutableArray*)extraPicturesArr extraFriendsArr:(NSMutableArray*)extraFriendsArr;
@end
#endif /* SeshController_h */

