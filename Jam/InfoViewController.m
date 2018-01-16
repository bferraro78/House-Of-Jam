//
//  InfoViewController.m
//  Jam
//
//  Created by james schuler on 11/7/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InfoViewController.h"

/** General Info Template, takes a attributed string to print out info on a topic
    Currently used for "Jam Info" and Competitive Rules **/
@implementation InfoViewController

/* Spacing in text views */
- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    return 8; // Line spacing of 19 is roughly equivalent to 5 here.
}

/* Information view Text/Title */
-(void)showInfoView:(NSMutableAttributedString*)text title:(NSString*)title {
    
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
                       action:@selector(voidInfo)
             forControlEvents:UIControlEventTouchUpInside];
    
    // Rules box
    UITextView *infoText = [[UITextView alloc] init];
    if (self.view.frame.size.height == 812.0) { // iphonex
        float textBoxHeight = (exitInfoButton.frame.origin.y - 8.0)-(45.0);
        infoText.frame = CGRectMake(10.0, 45.0, self.view.frame.size.width-20.0, textBoxHeight);
    } else {
        float textBoxHeight = (exitInfoButton.frame.origin.y - 8.0)-(25.0);
        infoText.frame = CGRectMake(10.0, 25.0, self.view.frame.size.width-20.0, textBoxHeight);
    }
    
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
    
    // add sub views
    [self.view addSubview:exitInfoButton];
    [self.view addSubview:infoText];
    
}

-(void)voidInfo {
    id<InfoViewControllerDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(dismissInfo)]) {
        [strongDelegate dismissInfo];
    }
}

@end
