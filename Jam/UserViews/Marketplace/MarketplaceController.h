//
//  MarketplaceController.h
//  House Of Jam
//
//  Created by james schuler on 12/13/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef MarketplaceController_h
#define MarketplaceController_h
#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "Account.h"
#import "AlertView.h"
#import "NavigationView.h"

@interface MarketplaceController : UIViewController <UIGestureRecognizerDelegate, GMSMapViewDelegate>

/* Map */
@property GMSMapView *mapViewMarket;

@property Account *mainAccount;

@property UIScrollView *featProducts;

/* Background Image View */
@property (strong, nonatomic) IBOutlet UIImageView *backGroundPic;


@end

#endif /* MarketplaceController_h */
