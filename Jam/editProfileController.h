//
//  editProfileController.h
//  RailJam
//
//  Created by Ben Ferraro on 7/12/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef editProfileController_h
#define editProfileController_h
#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "Account.h"
#import "AlertView.h"
#import "ImageVideoUploader.h"
#import "Constants.h"
#import "DataBaseCalls.h"
#import "NavigationView.h"

@import SkyFloatingLabelTextField;
@protocol EditProfileDelegate;


@interface editProfileController : UIViewController <UIGestureRecognizerDelegate, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) id <EditProfileDelegate> delegate;

@property Account *editAccount; // logged in account
@property Account *deleAcc; // delegate
@property BOOL toggleAutoLog;

/* Text Fields */
@property (strong, nonatomic) IBOutlet SkyFloatingLabelTextField *editEmail;
@property (strong, nonatomic) IBOutlet SkyFloatingLabelTextField *editPassword;
@property (strong, nonatomic) IBOutlet SkyFloatingLabelTextField *editReType;

/* Upload Pic */
@property (strong, nonatomic) IBOutlet UIButton *accountUploadPicture;
@property BOOL didUploadpic;

/* Upload Video */
@property (strong, nonatomic) IBOutlet UIButton *accountUploadVideo;
@property BOOL didUploadpVideo;
@property int deletedVideoIDIndex;

/* Edit Colors */
@property (strong, nonatomic) IBOutlet UIButton *profileBackGroundColor; // background
@property (strong, nonatomic) IBOutlet UIButton *profileTextColor; // text

/* Edit Bio */
@property (strong, nonatomic) IBOutlet UITextView *bioField;

/* View Direction */
@property (strong, nonatomic) IBOutlet UIButton *saveProfile;
@property (strong, nonatomic) IBOutlet UIButton *voidProfile;
@property (strong, nonatomic) IBOutlet UIButton *autoLogIn;

@property NSData *uploadedFeatureVideo;

/* Uploading vid or pic? */
@property NSString *vidOrPic;

/* Color Picker */
@property UIScrollView *colorPickerView;
@property SkyFloatingLabelTextField *red;
@property SkyFloatingLabelTextField *green;
@property SkyFloatingLabelTextField *blue;
@property UIImageView *colorPreview;
@property BOOL textOrBGColor;
@property BOOL changingColor; // for keyboard dismissing purposes
@property BOOL didChangeBackGroundColor;
@property BOOL didChangeTextColor;

@property NSString* redTextColor;
@property NSString* blueTextColor;
@property NSString* greenTextColor;

@property NSString* redBackGroundColor;
@property NSString* blueBackGroundColor;
@property NSString* greenBackGroundColor;

/* Background Image View */
@property (strong, nonatomic) IBOutlet UIImageView *backGroundPic;

/* Scroll View */
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@protocol EditProfileDelegate <NSObject>
-(void)endEdit:(NSString*)tag;
@end

#endif /* editProfileController_h */
