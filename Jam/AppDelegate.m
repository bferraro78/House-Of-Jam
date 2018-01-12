//
//  AppDelegate.m
//  RailJam
//
//  Created by Ben Ferraro on 6/22/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound +UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              // Enable or disable features based on authorization.
                          }];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];  // this calls delegate method application:didRegisterForRemoteNotificationsWithDeviceToken
    
    // Google Maps API KEYS
    [GMSServices provideAPIKey:@"AIzaSyDjLaNS7i4diH7yT312TqhjJ_ExgSkNJEI"];
    [GMSPlacesClient provideAPIKey:@"AIzaSyBULJAkllhoGKYjf-ySh8pwzROoTVXjwvY"];
    
    /* Load deafult account saved in NSUserDefaults */
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"defaultAccount"];
    self.defaultAccount = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject]; // calls Account.m decodeWithCoder
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageControl.backgroundColor = [UIColor clearColor];
    
    return YES;
}

// Handle remote notification registration.
- (void)application:(UIApplication *)app
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    // Forward the token to your provider, using a custom method.
    _notificationToken = devToken;
    
}
- (void)application:(UIApplication *)app
didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    // The token is not currently available.
    NSLog(@"Remote notification support is unavailable due to error: %@", err);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // Reget userLat/Long
    [[LocationManager sharedLocationManager] setLocationCoord:^(NSError *error, BOOL success) { }];
    
    // Clear Badge Number
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    if (_remoteNoteReceived) {
        
        NSString *message = [[[_remoteUserInfo valueForKey:@"aps"]valueForKey:@"alert"] valueForKey:@"message"];
        NSString *seshID = [_remoteUserInfo valueForKey:@"payload"];
        
        NSArray *array = [message componentsSeparatedByString:@"|"];
        NSString *hostName = [array objectAtIndex:0];
        NSString *otherInfo = [array objectAtIndex:1];
        
        /* Loading alert box */
        UIAlertController *alertControllerCreateMarkers = [UIAlertController
                                                           alertControllerWithTitle:hostName
                                                           message:otherInfo
                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"Sign Up" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               
                                                               NSString *accountID = _defaultAccount._accountid;
                                                               
                                                               [Session loadSession:kBaseURL seshID:seshID message:accountID callback:^(NSError *error, BOOL success, NSDictionary *responseSession) {
                                                                   if (responseSession != nil) {
                                                                       /* Load Session from DB */
                                                                       Session *tmpSession = [[Session alloc] initWithDictionary:responseSession];
                                                                       
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           
                                                                           NSString * storyboardName = @"Main";
                                                                           UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                                                                           
                                                                           SignUpController *botView = [storyboard instantiateViewControllerWithIdentifier:@"SignUpController"];
                                                                           
                                                                           botView.mainSignUpSession = tmpSession;
                                                                           botView.loggedInSignUpAccount = _defaultAccount;
                                                                           botView.fromAppDelegateSignUp = true;
                                                                           
                                                                           [botView signUpFromAppDele]; // sign up jammer
                                                                       });
                                                                   }
                                                               }];
                                                           }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) { /* Do Nothing*/ }];
        
        [alertControllerCreateMarkers addAction:okayAction];
        [alertControllerCreateMarkers addAction:cancelAction];
        
        UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        alertWindow.rootViewController = [[UIViewController alloc] init];
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        [alertWindow makeKeyAndVisible];
        
        [alertWindow.rootViewController presentViewController:alertControllerCreateMarkers animated:YES completion:nil];
        
        
        _remoteNoteReceived = false;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    /* Save default account to NSUserDefaults */
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.defaultAccount]; // calls Account.m encodeWithCoder
    [defaults setObject:encodedObject forKey:@"defaultAccount"];
    [defaults synchronize];
    
    /* Clean out temp directory - videos/photos are saved here when loaded!! */
    [self clearTmpDirectory];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    
    if(application.applicationState == UIApplicationStateInactive) {
        
        NSLog(@"\nInactive NOTE\n");
        
        NSString *message = [[[userInfo valueForKey:@"aps"]valueForKey:@"alert"] valueForKey:@"message"];
        
        NSArray *array = [message componentsSeparatedByString:@"|"];
        NSString *hostName = [array objectAtIndex:0];
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = hostName;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        // Set info for when app is pushed into foreground
        _remoteNoteReceived = true;
        _remoteUserInfo = [[NSDictionary alloc] initWithDictionary:userInfo];
        
        completionHandler(UIBackgroundFetchResultNewData);
        
    } else if (application.applicationState == UIApplicationStateBackground) {
        
        NSString *message = [[[userInfo valueForKey:@"aps"]valueForKey:@"alert"] valueForKey:@"message"];
        
        NSArray *array = [message componentsSeparatedByString:@"|"];
        NSString *hostName = [array objectAtIndex:0];
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = hostName;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        // Set info for when app is pushed into foreground
        _remoteNoteReceived = true;
        _remoteUserInfo = [[NSDictionary alloc] initWithDictionary:userInfo];
        
        completionHandler(UIBackgroundFetchResultNewData);
        
    } else { // foreground
        
        NSString *message = [[[userInfo valueForKey:@"aps"]valueForKey:@"alert"] valueForKey:@"message"];
        NSString *seshID = [userInfo valueForKey:@"payload"];
        
        NSArray *array = [message componentsSeparatedByString:@"|"];
        NSString *hostName = [array objectAtIndex:0];
        NSString *otherInfo = [array objectAtIndex:1];
        
        /* Loading alert box */
        UIAlertController *alertControllerCreateMarkers = [UIAlertController
                                                           alertControllerWithTitle:hostName
                                                           message:otherInfo
                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"Sign Up" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               
                                                               NSString *accountID = _defaultAccount._accountid;
                                                               
                                                               [Session loadSession:kBaseURL seshID:seshID message:accountID callback:^(NSError *error, BOOL success, NSDictionary *responseSession) {
                                                                   if (responseSession != nil) {
                                                                       /* Load Session from DB */
                                                                       Session *tmpSession = [[Session alloc] initWithDictionary:responseSession];
                                                                       
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           
                                                                           NSString * storyboardName = @"Main";
                                                                           UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                                                                           
                                                                           SignUpController *botView = [storyboard instantiateViewControllerWithIdentifier:@"SignUpController"];
                                                                           
                                                                           botView.mainSignUpSession = tmpSession;
                                                                           botView.loggedInSignUpAccount = _defaultAccount;
                                                                           botView.fromAppDelegateSignUp = true;
                                                                           
                                                                           [botView signUpFromAppDele]; // sign up jammer
                                                                       });
                                                                   }
                                                               }];
                                                           }];

        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) { /* Do Nothing*/ }];
        
        [alertControllerCreateMarkers addAction:okayAction];
        [alertControllerCreateMarkers addAction:cancelAction];
    
        UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        alertWindow.rootViewController = [[UIViewController alloc] init];
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        [alertWindow makeKeyAndVisible];
        
        [alertWindow.rootViewController presentViewController:alertControllerCreateMarkers animated:YES completion:nil];
        
        completionHandler(UIBackgroundFetchResultNewData);
        
    }
}


/* Clears tmp directory! Vidoes from voting and profiles are stored here. Must be deleted! */
-(void)clearTmpDirectory {
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}


@end
