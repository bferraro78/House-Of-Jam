//
//  FriendListView.m
//  House Of Jam
//
//  Created by james schuler on 12/6/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FriendListView.h"

@implementation FriendListView

-(void)viewDidLoad {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _friendListTable = [[UITableView alloc] init];
    _friendListTable.dataSource = self;
    _friendListTable.delegate = self;
    _friendListTable.bounces = false;
    
    if ([_loggedInAccount.friendsList count] == 0) { // no friends!!
        _friendListTable.hidden = true;
        UILabel *noFriendsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width/2, self.view.frame.size.height)];
        noFriendsLabel.text = @"No new friends!";
        noFriendsLabel.textAlignment = NSTextAlignmentCenter;
        noFriendsLabel.numberOfLines = 2;
        noFriendsLabel.center = self.view.center;
        noFriendsLabel.font = [UIFont fontWithName:@"ActionMan" size:30.0];
        [self.view addSubview:noFriendsLabel];
    }
    
    [self.view addSubview:_friendListTable];
    
    UIButton *backToProfile = [[UIButton alloc] init];
    [backToProfile setBackgroundImage:[UIImage imageNamed:@"backX"] forState:UIControlStateNormal];
    [backToProfile addTarget:self action:@selector(backToProfile) forControlEvents:UIControlEventTouchUpInside];
    
    [NavigationView showNavView:@"Friends" leftButton:backToProfile rightButton:nil view:self.view];
    
    CGFloat navHeight = [self.view viewWithTag:navBarViewTag].frame.size.height;
    _friendListTable.frame = CGRectMake(0.0, navHeight, self.view.frame.size.width, self.view.frame.size.height-navHeight);
    
}

-(void)backToProfile {
    [self dismissViewControllerAnimated:YES completion:nil];
}


/** Table View Delegates **/
/* Side swipe kick Jammer table delegates */
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL cellEditable = false;
    if (_ownProfile) {
        cellEditable = true;
    }
    return cellEditable;
}

-(NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    UITableViewRowAction *kickJammer = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Remove" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath]; // Cell
        NSString *userName = cell.textLabel.text; // cell text
        
        UIAlertController *alertControllerKick = [UIAlertController
                                                  alertControllerWithTitle:@"Remove Friend?"
                                                  message:nil
                                                  preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               
                                                               // Remove Friend
                                                               [AlertView showAlertTab:@"Removing Friend" view:self.view];
                                                               
                                                               if ([_loggedInAccount.friendsList containsObject:userName]) {
                                                                   [_loggedInAccount.friendsList removeObject:userName];
                                                                   [_loggedInAccount updateAccount:kBaseURL message:_loggedInAccount._accountid];
                                                                   [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                                               }
                                                           }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) { /* Do nothing */ }];
        
        [alertControllerKick addAction:okayAction];
        [alertControllerKick addAction:cancelAction];
        
        [self presentViewController:alertControllerKick animated:YES completion:nil];
    }];
    
    kickJammer.backgroundColor = [UIColor redColor];
    return @[kickJammer];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text; // userName
    
    Account *tmpAccount = [[Account alloc] init];
    
    [AlertView showAlertTab:@"Loading profile..." view:self.view];
    
    [Account loadAccount:kBaseURL userName:cellText initialLoad:@"no" message:_loggedInAccount._accountid
                callback:^(NSError *error, BOOL success, NSDictionary *responseAccount, NSInteger statusCode) {
                    /* Must do segue in main thread */
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success && [responseAccount objectForKey:@"userName"] != nil) {
                            SPAM(("Got Account success"));
                            
                            /* Init tmpAccount with Sign Up's account info */
                            [tmpAccount initWithDictionary:responseAccount];
                            
                            ProfileController *pvc = [[ProfileController alloc] init];
                            pvc.profileAccount = tmpAccount; // user of profile we clicked on (loaded from DB)
                            pvc.loggedInAccount = _loggedInAccount; // logged in user
                            
                            /* Go to profile */
                            [self presentViewController:pvc animated:true completion:nil];
                        } else {
                            if (!success) {
                                [AlertView showAlertTab:@"Could not load account..." view:self.view];
                            }
                        }
                    });
                }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_loggedInAccount.friendsList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifer = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    // Using a cell identifier will allow your app to reuse cells as they come and go from the screen.
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifer];
    }
    
    // Deciding which data to put into this particular cell.
    // If it the first row, the data input will be "Data1" from the array.
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [_loggedInAccount.friendsList objectAtIndex:row];
    cell.textLabel.textColor = [UIColor blackColor];
//    cell.textLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0]; // set font
    
    return cell;
}


@end
