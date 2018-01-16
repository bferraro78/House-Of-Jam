//
//  SeshLeisureController.h
//  RailJam
//
//  Created by Ben Ferraro on 7/12/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef SeshLeisureController_h
#define SeshLeisureController_h
#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "Session.h"
#import "Account.h"
#import "InviteFriendsController.h"
#import "AlertView.h"
#import "NavigationView.h"
#import "Constants.h"
#import <QBImagePickerController/QBImagePickerController.h> // multiple image picker

@import SkyFloatingLabelTextField;


@protocol SeshLeisureDelegate;

@interface SeshLeisureController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QBImagePickerControllerDelegate, InviteFriendsDelegate>

@property (weak, nonatomic) id <SeshLeisureDelegate> delegate;

@property Session *seshController;
@property Session *mainLocalSession; // represents the unmodified local session when editing

/* Account Properties */
//@property Account *seshAccount;
@property NSMutableArray *mainAccountFriendList;
@property NSString *mainAccountUsername;

/* BOOL */
@property BOOL editingJam;

/* Buttons */
@property (strong, nonatomic) IBOutlet UIButton *createRailJam;
@property (strong, nonatomic) IBOutlet UIButton *voidJam;
@property (strong, nonatomic) IBOutlet UIButton *locPicUpload;
@property (strong, nonatomic) IBOutlet UIButton *inviteFriends;
@property (strong, nonatomic) IBOutlet UIButton *changeDate;
@property (strong, nonatomic) IBOutlet UIButton *privateGame;

/* Text Fields*/
@property (strong, nonatomic) IBOutlet SkyFloatingLabelTextField *jamName;
@property (strong, nonatomic) IBOutlet SkyFloatingLabelTextField *startTime;
@property (weak, nonatomic) IBOutlet SkyFloatingLabelTextField *jamTypeText;
@property (strong, nonatomic) IBOutlet UITextView *sessionDescription;

/* Image Picker */
@property PHImageRequestOptions *requestOptions;

/* Jam type picker */
@property (strong, nonatomic) IBOutlet UIPickerView *jamType;
@property NSArray *pickerData;

/* Background Views */
@property (strong, nonatomic) IBOutlet UIImageView *backGroundPic;

/* Scroll View */
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

/* Add extra pics */
@property NSMutableArray *extraPicturesArr;
/* Invite Extra Friends */
@property NSMutableArray *extraFriendsArr;

/* Date Picker */
@property UIDatePicker *datePicker;

@end


@protocol SeshLeisureDelegate <NSObject>
-(void)placeMarker:(Session *)session;
-(void)finishEditingJam:(Session *)mainSession editSession:(Session *)editSession extraPicturesArr:(NSMutableArray*)extraPicturesArr extraFriendsArr:(NSMutableArray*)extraFriendsArr;
@end

#endif /* SeshLeisureController_h */
