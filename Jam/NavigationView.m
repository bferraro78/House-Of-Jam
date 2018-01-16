//
//  NavigationView.m
//  Jam
//
//  Created by Ben Ferraro on 10/10/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//
//  AlertView.m
//  Jam
//
//  Created by Ben Ferraro on 9/12/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NavigationView.h"

@implementation NavigationView

/* Alert tab view */
+(void)showNavView:(NSString*)text leftButton:(UIButton*)leftButton rightButton:(UIButton*)rightButton view:(UIView*)view {
    
    UIView *nav = [[UIView alloc] init];
    nav.backgroundColor = [UIColor whiteColor];
    nav.tag = navBarViewTag;
    
    UILabel *title = [[UILabel alloc] init];
    title.text = text;
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont fontWithName:@"ActionMan" size:22.0];
    
    UIView *bottomBar = [[UIView alloc] init]; // thin divider bar
    bottomBar.backgroundColor = [UIColor darkGrayColor];

    if (leftButton != nil) {
        [nav addSubview:leftButton];
    }
    
    if (rightButton != nil) {
        [nav addSubview:rightButton];
    }
    
    if (view.frame.size.height > 810.0) { // ipad / iphoneX
        nav.frame = CGRectMake(0.0, 0.0, view.frame.size.width, 80.0);
        title.frame = CGRectMake(0.0, 40.0, view.frame.size.width, 40.0);
        leftButton.frame = CGRectMake(10.0, 45.0, 30.0, 30.0);
        rightButton.frame = CGRectMake(view.frame.size.width-40.0, 45.0, 30.0, 30.0);
    } else { // iphone
        nav.frame = CGRectMake(0.0, 0.0, view.frame.size.width, 65.0);
        title.frame = CGRectMake(0.0, 20.0, view.frame.size.width, 45.0);
        leftButton.frame = CGRectMake(10.0, 30.0, 25.0, 25.0);
        rightButton.frame = CGRectMake(view.frame.size.width-35.0, 30.0, 25.0, 25.0);
    }
    
    if ([rightButton.titleLabel.text isEqualToString:@"Change Date"] ||
        [rightButton.titleLabel.text isEqualToString:@"Done"]) { // "Done" - inviteFriends/editProfile | "Change Date" - Jam Forms
        if (view.frame.size.height > 810.0) { // iphoneX/ipad
            rightButton.frame = CGRectMake(view.frame.size.width-70.0, 45.0, 65.0, 35.0);
            rightButton.titleLabel.font = [UIFont fontWithName:@"ActionMan" size:18.0];
        } else { // reg iphone
            rightButton.frame = CGRectMake(view.frame.size.width-70.0, 30.0, 65.0, 30.0);
            rightButton.titleLabel.font = [UIFont fontWithName:@"ActionMan" size:18.0];
        }
    }
    
    rightButton.contentMode = UIViewContentModeScaleAspectFill;
    rightButton.clipsToBounds = true;
    
    // thin bottom bar line
    bottomBar.frame = CGRectMake(0.0, nav.frame.size.height, view.frame.size.width, 1.0);
    
    [nav addSubview:title];
    [nav addSubview:bottomBar];
    
    [view addSubview:nav];
    [view bringSubviewToFront:nav];    
}

@end
