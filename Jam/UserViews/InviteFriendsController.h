//
//  InviteFriendsController.h
//  RailJam
//
//  Created by Ben Ferraro on 8/3/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef InviteFriendsController_h
#define InviteFriendsController_h
#import <UIKit/UIKit.h>
#include <stdlib.h>
#import "Session.h"
#import "NavigationView.h"

@protocol InviteFriendsDelegate;

@interface InviteFriendsController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) id <InviteFriendsDelegate> delegate;

/* Session being created, add friends to sessions.invitedFriends */
@property Session *addFriendsSession;

/* Friend List from logged in account */
@property NSMutableArray *accountsFriendList;
@property NSMutableArray *extraFriendsArr;

@property BOOL editingJam; // currently editing a jam

/* Table View */
@property (strong, nonatomic) IBOutlet UITableView *loggedInFriendListTable;

@property (strong, nonatomic) IBOutlet UILabel *inviteFriendsLabel;

@property (strong, nonatomic) IBOutlet UIButton *backToCreateSesssionButton;

@property BOOL pickedAFriend;

@end

@protocol InviteFriendsDelegate <NSObject>
-(void)endInviteFriends;
@end

#endif /* InviteFriendsController_h */
