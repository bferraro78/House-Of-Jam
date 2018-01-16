//
//  createAccountController.h
//  RailJam
//
//  Created by Ben Ferraro on 7/10/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef createAccountController_h
#define createAccountController_h
#import <UIKit/UIKit.h>
#import "Account.h"
#import "AlertView.h"
#import "Constants.h"

@import SVProgressHUD;
@import SkyFloatingLabelTextField;

@protocol CreateAccountControllerDelegate;

@interface CreateAccountController : UIViewController <UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) id <CreateAccountControllerDelegate> delegate;

@property Account *createAccount;

/* Form Properties */
@property (strong, nonatomic) IBOutlet SkyFloatingLabelTextField *createUserName;
@property (strong, nonatomic) IBOutlet SkyFloatingLabelTextField *createEmail;
@property (strong, nonatomic) IBOutlet SkyFloatingLabelTextField *createPassword;
@property (strong, nonatomic) IBOutlet SkyFloatingLabelTextField *reenterPassword;
@property (strong, nonatomic) IBOutlet SkyFloatingLabelTextField *hometown;
@property (strong, nonatomic) IBOutlet SkyFloatingLabelTextField *name;

/* Buttons */
@property (strong, nonatomic) IBOutlet UIButton *createAccountButton;
@property (strong, nonatomic) IBOutlet UIButton *voidAccount;

/* Top Part */
@property (strong, nonatomic) IBOutlet UILabel *createAccountLabel;
@property (strong, nonatomic) IBOutlet UIImageView *createAccountLine;

/* Background Image View */
@property (strong, nonatomic) IBOutlet UIImageView *backGroundPic;

/* Scroll View */
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@protocol CreateAccountControllerDelegate <NSObject>
-(void)toTutorialUN:(NSString*)userName;
@end

#endif /* createAccountController_h */
