//
//  InviteFriendsController.m
//  RailJam
//
//  Created by Ben Ferraro on 8/3/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
//
//  SelectWinnerController.m
//  RailJam
//
//  Created by Ben Ferraro on 7/18/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InviteFriendsController.h"
@implementation InviteFriendsController


- (void)viewDidLoad {
    [super viewDidLoad];
    SPAM(("\nAdd Friend Controller\n"));
    
    _pickedAFriend = false;
    
    _loggedInFriendListTable = [[UITableView alloc] init];
    _loggedInFriendListTable.dataSource = self;
    _loggedInFriendListTable.delegate = self;
    _loggedInFriendListTable.bounces = false;
    
    if ([_accountsFriendList count] == 0) { // no friends!!
        _loggedInFriendListTable.hidden = true;
        UILabel *noFriendsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width/2, self.view.frame.size.height)];
        noFriendsLabel.text = @"No new friends!";
        noFriendsLabel.textAlignment = NSTextAlignmentCenter;
        noFriendsLabel.numberOfLines = 2;
        noFriendsLabel.center = self.view.center;
        noFriendsLabel.font = [UIFont fontWithName:@"ActionMan" size:30.0];
        [self.view addSubview:noFriendsLabel];
    }
 
    [self.view addSubview:_loggedInFriendListTable];
    
    _backToCreateSesssionButton = [[UIButton alloc] init];
    [_backToCreateSesssionButton setTitle:@"Done" forState:UIControlStateNormal];
    [_backToCreateSesssionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_backToCreateSesssionButton addTarget:self
                     action:@selector(backToCreateSession:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [NavigationView showNavView:@"Invite Friends" leftButton:nil rightButton:_backToCreateSesssionButton view:self.view];
    CGFloat navHeight = [self.view viewWithTag:navBarViewTag].frame.size.height;
    _loggedInFriendListTable.frame = CGRectMake(0.0, navHeight, self.view.frame.size.width, self.view.frame.size.height-navHeight);
    
}


-(IBAction)backToCreateSession:(id)sender {
    if (_pickedAFriend) {
        id<InviteFriendsDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(endInviteFriends)]) {
            [strongDelegate endInviteFriends];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _pickedAFriend = true;
    
    /* When clicked on, go to player profile */
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text; // userName
    
    NSArray *colorArr = [[NSArray alloc] initWithObjects:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.4], // red
                         [UIColor colorWithRed:0.74 green:0.00 blue:1.00 alpha:0.4], // purple
                         [UIColor colorWithRed:0.00 green:0.22 blue:1.00 alpha:0.4], // blue
                         [UIColor colorWithRed:0.00 green:1.00 blue:0.04 alpha:0.4], // green
                         [UIColor colorWithRed:1.00 green:0.96 blue:0.00 alpha:0.4], // yellow
                         [UIColor colorWithRed:1.00 green:0.54 blue:0.00 alpha:0.4], // orange
                         nil];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) { // Selected, Remove
        cell.accessoryType = UITableViewCellAccessoryNone;
        SPAM(("Removed friend\n"));
        
        if (_editingJam) {
            [_extraFriendsArr removeObject:cellText];
        } else {
            [_addFriendsSession.invitedFriends removeObject:cellText];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        
    } else { // Not selected, Add
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        SPAM(("Added friend\n"));

        int ranColor = arc4random_uniform(6); // choose a random color
        cell.backgroundColor = [colorArr objectAtIndex:ranColor];
        
        // If editing, don't change real session list yet
        if (_editingJam) {
            [_extraFriendsArr addObject:cellText];
        } else {
            [_addFriendsSession.invitedFriends addObject:cellText]; // add to invited friend list
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

// This will tell your UITableView how many rows you wish to have in each section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_accountsFriendList count];
}

// This will tell your UITableView what data to put in which cells in your table.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifer = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    // Using a cell identifier will allow your app to reuse cells as they come and go from the screen.
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifer];
    }
    
    // Deciding which data to put into this particular cell.
    // If it the first row, the data input will be "Data1" from the array.
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [_accountsFriendList objectAtIndex:row];
    cell.textLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    
    if ([_addFriendsSession.invitedFriends containsObject:cell.textLabel.text] ||
        [_extraFriendsArr containsObject:cell.textLabel.text]) { // friend is on the list
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        NSArray *colorArr = [[NSArray alloc] initWithObjects:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.4], // red
                             [UIColor colorWithRed:0.74 green:0.00 blue:1.00 alpha:0.4], // purple
                             [UIColor colorWithRed:0.00 green:0.22 blue:1.00 alpha:0.4], // blue
                             [UIColor colorWithRed:0.00 green:1.00 blue:0.04 alpha:0.4], // green
                             [UIColor colorWithRed:1.00 green:0.96 blue:0.00 alpha:0.4], // yellow
                             [UIColor colorWithRed:1.00 green:0.54 blue:0.00 alpha:0.4], // orange
                             nil];
        int ranColor = arc4random_uniform(6); // choose a random color
        cell.backgroundColor = [colorArr objectAtIndex:ranColor];
        if (_editingJam && ![_extraFriendsArr containsObject:cell.textLabel.text]) { // If editing jam, you can not uninvite a person after jam has been created
            cell.userInteractionEnabled = false;
        }
    }
    
    
    return cell;
}

@end
