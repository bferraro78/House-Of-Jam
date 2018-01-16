//
//  LaunchController.h
//  Jam
//
//  Created by Ben Ferraro on 10/6/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef LaunchController_h
#define LaunchController_h
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "LocationManager.h"

@interface LaunchController : UIViewController


@property (strong, nonatomic) IBOutlet UIImageView *launchImageView;

@property (strong, nonatomic) IBOutlet UILabel *versionLabel;

@property BOOL largeScreen;

@end

#endif /* LaunchController_h */
