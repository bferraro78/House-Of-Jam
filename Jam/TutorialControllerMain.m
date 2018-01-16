//
//  TutorialControllerMain.m
//  RailJam
//
//  Created by Ben Ferraro on 8/2/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TutorialControllerMain.h"

@implementation TutorialControllerMain

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    return 8; // Line spacing of 19 is roughly equivalent to 5 here.
}

- (void)viewDidLayoutSubviews {
    [self.homebaseText setContentOffset:CGPointZero animated:NO];
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
                                       NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:17.0]
                                       };
    
    NSDictionary *attributesLarge = @{
                                      NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:22.0]
                                      };
    
    NSMutableAttributedString *startText = [[NSMutableAttributedString alloc] initWithString:@"A platform to meet new people, share your experiences, and discover the world through 7 billion different eyes.\n\nWhat is a Jam?\n\nTap the House to find out." attributes:nil];
    if (self.view.frame.size.height < 810.0) {
        [startText addAttributes:attributesNormal range:NSMakeRange(0, [startText.string length])];
        _tutorialLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 35.0,
                                                                   screenWidth-10.0, 45.0)];
    } else { // ipad/iphoneX
        [startText addAttributes:attributesLarge range:NSMakeRange(0, [startText.string length])];
        _tutorialLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 50.0,
                                                                   screenWidth-10.0, 45.0)];
    }
    
    _tutorialLabel.text = @"Welcome to The House Of Jam";
    _tutorialLabel.numberOfLines = 2;
    _tutorialLabel.font = [UIFont fontWithName:@"ActionMan-Bold" size:22.0];
    _tutorialLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_tutorialLabel];
    
    // Inital Text View
    _homebaseText = [[UITextView alloc] initWithFrame:CGRectMake(10.0, (_tutorialLabel.frame.origin.y+_tutorialLabel.frame.size.height+5.0),
                                                                 screenWidth-20.0, 0.0)];
    _homebaseText.editable = false;
    _homebaseText.selectable = false;
    _homebaseText.backgroundColor = [UIColor clearColor];
    _homebaseText.layoutManager.delegate = self;
    _homebaseText.clipsToBounds = true;
    _homebaseText.attributedText = startText;
    _homebaseText.textAlignment = NSTextAlignmentCenter;
    _homebaseText.scrollEnabled = false;
    
    // Auto fit the size if the content
    CGFloat fixedWidth = _homebaseText.frame.size.width;
    CGSize newSize = [_homebaseText sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = _homebaseText.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    _homebaseText.frame = newFrame;
    
    _homebaseText.translatesAutoresizingMaskIntoConstraints = true;
    
    // Icon
    _houseIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                   (_homebaseText.frame.origin.y+_homebaseText.frame.size.height+5.0),
                                                               screenWidth,
                                                               screenHeight-(_homebaseText.frame.origin.y+_homebaseText.frame.size.height))];
    _houseIcon.image = [UIImage imageNamed:@"tutorialHouse"];
    _houseIcon.contentMode = UIViewContentModeScaleAspectFill;
    _houseIcon.clipsToBounds = true;
    
    [self.view addSubview:_homebaseText];
    [self.view addSubview:_houseIcon];
    
    // Pictures of tutorial
    _homebasePicArr = [[NSMutableArray alloc] init];
    [_homebasePicArr insertObject:[UIImage imageNamed:@"TutorialPicture3"] atIndex:0];
    [_homebasePicArr insertObject:[UIImage imageNamed:@"TutorialPicture4"] atIndex:0];
    [_homebasePicArr insertObject:[UIImage imageNamed:@"TutorialPicture5"] atIndex:0];
    [_homebasePicArr insertObject:[UIImage imageNamed:@"TutorialPicture6"] atIndex:0]; // kick jammer list
    [_homebasePicArr insertObject:[UIImage imageNamed:@"TutorialPicture7"] atIndex:0];
    [_homebasePicArr insertObject:[UIImage imageNamed:@"TutorialPicture8"] atIndex:0];
    [_homebasePicArr insertObject:[UIImage imageNamed:@"TutorialPicture9"] atIndex:0];
    
    _homebaseImageViewArr = [[NSMutableArray alloc] init];
    
    // Set views and images for each image view
    for (int i = 0; i < [_homebasePicArr count]; i++) {
        
        UIImageView *homebasePic = [[UIImageView alloc] init];
        
        // Set all views to the right of the main view
        homebasePic.frame = CGRectMake(self.view.frame.size.width, 0.0,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height);
        
        homebasePic.contentMode = UIViewContentModeScaleAspectFit; //UIViewContentModeScaleToFill; (AspectFit for ipad/iphoneX)
        homebasePic.clipsToBounds = true;
        homebasePic.userInteractionEnabled = true;
        homebasePic.backgroundColor = [UIColor clearColor];
        homebasePic.image = [_homebasePicArr objectAtIndex:i];
        [_homebaseImageViewArr insertObject:homebasePic atIndex:0]; // add image view to array
        [self.view addSubview:homebasePic]; // add views to scrollview
    }
    
    _currentVideo = 0; // start with first video
    
    /* Touch gesture change image */
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImage:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    /* Touch gesture swipe away tutorial */
    UISwipeGestureRecognizer *swipeDownTut = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leaveTutorial)];
    swipeDownTut.direction = UISwipeGestureRecognizerDirectionDown;
    swipeDownTut.delegate = self;
    [self.view addGestureRecognizer:swipeDownTut];
    
}


