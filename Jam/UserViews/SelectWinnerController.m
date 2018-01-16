//
//  SelectWinnerController.m
//  RailJam
//
//  Created by Ben Ferraro on 7/18/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SelectWinnerController.h"
@implementation SelectWinnerController 


- (void)viewDidLoad {
    [super viewDidLoad];
    SPAM(("\nSelect Winner Controller\n"));
    
    _selectWinnerJammerTable = [[UITableView alloc] init];
    _selectWinnerJammerTable.dataSource = self;
    _selectWinnerJammerTable.delegate = self;
    
    [self.view addSubview:_selectWinnerJammerTable];
    
    [NavigationView showNavView:@"Select Winner" leftButton:nil rightButton:nil view:self.view];
    CGFloat navHeight = [self.view viewWithTag:navBarViewTag].frame.size.height;
    _selectWinnerJammerTable.frame = CGRectMake(0.0, navHeight, self.view.frame.size.width, self.view.frame.size.height-navHeight);
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SPAM(("\nName Touched\n"));
    
    /* When clicked on, go to player profile */
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text; // userName
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Go back to main Screen
    id<SelectWinnerDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(getWinner:jamIndex:jam:)]) {
        [strongDelegate getWinner:cellText jamIndex:self.jamIndex jam:self.selectWinnerSession];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

// This will tell your UITableView how many rows you wish to have in each section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.selectWinnerSession.jammers count];
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
    
    NSString *userNameFromList = [self.selectWinnerSession.jammers objectAtIndex:row]; // set text
    // Check if there is "host involved"
    if ([userNameFromList containsString:@"Host"]) {
        NSArray *array = [userNameFromList componentsSeparatedByString:@" - "];
        userNameFromList = [array objectAtIndex:1];
    }
    cell.textLabel.text = userNameFromList; // set text for cell (userName)
    cell.textLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0]; // set font
    
    
    return cell;
}

@end
