//
//  SignUpController.h
//  RailJam
//
//  Created by Ben Ferraro on 7/4/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef SignUpController_h
#define SignUpController_h

#import <UIKit/UIKit.h>
#import "Session.h"
#import "Account.h"
#import "AlertView.h"
#import "ProfileController.h"
#import "Constants.h"
#import "DataBaseCalls.h"
#import "LocationManager.h"

@import ISHPullUp;

@protocol SignUpDelegate;

@interface SignUpController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (weak, nonatomic) id <SignUpDelegate> delegate;

/* Logged In Account */
@property Account *loggedInSignUpAccount;
/* Account For clicking on table cell to view profile */
@property Account *tmpAccount;

/* Session */
@property Session *mainSignUpSession;

@property UIColor *textLabelColor;

@property BOOL fromAppDelegateSignUp; // Singing up up from a notification?

/* Text Labels */
@property (strong, nonatomic) IBOutlet UILabel *signUpHostName;
@property (strong, nonatomic) IBOutlet UILabel *signUpGameType;
@property (strong, nonatomic) IBOutlet UILabel *signUpStartTime;
@property (strong, nonatomic) IBOutlet UILabel *signUpEntryFee;
@property (strong, nonatomic) IBOutlet UILabel *noImages;
@property (strong, nonatomic) IBOutlet UILabel *jammersLabel;
@property (strong, nonatomic) IBOutlet UILabel *numOfJammers;
@property (strong, nonatomic) IBOutlet UITextView *extraWords;

/* Image Views*/
@property (strong, nonatomic) UILabel *jamPhotosLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *jamPhotosScroll;

/* Buttons */
@property (strong, nonatomic) IBOutlet UIButton *SignUpButton;

/* Table View */
@property (strong, nonatomic) IBOutlet UITableView *jammerTable;

/* In charge of moving the view */
@property int tapNumber;

/* Scroll View */
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

/* Full Screen */
@property CGRect oldScrollFrame;
@property NSMutableArray *oldImageFrames;
@property CGSize oldContentSize;
@property BOOL isFullScreen; // for pictures

@property BOOL scrollViewFullScreen; // for scrollView

@property UISwipeGestureRecognizer *swipeDown;
@property UISwipeGestureRecognizer *swipeUp;

// METHODS
-(void)loadImage:(Session*)session localSignUpPictureCache:(NSMutableDictionary*)localSignUpPictureCache;
-(void)loadSessionContent:(NSMutableDictionary*)localSignUpPictureCache;
-(void)signUpFromAppDele;

@end

@protocol SignUpDelegate <NSObject>
-(void)removeBotView;
-(void)refreshMarker:(NSString*)seshID;
-(void)editJam:(Session*)mainSession editSession:(Session*)editSession;
@end


#endif /* SignUpController_h */
