//
//  MonthlyRewardsController.h
//  House Of Jam
//
//  Created by james schuler on 11/13/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef MonthlyRewardsController_h
#define MonthlyRewardsController_h
#import <UIKit/UIKit.h>

@protocol MonthlyRewardsControllerDelegate;

@interface MonthlyRewardsController : UIViewController <NSLayoutManagerDelegate>

@property (weak, nonatomic) id <MonthlyRewardsControllerDelegate> delegate;

-(void)showRewardsView:(NSMutableAttributedString*)text;
-(void)voidRewards;

@end

@protocol MonthlyRewardsControllerDelegate <NSObject>
-(void)dismissInfo;
@end

#endif /* MonthlyRewardsController_h */