/* For changing pics */
- (void)tappedImage:(UITapGestureRecognizer *)gestureRecognizer {
    /* Atrributes */
    NSDictionary *attributesNormal = @{
                                       NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:21.0]
                                       };
    
    NSDictionary *attributesLarge = @{
                                      NSFontAttributeName : [UIFont fontWithName:@"ActionMan-Bold" size:24.0]
                                      };
    
    if (_currentVideo == 0) {
        
        self.view.userInteractionEnabled = false;
        
        // Dissapear text so we can change it real quick
        [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
            _homebaseText.alpha = 0.0;
            _tutorialLabel.alpha = 0.0;
            _houseIcon.alpha = 0.0;
        } completion:^(BOOL finished) {
            _homebaseText.frame = CGRectMake(0.0, 50.0, self.view.frame.size.width, self.view.frame.size.height-50.0);
            _tutorialLabel.hidden = true;
            _houseIcon.hidden = true;
            
            NSAttributedString *jamTitle = [[NSMutableAttributedString alloc] initWithString:@"What is a Jam?\n\n" attributes:attributesLarge];
            NSAttributedString *jamStr = [[NSMutableAttributedString alloc] initWithString:@"A Jam is a location where you and others can gather to do what you love\n\nThe House Of Jam brings together all the local happenings under one roof" attributes:attributesNormal];
            
            NSMutableAttributedString *jamText = [[NSMutableAttributedString alloc] init];
            [jamText appendAttributedString:jamTitle];
            [jamText appendAttributedString:jamStr];
            
            // Re-appear text
            [UIView animateWithDuration:0.2 delay:0.2 options:0 animations:^{
                _homebaseText.attributedText = jamText;
                _homebaseText.alpha = 1.0;
                _homebaseText.textAlignment = NSTextAlignmentCenter;
                
                [self.view bringSubviewToFront:_homebaseText];
            } completion:^(BOOL finished) { self.view.userInteractionEnabled = true; }];
        }];
        
    } else if (_currentVideo == 1) {
        UIImageView *currIV = [_homebaseImageViewArr objectAtIndex:_currentVideo-1]; // first tutorial picture
        
        [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
            _homebaseText.alpha = 0.0;
            currIV.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
        } completion:nil];
    } else if (_currentVideo == [_homebasePicArr count]+1) { // last picture
        
        // remove all gestures first, then add the dismiss one
        for (UIGestureRecognizer *gr in self.view.gestureRecognizers) {
            [self.view removeGestureRecognizer:gr];
        }
        
        NSAttributedString *endTitle = [[NSMutableAttributedString alloc] initWithString:@"That's it!\n\n" attributes:attributesLarge];
        NSAttributedString *endStr = [[NSMutableAttributedString alloc] initWithString:@"Be sure to check out the Weekly Entries page located in the main menu.\n\nYou may now enter the House Of Jam" attributes:attributesNormal];
        
        NSMutableAttributedString *endText = [[NSMutableAttributedString alloc] init];
        [endText appendAttributedString:endTitle];
        [endText appendAttributedString:endStr];
        
        // Dismiss view, we are done
        // Animate the current image view to the left
        NSInteger currIVNumber = _currentVideo - 1;
        UIImageView *currIV = [_homebaseImageViewArr objectAtIndex:currIVNumber-1];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
            currIV.frame = CGRectMake(-self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height);
            currIV.alpha = 0.0;
        } completion:nil];
        
        [UIView animateWithDuration:0.5 delay:0.2 options:0 animations:^{
            _homebaseText.attributedText = endText;
            _homebaseText.textAlignment = NSTextAlignmentCenter;
            _homebaseText.alpha = 1.0;
            
            CGFloat fixedWidth = _homebaseText.frame.size.width;
            CGSize newSize = [_homebaseText sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
            CGRect newFrame = _homebaseText.frame;
            newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
            _homebaseText.frame = newFrame;
            _homebaseText.center = self.view.center;
            
            [self.view bringSubviewToFront:_homebaseText];
        } completion:^(BOOL finished) {
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leaveTutorial)];
            tapGestureRecognizer.delegate = self;
            tapGestureRecognizer.numberOfTapsRequired = 1;
            [_homebaseText addGestureRecognizer:tapGestureRecognizer];
            [self.view addGestureRecognizer:tapGestureRecognizer];
        }];
        
    } else {
        // Animate the current image view to the left
        NSInteger currIVNumber = _currentVideo - 1;
        
        if (currIVNumber < [_homebaseImageViewArr count]) {
            UIImageView *currIV = [_homebaseImageViewArr objectAtIndex:currIVNumber-1];
            
            [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
                currIV.frame = CGRectMake(-self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height);
                currIV.alpha = 0.0;
            } completion:^(BOOL finished) { }];
            
            UIImageView *nextIV = [_homebaseImageViewArr objectAtIndex:_currentVideo-1];
            // Animate next image in
            [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
                nextIV.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
            } completion:^(BOOL finished) { }];
        }
    }
    _currentVideo += 1;
    
}


- (void)leaveTutorial {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}


@end
