//
//  FilterView.m
//  House Of Jam
//
//  Created by james schuler on 12/6/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterView.h"

@implementation FilterView

NSInteger const recFilterTag = 0;
NSInteger const compFilterTag = 1;
NSInteger const invFilterTag = 2;
NSInteger const futureFilterTag = 4;
NSInteger const signUpFilterTag = 3;

-(void)setUpFilterView {
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 280.0,
                                                                      185.0, 35.0)];
    doneButton.backgroundColor = [UIColor blackColor];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    doneButton.titleLabel.textColor = [UIColor whiteColor];
    doneButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    doneButton.titleLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    doneButton.layer.cornerRadius = 3;
    [doneButton addTarget:self
                     action:@selector(finalizeFilter)
           forControlEvents:UIControlEventTouchUpInside];
    
    /* Attributed Strings for Legend */
    UIColor *BlackColor = [UIColor blackColor];
    UIColor *GColor = [UIColor greenColor];
    UIColor *RColor = [UIColor redColor];
    UIColor *BlueColor = [UIColor blueColor];
    UIColor *GrayColor = [UIColor grayColor];
    UIColor *InvitedColor =[UIColor colorWithRed:0.00 green:1.00 blue:0.76 alpha:1.0];

    NSDictionary *attributesTitle = @{
                                  NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:21.0],
                                  NSForegroundColorAttributeName : BlackColor
                                  };
    NSDictionary *attributesG = @{
                                  NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:18.0],
                                  NSForegroundColorAttributeName : GColor
                                  };
    NSDictionary *attributesR = @{
                                  NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:18.0],
                                  NSForegroundColorAttributeName : RColor
                                  };
    NSDictionary *attributesBlue = @{
                                     NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:18.0],
                                     NSForegroundColorAttributeName : BlueColor
                                     };
    NSDictionary *attributesInvited = @{
                                        NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:18.0],
                                        NSForegroundColorAttributeName : InvitedColor
                                        };
    NSDictionary *attributesGray = @{
                                     NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:18.0],
                                     NSForegroundColorAttributeName : GrayColor
                                     };
    
    NSAttributedString *TitleStr = [[NSAttributedString alloc] initWithString:@"Jam Filters:" attributes:attributesTitle];
    NSAttributedString *RecreationalStr = [[NSAttributedString alloc] initWithString:@"Recreational - " attributes:attributesBlue];
    NSAttributedString *CompetitionStr = [[NSAttributedString alloc] initWithString:@"Competition - " attributes:attributesR];
    NSAttributedString *InvitedStr = [[NSAttributedString alloc] initWithString:@"Invited - " attributes:attributesInvited];
    NSAttributedString *SignUpStr = [[NSAttributedString alloc] initWithString:@"Signed Up - " attributes:attributesG];
    NSAttributedString *FutureDateStr = [[NSAttributedString alloc] initWithString:@"Future Date - " attributes:attributesGray];
    
    /* Filter Labels */
    UILabel *TitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 10.0, 150.0, 35.0)];
    TitleLabel.attributedText = TitleStr;
    
    UILabel *RecLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, TitleLabel.frame.origin.y+45.0, 150.0, 35.0)];
    RecLabel.attributedText = RecreationalStr;

    UILabel *CompLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, RecLabel.frame.origin.y+45.0, 150.0, 35.0)];
    CompLabel.attributedText = CompetitionStr;
    
    UILabel *InvLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, CompLabel.frame.origin.y+45.0, 150.0, 35.0)];
    InvLabel.attributedText = InvitedStr;
    
    UILabel *SignUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, InvLabel.frame.origin.y+45.0, 150.0, 35.0)];
    SignUpLabel.attributedText = SignUpStr;
    
    UILabel *FutureLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, SignUpLabel.frame.origin.y+45.0, 150.0, 35.0)];
    FutureLabel.attributedText = FutureDateStr;
    
    /* Filter Buttons */
    UIButton *RecFilter = [[UIButton alloc] initWithFrame:CGRectMake(160.0, RecLabel.frame.origin.y, 35.0, 35.0)];
    RecFilter.layer.cornerRadius = 10;
    RecFilter.layer.borderWidth = 1.5f;
    RecFilter.tag = recFilterTag;
    [RecFilter addTarget:self
                  action:@selector(changeFilter:)
             forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *CompFilter = [[UIButton alloc] initWithFrame:CGRectMake(160.0, CompLabel.frame.origin.y, 35.0, 35.0)];
    CompFilter.layer.cornerRadius = 10;
    CompFilter.layer.borderWidth = 1.5f;
    CompFilter.tag = compFilterTag;
    [CompFilter addTarget:self
                   action:@selector(changeFilter:)
             forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *InvFilter = [[UIButton alloc] initWithFrame:CGRectMake(160.0, InvLabel.frame.origin.y, 35.0, 35.0)];
    InvFilter.layer.cornerRadius = 10;
    InvFilter.layer.borderWidth = 1.5f;
    InvFilter.tag = invFilterTag;
    [InvFilter addTarget:self
                  action:@selector(changeFilter:)
             forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *SignUpFilter = [[UIButton alloc] initWithFrame:CGRectMake(160.0, SignUpLabel.frame.origin.y, 35.0, 35.0)];
    SignUpFilter.layer.cornerRadius = 10;
    SignUpFilter.layer.borderWidth = 1.5f;
    SignUpFilter.tag = signUpFilterTag;
    [SignUpFilter addTarget:self
                     action:@selector(changeFilter:)
             forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *FutureFilter = [[UIButton alloc] initWithFrame:CGRectMake(160.0, FutureLabel.frame.origin.y, 35.0, 35.0)];
    FutureFilter.layer.cornerRadius = 10;
    FutureFilter.layer.borderWidth = 1.5f;
    FutureFilter.tag = futureFilterTag;
    [FutureFilter addTarget:self
                     action:@selector(changeFilter:)
             forControlEvents:UIControlEventTouchUpInside];
    
    
    /* Set Init Filter Color */
    if ([_filters[@"recreational"] isEqualToString:@"true"]) {
        RecFilter.backgroundColor = [UIColor greenColor];
        RecFilter.layer.borderColor = [[UIColor clearColor] CGColor];
    } else {
        RecFilter.backgroundColor = [UIColor whiteColor];
        RecFilter.layer.borderColor = [[UIColor blackColor] CGColor];
    }

    if ([_filters[@"competition"] isEqualToString:@"true"]) {
        CompFilter.backgroundColor = [UIColor greenColor];
        CompFilter.layer.borderColor = [[UIColor clearColor] CGColor];
    } else {
        CompFilter.backgroundColor = [UIColor whiteColor];
        CompFilter.layer.borderColor = [[UIColor blackColor] CGColor];
    }
    
    if ([_filters[@"invited"] isEqualToString:@"true"]) {
        InvFilter.backgroundColor = [UIColor greenColor];
        InvFilter.layer.borderColor = [[UIColor clearColor] CGColor];
    } else {
        InvFilter.backgroundColor = [UIColor whiteColor];
        InvFilter.layer.borderColor = [[UIColor blackColor] CGColor];
    }
    
    if ([_filters[@"signedUp"] isEqualToString:@"true"]) {
        SignUpFilter.backgroundColor = [UIColor greenColor];
        SignUpFilter.layer.borderColor = [[UIColor clearColor] CGColor];
    } else {
        SignUpFilter.backgroundColor = [UIColor whiteColor];
        SignUpFilter.layer.borderColor = [[UIColor blackColor] CGColor];
    }
    
    if ([_filters[@"future"] isEqualToString:@"true"]) {
        FutureFilter.backgroundColor = [UIColor greenColor];
        FutureFilter.layer.borderColor = [[UIColor clearColor] CGColor];
    } else {
        FutureFilter.backgroundColor = [UIColor whiteColor];
        FutureFilter.layer.borderColor = [[UIColor blackColor] CGColor];
    }
    
    [self.view addSubview:doneButton];
    [self.view addSubview:TitleLabel];
    [self.view addSubview:RecLabel];
    [self.view addSubview:CompLabel];
    [self.view addSubview:InvLabel];
    [self.view addSubview:SignUpLabel];
    [self.view addSubview:FutureLabel];
    [self.view addSubview:RecFilter];
    [self.view addSubview:CompFilter];
    [self.view addSubview:InvFilter];
    [self.view addSubview:SignUpFilter];
    [self.view addSubview:FutureFilter];
    
    // Keep Intital values;
    _intRec = _filters[@"recreational"];
    _intComp = _filters[@"competition"];
    _intInv = _filters[@"invited"];
    _intSignUp = _filters[@"signedUp"];
    _intFuture = _filters[@"future"];
}


-(void)changeFilter:(UIButton*)filter {
    if (filter.tag == recFilterTag) { // Rec
        if ([_filters[@"recreational"] isEqualToString:@"true"]) { // change to false;
            _filters[@"recreational"] = @"false";
            filter.backgroundColor = [UIColor whiteColor];
            filter.layer.borderColor = [[UIColor blackColor] CGColor];
        } else {
            _filters[@"recreational"] = @"true";
            filter.backgroundColor = [UIColor greenColor];
            filter.layer.borderColor = [[UIColor clearColor] CGColor];
        }
    } else if (filter.tag == compFilterTag) { // Comp
        if ([_filters[@"competition"] isEqualToString:@"true"]) { // change to false;
            _filters[@"competition"] = @"false";
            filter.backgroundColor = [UIColor whiteColor];
            filter.layer.borderColor = [[UIColor blackColor] CGColor];
        } else {
            _filters[@"competition"] = @"true";
            filter.backgroundColor = [UIColor greenColor];
            filter.layer.borderColor = [[UIColor clearColor] CGColor];
        }
    } else if (filter.tag == invFilterTag) { // Inv
        if ([_filters[@"invited"] isEqualToString:@"true"]) { // change to false;
            _filters[@"invited"] = @"false";
            filter.backgroundColor = [UIColor whiteColor];
            filter.layer.borderColor = [[UIColor blackColor] CGColor];
        } else {
            _filters[@"invited"] = @"true";
            filter.backgroundColor = [UIColor greenColor];
            filter.layer.borderColor = [[UIColor clearColor] CGColor];
        }
    } else if (filter.tag == signUpFilterTag) { // Sign Up
        if ([_filters[@"signedUp"] isEqualToString:@"true"]) { // change to false;
            _filters[@"signedUp"] = @"false";
            filter.backgroundColor = [UIColor whiteColor];
            filter.layer.borderColor = [[UIColor blackColor] CGColor];
        } else {
            _filters[@"signedUp"] = @"true";
            filter.backgroundColor = [UIColor greenColor];
            filter.layer.borderColor = [[UIColor clearColor] CGColor];
        }
    } else if (filter.tag == futureFilterTag) { // Future
        if ([_filters[@"future"] isEqualToString:@"true"]) { // change to false;
            _filters[@"future"] = @"false";
            filter.backgroundColor = [UIColor whiteColor];
            filter.layer.borderColor = [[UIColor blackColor] CGColor];
        } else {
            _filters[@"future"] = @"true";
            filter.backgroundColor = [UIColor greenColor];
            filter.layer.borderColor = [[UIColor clearColor] CGColor];
        }
    }
}

// Save Changes
-(void)finalizeFilter {
    int choice = 0;
    if (![_intRec isEqualToString:_filters[@"recreational"]]) {
        choice = 1;
    } else if (![_intComp isEqualToString:_filters[@"competition"]]) {
        choice = 1;
    } else if (![_intInv isEqualToString:_filters[@"invited"]]) {
        choice = 1;
    } else if (![_intSignUp isEqualToString:_filters[@"signedUp"]]) {
        choice = 1;
    } else if (![_intFuture isEqualToString:_filters[@"future"]]) {
        choice = 1;
    }
    
    id<FilterViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(dismissFilter:)]) {
        [strongDelegate dismissFilter:choice];
    }   
}


@end
