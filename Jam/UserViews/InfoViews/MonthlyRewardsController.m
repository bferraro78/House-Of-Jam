//
//  MonthlyRewardsController.m
//  House Of Jam
//
//  Created by james schuler on 11/13/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MonthlyRewardsController.h"

@implementation MonthlyRewardsController

/* Spacing in text views */
- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    return 8; // Line spacing of 19 is roughly equivalent to 5 here.
}

/* Information view (Point System, ) */
-(void)showRewardsView:(NSMutableAttributedString*)text {
    
    // Top Title
    UILabel *topTitle = [[UILabel alloc] init];
    if (self.view.frame.size.height == 812.0) { // iphonex
        topTitle.frame = CGRectMake(10.0, 35.0, self.view.frame.size.width, 50.0);
    } else {
        topTitle.frame = CGRectMake(10.0, 25.0, self.view.frame.size.width, 50.0);
    }
    
    topTitle.font = [UIFont fontWithName:@"ActionMan-Bold" size:20.0];
    topTitle.textColor = [UIColor whiteColor];
    topTitle.text = @"Point System:";
    topTitle.textAlignment = NSTextAlignmentLeft;
    topTitle.numberOfLines = 2;
    
    // Exit button
    UIButton *exitInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0,
                                                                          self.view.frame.size.height-70.0,
                                                                          self.view.frame.size.width,
                                                                          40.0)];
    exitInfoButton.backgroundColor = [UIColor blackColor];
    [exitInfoButton setTitle:@"Exit" forState:UIControlStateNormal];
    exitInfoButton.titleLabel.textColor = [UIColor whiteColor];
    exitInfoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    exitInfoButton.titleLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    [exitInfoButton addTarget:self
                       action:@selector(voidRewards)
             forControlEvents:UIControlEventTouchUpInside];
    
    // Rules box
    float textBoxHeight = self.view.frame.size.height/3; 
    UITextView *infoText = [[UITextView alloc] init];
    infoText.frame = CGRectMake(10.0, topTitle.frame.origin.y+45.0, self.view.frame.size.width-20.0, textBoxHeight);
    infoText.textColor = [UIColor whiteColor];
    infoText.backgroundColor = [UIColor clearColor];
    infoText.layer.cornerRadius = 3;
    infoText.clipsToBounds = true;
    infoText.editable = false;
    infoText.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    infoText.layer.borderWidth = 2.0;
    infoText.layer.borderColor = [[UIColor blackColor] CGColor];
    infoText.bounces = false;
    infoText.layoutManager.delegate = self; // line spacing
    infoText.attributedText = text;
    
    // Bottom Title
    UILabel *bottomTitle = [[UILabel alloc] init];
    bottomTitle.frame = CGRectMake(10.0, (infoText.frame.origin.y+infoText.frame.size.height+5.0), self.view.frame.size.width, 50.0);
    
    bottomTitle.font = [UIFont fontWithName:@"ActionMan-Bold" size:20.0];
    bottomTitle.textColor = [UIColor whiteColor];
    bottomTitle.text = @"Monthly Rewards:";
    bottomTitle.textAlignment = NSTextAlignmentLeft;
    
    // Bottom Title
    UILabel *noRewards = [[UILabel alloc] init];
    noRewards.frame = CGRectMake(0.0, (bottomTitle.frame.origin.y+100.0), self.view.frame.size.width, 40.0);
    
    noRewards.font = [UIFont fontWithName:@"ActionMan" size:18.0];
    noRewards.textColor = [UIColor whiteColor];
    noRewards.text = @"Monthly Rewards to come!";
    noRewards.textAlignment = NSTextAlignmentCenter;
    
    // add sub views
    [self.view addSubview:exitInfoButton];
    [self.view addSubview:infoText];
    [self.view addSubview:topTitle];
    [self.view addSubview:bottomTitle];
    [self.view addSubview:noRewards];
}

-(void)voidRewards {
    id<MonthlyRewardsControllerDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(dismissInfo)]) {
        [strongDelegate dismissInfo];
    }
}

@end
