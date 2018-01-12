//
//  FilterView.h
//  House Of Jam
//
//  Created by james schuler on 12/6/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef FilterView_h
#define FilterView_h
#import <UIKit/UIKit.h>

@protocol FilterViewDelegate;

@interface FilterView : UIViewController <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id <FilterViewDelegate> delegate;

@property NSMutableDictionary *filters;

@property NSString *intRec;
@property NSString *intComp;
@property NSString *intInv;
@property NSString *intSignUp;
@property NSString *intFuture;

// Methods
-(void)setUpFilterView;

@end

@protocol FilterViewDelegate <NSObject>
-(void)dismissFilter:(int)choice;
@end

#endif /* FilterView_h */
