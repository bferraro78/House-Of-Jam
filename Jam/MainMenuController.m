//
//  MainMenuController.m
//  Jam
//
//  Created by Ben Ferraro on 9/11/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainMenuController.h"
@implementation MainMenuController

-(void)viewDidLoad {

    _menuOptions = [[NSMutableArray alloc] initWithArray:@[@"Weekly Entries", @"Submit Entry", @"End Jam", @"View Profile", @"Edit Profile", @"Search Profiles", @"Monthly Rewards", @"Daily Message", @"Tutorial", @"Log Out"]];

    self.view.backgroundColor = [UIColor darkGrayColor];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,
                                                                self.tableView.frame.size.width, 300.0)];
    
    UIImageView *skateDeck = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0,
                                                                           footView.frame.size.width/2, 300.0)];
    skateDeck.image = [UIImage imageNamed:@"Bonsai.png"];
    skateDeck.contentMode = UIViewContentModeScaleAspectFit;
    skateDeck.alpha = 0.5;
    
    [footView addSubview:skateDeck];
    
    self.tableView.tableFooterView = footView;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text; // Menu Option
    
    if ([cellText isEqualToString:@"View Profile"]) {
        id<MenuDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(menuOption:)]) {
            [strongDelegate menuOption:@"View Profile"];
        }
    } else if ([cellText isEqualToString:@"Edit Profile"]) {
        id<MenuDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(menuOption:)]) {
            [strongDelegate menuOption:@"Edit Profile"];
        }
    } else if ([cellText isEqualToString:@"Weekly Entries"]) {
        id<MenuDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(menuOption:)]) {
            [strongDelegate menuOption:@"Weekly Entries"];
        }
    } else if ([cellText isEqualToString:@"Submit Entry"]) {
        id<MenuDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(menuOption:)]) {
            [strongDelegate menuOption:@"Submit Entry"];
        }
    } else if ([cellText isEqualToString:@"End Jam"]) {
        id<MenuDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(menuOption:)]) {
            [strongDelegate menuOption:@"End Jam"];
        }
    } else if ([cellText isEqualToString:@"Search Profiles"]) {
        id<MenuDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(menuOption:)]) {
            [strongDelegate menuOption:@"Search Profiles"];
        }
    } else if ([cellText isEqualToString:@"Log Out"]) {
        id<MenuDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(menuOption:)]) {
            [strongDelegate menuOption:@"Log Out"];
        }
    } else if ([cellText isEqualToString:@"Daily Message"]) {
        id<MenuDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(menuOption:)]) {
            [strongDelegate menuOption:@"Daily Message"];
        }
    } else if ([cellText isEqualToString:@"Monthly Rewards"]) {
        id<MenuDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(menuOption:)]) {
            [strongDelegate menuOption:@"Monthly Rewards"];
        }
    } else if ([cellText isEqualToString:@"Tutorial"]) {
        id<MenuDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(menuOption:)]) {
            [strongDelegate menuOption:@"Tutorial"];
        }
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_menuOptions count];

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor darkGrayColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifer = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    // Using a cell identifier will allow your app to reuse cells as they come and go from the screen.
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifer];
    }
    
    // Deciding which data to put into this particular cell.
    // If it the first row, the data input will be "Data1" from the array.
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [_menuOptions objectAtIndex:row];
    if ([cell.textLabel.text isEqualToString:@"Weekly Entries"]) {
        cell.textLabel.font = [UIFont fontWithName:@"ActionMan-Bold" size:18.0];
    } else {
        cell.textLabel.font = [UIFont fontWithName:@"ActionMan" size:18.0];
    }
    
    cell.textLabel.textColor= [UIColor lightGrayColor];
    
    return cell;
}

@end
