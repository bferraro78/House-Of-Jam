//
//  DojoTutorial.h
//  Jam
//
//  Created by Ben Ferraro on 10/25/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef DojoTutorial_h
#define DojoTutorial_h
#import <UIKit/UIKit.h>


@interface DojoTutorial : UIViewController <UIGestureRecognizerDelegate, NSLayoutManagerDelegate>

@property (strong, nonatomic) IBOutlet NSMutableArray *dojoImageViewArr;
@property (strong, nonatomic) IBOutlet NSMutableArray *dojoPicArr;
@property (strong, nonatomic) IBOutlet UITextView *homebaseText;
@property int currentImage;

/* Background Image View */
@property (strong, nonatomic) IBOutlet UIImageView *backGroundPic;

@end

#endif /* DojoTutorial_h */
