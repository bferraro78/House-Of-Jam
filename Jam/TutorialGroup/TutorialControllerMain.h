//
//  TutorialControllerMain.h
//  RailJam
//
//  Created by Ben Ferraro on 8/2/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef TutorialControllerMain_h
#define TutorialControllerMain_h
#import <UIKit/UIKit.h>


@interface TutorialControllerMain : UIViewController <UIGestureRecognizerDelegate, NSLayoutManagerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *tutorialLabel;
@property (strong, nonatomic) IBOutlet UITextView *homebaseText;

@property (strong, nonatomic) IBOutlet UIImageView *houseIcon;

@property (strong, nonatomic) IBOutlet NSMutableArray *homebaseImageViewArr;
@property (strong, nonatomic) IBOutlet NSMutableArray *homebasePicArr;
@property int currentVideo;

/* Background Image View */
@property (strong, nonatomic) IBOutlet UIImageView *backGroundPic;


@end

#endif /* TutorialControllerMain_h */
