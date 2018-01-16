//
//  FriendListView.h
//  House Of Jam
//
//  Created by james schuler on 12/6/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef FriendListView_h
#define FriendListView_h
#import <UIKit/UIKit.h>
#import "Account.h"
#import "NavigationView.h"
#import "Constants.h"
#import "AlertView.h"
#import "ProfileController.h"

@interface FriendListView : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property BOOL ownProfile; // For accessing friends list vs adding a friend
@property Account *loggedInAccount; // logged in account
@property UITableView *friendListTable;


@end
#endif /* FriendListView_h */
