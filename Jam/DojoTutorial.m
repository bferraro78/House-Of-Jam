//
//  DojoTutorial.m
//  Jam
//
//  Created by Ben Ferraro on 10/25/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DojoTutorial.h"

@implementation DojoTutorial

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    return 8; // Line spacing of 19 is roughly equivalent to 5 here.
}

-(void)viewDidLoad {
    
    [self prefersStatusBarHidden];
    
    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat screenHeight = self.view.frame.size.height;
    
    // Parchment background for devices other than normal iphones
    CGRect newBackGroundFrame = CGRectMake(0.0, 0.0, screenWidth, screenHeight);
    _backGroundPic = [[UIImageView alloc] initWithFrame:newBackGroundFrame];
    _backGroundPic.image = [UIImage imageNamed:@"parchmentBackground"];
    _backGroundPic.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_backGroundPic];
    [self.view sendSubviewToBack:_backGroundPic];
    
    /* Atrributes */
    NSDictionary *attributesNormal = @{
                                       NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:21.0]
                                       };
    NSDictionary *attributesStellar = @{
                                       NSFontAttributeName : [UIFont fontWithName:@"ActionMan-Bold" size:21.0]
                                       };
    NSDictionary *attributesLarge = @{
                                      NSFontAttributeName : [UIFont fontWithName:@"ActionMan-Bold" size:26.0]
                                      };
    
    
    NSAttributedString *dojoTitle = [[NSAttributedString alloc] initWithString:@"Weekly Entries!\n\n\n" attributes:attributesLarge];
    NSMutableAttributedString *stellarStr = [[NSMutableAttributedString alloc] initWithString:@"Captured a stellar moment?\n\n" attributes:attributesStellar];
    [stellarStr addAttribute:NSUnderlineStyleAttributeName
                           value:[NSNumber numberWithInt:3]
                           range:(NSRange){0,[stellarStr length]}];
    NSAttributedString *dojoStr = [[NSAttributedString alloc] initWithString:@"Submit it to our weekly entry pool.\n\nThere, your entry will be pitted against 2 other entries. Throughout the week, users will vote on their favorite entry in each pool." attributes:attributesNormal];
    
    NSMutableAttributedString *dojoText = [[NSMutableAttributedString alloc] init];
    [dojoText appendAttributedString:dojoTitle];
                                      [dojoText appendAttributedString:stellarStr];
    [dojoText appendAttributedString:dojoStr];

    // Inital Text View
    _homebaseText = [[UITextView alloc] initWithFrame:CGRectMake(5.0, 70.0,
                                                                 screenWidth-10.0, screenHeight-70.0)];
    _homebaseText.editable = false;
    _homebaseText.selectable = false;
    _homebaseText.backgroundColor = [UIColor clearColor];
    _homebaseText.layoutManager.delegate = self;
    _homebaseText.attributedText = dojoText;
    _homebaseText.textAlignment = NSTextAlignmentCenter;
    _homebaseText.scrollEnabled = false;
    
    [self.view addSubview:_homebaseText];
    
    
    // Pictures of tutorial
    _dojoPicArr = [[NSMutableArray alloc] init];
    [_dojoPicArr insertObject:[UIImage imageNamed:@"tutorialDojoPic"] atIndex:0];
    
    _dojoImageViewArr = [[NSMutableArray alloc] init];
    
    // Set views and images for each image view
    for (int i = 0; i < [_dojoPicArr count]; i++) {
        
        UIImageView *dojoPic = [[UIImageView alloc] init];
        dojoPic.frame = CGRectMake(self.view.frame.size.width, 0.0,
                                   self.view.frame.size.width,
                                   self.view.frame.size.height);
        dojoPic.contentMode = UIViewContentModeScaleAspectFit;
        dojoPic.userInteractionEnabled = true;
        dojoPic.backgroundColor = [UIColor clearColor];
        dojoPic.image = [_dojoPicArr objectAtIndex:i];
        [_dojoImageViewArr insertObject:dojoPic atIndex:0]; // add image view to array
        [self.view addSubview:dojoPic]; // add views to scrollview
    }
    
    _currentImage = 0; // start with first image
    
    /* Touch gesture change image */
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImage:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
}


/* For changing pics */
- (void)tappedImage:(UITapGestureRecognizer *)gestureRecognizer {
    
    /* Atrributes */
    NSDictionary *attributesNormal = @{
                                       NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:21.0]
                                       };
    
    NSDictionary *attributesLarge = @{
                                      NSFontAttributeName : [UIFont fontWithName:@"ActionMan-Bold" size:26.0]
                                      };
    
    // First image
    if(_currentImage == 0) {
        UIImageView *currIV = [_dojoImageViewArr objectAtIndex:_currentImage];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
            _homebaseText.alpha = 0.0;
            
            currIV.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) { }];
    } else if (_currentImage == 1) { // last picture
            
            NSAttributedString *endTitle = [[NSMutableAttributedString alloc] initWithString:@"Weekly Winners\n\n" attributes:attributesLarge];
            NSAttributedString *endStr = [[NSMutableAttributedString alloc] initWithString:@"At the end of each week, the entry’s profile with the most votes out of the entry pool wins!\n\nWinners of each entry pool will be rewarded extra profile points.\n\nMultiple of the top voted entries of each week will be put on our social media and website." attributes:attributesNormal];
            
            NSMutableAttributedString *endText = [[NSMutableAttributedString alloc] init];
            [endText appendAttributedString:endTitle];
            [endText appendAttributedString:endStr];
            
            // Dismiss view, we are done
            // Animate the current image view to the left
            NSInteger currIVNumber = _currentImage - 1;
            UIImageView *currIV = [_dojoImageViewArr objectAtIndex:currIVNumber];
            [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
                currIV.frame = CGRectMake(-self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height);
                currIV.alpha = 0.0;
            } completion:nil];
            
            [UIView animateWithDuration:0.5 delay:0.2 options:0 animations:^{
                _homebaseText.attributedText = endText;
                _homebaseText.alpha = 1.0;
                _homebaseText.textAlignment = NSTextAlignmentCenter;
                
                [self.view bringSubviewToFront:_homebaseText];
            } completion:^(BOOL finished) { }];
        
    } else if (_currentImage == 2) {
        
        // Dissapear text so we can change it real quick
        [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
            _homebaseText.alpha = 0.0;
        } completion:^(BOOL finished) {
            
            NSAttributedString *endTitle = [[NSMutableAttributedString alloc] initWithString:@"Monthly Prizes\n\n" attributes:attributesLarge];
            NSAttributedString *endStr = [[NSMutableAttributedString alloc] initWithString:@"Earn points as you host and attend Jams as well as submit photo/video entries.\n\nProfiles with the most points at the end of the month will get to choose from a selection of prizes.\n\nSee our \"Monthly Rewards\" page located in the main menu for more details." attributes:attributesNormal];
            
            NSMutableAttributedString *endText = [[NSMutableAttributedString alloc] init];
            [endText appendAttributedString:endTitle];
            [endText appendAttributedString:endStr];
            
            // Re-appear text
            [UIView animateWithDuration:0.2 delay:0.2 options:0 animations:^{
                _homebaseText.attributedText = endText;
                _homebaseText.alpha = 1.0;
                _homebaseText.textAlignment = NSTextAlignmentCenter;
                
                [self.view bringSubviewToFront:_homebaseText];
            } completion:nil];
        }];
        
    } else if (_currentImage == 3) {
        [self leaveTutorial];
    }
    
    _currentImage += 1;
}

- (void)leaveTutorial {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

@end
