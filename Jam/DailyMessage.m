//
//  DailyMessage.m
//  Jam
//
//  Created by Ben Ferraro on 9/26/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DailyMessage.h"
@implementation DailyMessage


+(UITextView*)getDailyMessage:(UIView*)view message:(NSString*)message {

    /* Attributed Strings for Daily Message */
    UIColor *IGColor = [UIColor yellowColor];
    NSDictionary *attributesIG =  @{ NSFontAttributeName : [UIFont fontWithName:@"Noteworthy-Bold" size:22.0],
                                    NSForegroundColorAttributeName : IGColor
                                    };
    NSDictionary *attributesBlackLarge = @{
                                      NSFontAttributeName : [UIFont fontWithName:@"Noteworthy-Bold" size:23.0],
                                      NSForegroundColorAttributeName : [UIColor blackColor]
                                      };
    NSDictionary *attributesBlackReg = @{
                                           NSFontAttributeName : [UIFont fontWithName:@"Noteworthy-Bold" size:18.0],
                                           NSForegroundColorAttributeName : [UIColor blackColor]
                                           };
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter]; // centers string
    
    NSMutableAttributedString *dm = [[NSMutableAttributedString alloc] initWithString:@"Daily Message Board\n" attributes:attributesBlackLarge];
    NSMutableAttributedString *IGName = [[NSMutableAttributedString alloc] initWithString:@"IG: --> @JamCommunity\n\n" attributes:attributesIG];
    
    // New lines in JSON are "\\n" - must replace this to be \n
    NSString *oldDM = [NSString stringWithString:message];
    oldDM = [oldDM stringByReplacingOccurrencesOfString:@"\\n"
                                             withString:@"\n"];
    NSMutableAttributedString *messageOnBoard = [[NSMutableAttributedString alloc] initWithString:oldDM attributes:attributesBlackReg];
    
    NSMutableAttributedString *keepOn = [[NSMutableAttributedString alloc] initWithString:@"\n\nKeep on Jamming" attributes:attributesBlackLarge];
    
    [IGName addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [IGName length])];
    [messageOnBoard addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [messageOnBoard length])];
    [dm addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [dm length])];
    [keepOn addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [keepOn length])];
    
    [dm appendAttributedString:IGName];
    [dm appendAttributedString:messageOnBoard];
    [dm appendAttributedString:keepOn];
    
    UITextView *tv = [[UITextView alloc] init];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    if (screenHeight > 810.0) { // ipads/iphonex
        tv.frame = CGRectMake(10.0, 60.0, view.frame.size.width-20.0, view.frame.size.height/1.5);
    } else { // not ipads (Iphone 7plus is height = 736.0)
        tv.frame = CGRectMake(10.0, 40.0, view.frame.size.width-20.0, view.frame.size.height/1.2);
    }
    
    tv.backgroundColor = [UIColor clearColor];
    tv.layer.borderColor = [[UIColor brownColor] CGColor];
    tv.layer.borderWidth = 2.0f;
    tv.textAlignment = NSTextAlignmentCenter;
    tv.attributedText = dm;
    tv.tag = dailyMessageViewTag;
    tv.editable = false;
    tv.clipsToBounds = true;
    tv.bounces = false;
    tv.layer.cornerRadius = 3;
    
    CGRect frame = tv.frame;
    frame.size.height = tv.contentSize.height;
    tv.frame = frame;
    
    tv.translatesAutoresizingMaskIntoConstraints = true;
    tv.scrollEnabled = false;
    
    if (tv.frame.size.height > screenHeight-60.0) {
        CGRect frame = tv.frame;
        if (screenHeight > 810.0) { // ipads/iphonex
            frame.size.height = screenHeight-70.0;
        } else { // not ipads (Iphone 7plus is height = 736.0)
            frame.size.height = screenHeight-50.0;
        }

        tv.frame = frame;
        tv.scrollEnabled = true;
    }
    
    // Make sure bullitin background is large enough
    UIImageView *bullitin = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -50.0, tv.frame.size.width+150.0, tv.contentSize.height+100.0)];
    bullitin.image = [UIImage imageNamed:@"DMbackground.jpg"];
    [tv addSubview:bullitin];
    [tv sendSubviewToBack:bullitin];
    
    return tv;
}

@end
