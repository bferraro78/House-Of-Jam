//
//  MainMenuRight.m
//  Jam
//
//  Created by Ben Ferraro on 10/19/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainMenuRight.h"
@implementation MainMenuRight

-(void)viewDidLoad {
    
    _menuOptions = [[NSMutableArray alloc] initWithArray:@[@"Mark a location", @"Create a competition", @"Hosting Info", @"Competition Game Rules",]];
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
//    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,
//                                                                self.tableView.frame.size.width, 300.0)];
//
//    UIImageView *skateDeck = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0,
//                                                                           footView.frame.size.width/2, 300.0)];
//    skateDeck.image = [UIImage imageNamed:@"risingSun.png"];
//    skateDeck.contentMode = UIViewContentModeScaleAspectFill;
//    skateDeck.alpha = 0.5;
//
//    [footView addSubview:skateDeck];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text; // Menu Option
    
    if ([cellText isEqualToString:@"Mark a location"]) {
        id<MenuRightDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(menuRightOption:)]) {
            [strongDelegate menuRightOption:@"Mark a location"];
        }
    } else if ([cellText isEqualToString:@"Create a competition"]) {
        id<MenuRightDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(menuRightOption:)]) {
            [strongDelegate menuRightOption:@"Create a competition"];
        }
    } else if ([cellText isEqualToString:@"Hosting Info"]) {
        id<MenuRightDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(menuRightOption:)]) {
            [strongDelegate menuRightOption:@"Hosting Info"];
        }
    } else if ([cellText isEqualToString:@"Competition Game Rules"]) {
        id<MenuRightDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(menuRightOption:)]) {
            [strongDelegate menuRightOption:@"Competition Game Rules"];
        }
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView
numberOfRowsInSection:(NSInteger)section {
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
    if ([cell.textLabel.text isEqualToString:@"Mark a location"] ||
        [cell.textLabel.text isEqualToString:@"Create a competition"]) {
        cell.textLabel.font = [UIFont fontWithName:@"ActionMan-Bold" size:18.0];
    } else {
        cell.textLabel.font = [UIFont fontWithName:@"ActionMan" size:18.0];
    }
    cell.textLabel.textColor= [UIColor lightGrayColor];
    
    return cell;
}

@end
