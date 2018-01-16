//
//  SelectWinnerController.h
//  RailJam
//
//  Created by Ben Ferraro on 7/18/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef SelectWinnerController_h
#define SelectWinnerController_h
#import <UIKit/UIKit.h>
#import "Account.h"
#import "Session.h"
#import "Constants.h"
#import "NavigationView.h"

@protocol SelectWinnerDelegate;

@interface SelectWinnerController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) id <SelectWinnerDelegate> delegate;

/* Session being Ended */
@property Session *selectWinnerSession;
@property NSInteger jamIndex;

/* Table View */
@property (strong, nonatomic) IBOutlet UITableView *selectWinnerJammerTable;

/* Winner Label */
@property (strong, nonatomic) IBOutlet UILabel *selectWinnerLabel;

@end

@protocol SelectWinnerDelegate <NSObject>
-(void)getWinner:(NSString*)winner jamIndex:(NSInteger)jamIndex jam:(Session*)jam;
@end

#endif /* SelectWinnerController_h */
