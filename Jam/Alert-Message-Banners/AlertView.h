//
//  AlertView.h
//  Jam
//
//  Created by Ben Ferraro on 9/12/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef AlertView_h
#define AlertView_h
#import <UIKit/UIKit.h>
#import "Constants.h"

@interface AlertView : NSObject



+(void)showAlertTab:(NSString*)text view:(UIView*)view;
+(void)removeAlertTab:(UIView*)view;
+(int)randomTag;
// Abstraction for a Alert View Controller
+(void)showAlertControllerOkayOption:(NSString*)title message:(NSString*)message view:(UIViewController*)view;

@end

#endif /* AlertView_h */
