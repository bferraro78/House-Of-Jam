//
//  InfoViewController.h
//  Jam
//
//  Created by james schuler on 11/7/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef InfoViewController_h
#define InfoViewController_h
#import <UIKit/UIKit.h>

@protocol InfoViewControllerDelegate;

@interface InfoViewController : UIViewController <NSLayoutManagerDelegate>

@property (weak, nonatomic) id <InfoViewControllerDelegate> delegate;

-(void)showInfoView:(NSMutableAttributedString*)text title:(NSString*)title;
-(void)voidInfo;

@end

@protocol InfoViewControllerDelegate <NSObject>
-(void)dismissInfo;
@end


#endif /* InfoViewController_h */
