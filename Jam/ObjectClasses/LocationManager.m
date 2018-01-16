//
//  LocationManager.m
//  House Of Jam
//
//  Created by james schuler on 12/22/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationManager.h"

@implementation LocationManager

// Used by all classes that import location manager to get a reference to this class
+(id)sharedLocationManager {
    static LocationManager *sharedLocationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLocationManager = [[self alloc] init];
    });
    return sharedLocationManager;
}

// Delegate method for when a user finally accepts the
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        if (!_locationAlreadyRecieved) {
            /* Get location now that user has authorized */
            _locationAlreadyRecieved = true;
            [self setLocationCoord:^(NSError* error, BOOL success ) { }];
        }
    }
}

-(void)startFindingLocation {
    // Init Apple Location Services
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    
    // Init Google maps location services
    self.placesClient = [GMSPlacesClient sharedClient];
    
    self.locationFound = @"0"; // not found yet
    
    // Init userLat/Long
    self.userLat = 0.0;
    self.userLong = 0.0;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse
        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        if (!_locationAlreadyRecieved) {
            _locationAlreadyRecieved = true;
            [self setLocationCoord:^(NSError* error, BOOL success) { }];
        }
    }
}

-(void)setLocationCoord:(void (^)(NSError *error, BOOL success))callback {
    
    [self.placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *placeLikelihoodList, NSError *error) {
        
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            callback(error, NO);
        }
        
        if (placeLikelihoodList != nil) {
            GMSPlace *place = [[[placeLikelihoodList likelihoods] firstObject] place]; // most accurate answer
            
            if (place != nil) {
                /* Using Apples core location for coords instead of googlemaps */
                CLLocationCoordinate2D center = CLLocationCoordinate2DMake(_locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude);
                
                self.userLat = center.latitude;
                self.userLong = center.longitude;
                
                SPAM(("\nUser Lat: %f, Long - %f\n", _userLat, _userLong));
                
                self.locationFound = @"1"; // observer in View Controller
                
                callback(error, YES);
            } else {
                callback(error, NO);
            }
        } else {
            callback(error, NO);
        }
    }];
}

@end
