//
//  AlertView.m
//  Jam
//
//  Created by Ben Ferraro on 9/12/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlertView.h"

@implementation AlertView

/* Alert tab view */
+(void)showAlertTab:(NSString*)text view:(UIView*)view {
    
    UITextField *tv = [[UITextField alloc] init];
    
    // set frame
    if (view.frame.size.height > 810.0) { // ipads/iphonex
        tv.frame = CGRectMake(0.0, -60.0, view.frame.size.width, 60.0);
    } else { // not ipads (Iphone 7plus is height = 736.0)
        tv.frame = CGRectMake(0.0, -40.0, view.frame.size.width, 40.0);
    }
    
    tv.backgroundColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0]; // dank blue
    tv.textColor = [UIColor whiteColor];
    tv.textAlignment = NSTextAlignmentCenter;
    tv.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    tv.text = text;
    tv.tag = [self randomTag];
    tv.font = [UIFont fontWithName:@"ActionMan" size:14.0];
    tv.userInteractionEnabled = false;
    
    [view addSubview:tv];
    
    // Animation
    [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
        if (view.frame.size.height > 810.0) { // ipads/iphonex
            tv.frame = CGRectMake(0.0, 0.0, view.frame.size.width, 60.0);
        } else { // not ipads (Iphone 7plus is height = 736.0)
            tv.frame = CGRectMake(0.0, 0.0, view.frame.size.width, 40.0);
        }
    } completion:^(BOOL finished) {
        NSDictionary *dicOfArguments = [[NSDictionary alloc] initWithObjectsAndKeys:view, @"view", [NSNumber numberWithInteger:tv.tag], @"tag", nil];
        [self performSelector:@selector(removeAlertTab:) withObject:dicOfArguments afterDelay:2.6];
    }];
}

+(void)removeAlertTab:(NSDictionary*)dicOfPara {

    UIView *view = [dicOfPara objectForKey:@"view"];
    NSInteger tag = [[dicOfPara objectForKey:@"tag"] intValue];
    
    runOnMainQueue(^{
        // Animation
        [UIView animateWithDuration:0.5 delay:0.1 options:0 animations:^{
            if (view.frame.size.height > 810.0) { // ipads/iphonex
                [view viewWithTag:tag].frame = CGRectMake(0.0, -60.0, view.frame.size.width, 60.0);
            } else { // not ipads (Iphone 7plus is height = 736.0)
                [view viewWithTag:tag].frame = CGRectMake(0.0, -40.0, view.frame.size.width, 40.0);
            }
        } completion:^(BOOL finished) {
            [[view viewWithTag:tag] removeFromSuperview];
        }];
    });
}

+(int)randomTag {
    int ranTag = arc4random_uniform(151) + 10000; // 10,000-10,150
    return ranTag;
}


+(void)showAlertControllerOkayOption:(NSString*)title message:(NSString*)message view:(UIViewController*)view {
    UIAlertController *alertControllerOutDated = [UIAlertController
                                                  alertControllerWithTitle:title
                                                  message:message
                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) { /* Do nothing */ }];
    
    [alertControllerOutDated addAction:okayAction];
    [view presentViewController:alertControllerOutDated animated:YES completion:nil];
}


void runOnMainQueue(void (^block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end
