//
//  SearchView.h
//  House Of Jam
//
//  Created by james schuler on 12/4/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef SearchView_h
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "AlertView.h"
#import "Account.h"
#import "ProfileController.h"

@import SkyFloatingLabelTextField;
@import SVProgressHUD;

@protocol SearchViewDelegate;

@interface SearchView : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) id <SearchViewDelegate> delegate;

@property Account *mainAccount;

@property NSArray *likelySearchAccounts;
@property UITableView *searchTable;



// Methods
-(void)loadSearchContent;

@end

@protocol SearchViewDelegate <NSObject>
-(void)dismissSearch;
@end

#endif /* SearchView_h */
