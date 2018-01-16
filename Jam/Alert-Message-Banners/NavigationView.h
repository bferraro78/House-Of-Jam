//
//  NavigationView.h
//  Jam
//
//  Created by Ben Ferraro on 10/10/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef NavigationView_h
#define NavigationView_h
#import <UIKit/UIKit.h>
#import "Constants.h"

@interface NavigationView : NSObject

+(void)showNavView:(NSString*)text leftButton:(UIButton*)leftButton rightButton:(UIButton*)rightButton view:(UIView*)view;

@end

#endif /* NavigationView_h */
