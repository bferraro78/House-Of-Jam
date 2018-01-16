//
//  DailyMessage.h
//  Jam
//
//  Created by Ben Ferraro on 9/26/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef DailyMessage_h
#define DailyMessage_h
#import <UIKit/UIKit.h>
#import "Constants.h"

@interface DailyMessage : NSObject

+(UITextView*)getDailyMessage:(UIView*)view message:(NSString*)message;

@end

#endif /* DailyMessage_h */
