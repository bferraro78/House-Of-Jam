//
//  LocationManager.h
//  House Of Jam
//
//  Created by james schuler on 12/22/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef LocationManager_h
#define LocationManager_h
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Constants.h"

@import GoogleMaps;
@import GooglePlaces;
@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property NSString *locationFound; // Observer added in ViewController, determines if loction is able to be found after logging in
@property BOOL locationAlreadyRecieved; // For when a user authorizes us to track location

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) GMSPlacesClient *placesClient;
@property CLLocationDegrees userLat;
@property CLLocationDegrees userLong;

// For observer in Viewcontroller.m
@property BOOL observerAlreadyUsed;

// Methods
+(id)sharedLocationManager;
-(void)startFindingLocation;
-(void)setLocationCoord:(void (^)(NSError *error, BOOL success))callback;

@end
#endif /* LocationManager_h */
