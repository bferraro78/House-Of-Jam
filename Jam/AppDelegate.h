//
//  AppDelegate.h
//  RailJam
//
//  Created by Ben Ferraro on 6/22/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "LaunchController.h"
#import "Constants.h"
#import "Account.h"
#import "LocationManager.h"

@import UserNotifications;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) Account *defaultAccount;
/* default account for UserDefault (only used for UN and PW log in right now),
   and to update main account in appTerminate */

@property (strong, nonatomic) UIWindow *window;

@property NSData *notificationToken;

@property BOOL remoteNoteReceived; // == true when notification is recieved and app is in background
@property NSDictionary *remoteUserInfo;


@end

