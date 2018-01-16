//
//  SearchView.m
//  House Of Jam
//
//  Created by james schuler on 12/4/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchView.h"
@implementation SearchView

NSInteger const exitSearchButtonTag = 9001;
NSInteger const searchProfileButtonTag = 9002;
NSInteger const searchProfileTextBarTag = 9003;

-(void)viewDidLoad {
    _likelySearchAccounts = [[NSArray alloc] init];

}

-(void)loadSearchContent {
    SPAM(("\nloadSearchContentn\n"));
    
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                  0.0,
                                                                  self.view.frame.size.width,
                                                                  self.view.frame.size.height)];
    
    SkyFloatingLabelTextField *searchBar = [[SkyFloatingLabelTextField alloc] init];
    
    if (self.view.frame.size.height < 800.0) { // iphones
        searchBar.frame = CGRectMake(10.0, 60.0, self.view.frame.size.width-20.0, 40.0);
    } else { // ipad/iphoneX
        searchBar.frame = CGRectMake(10.0, 85.0, self.view.frame.size.width-20.0, 40.0);
    }
    
    searchBar.tag = searchProfileTextBarTag;
    searchBar.delegate = self;
    searchBar.placeholderColor = [UIColor whiteColor];
    searchBar.placeholder = @"Search Profile (case sensitive)";
    searchBar.titleColor = [UIColor whiteColor];
    searchBar.selectedTitleColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    searchBar.titleColor = [UIColor whiteColor];
    searchBar.selectedLineColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:245.0/255.0 alpha:1.0];
    searchBar.textColor = [UIColor whiteColor];
    // Search Bar autocorrect, capitalization, etc...
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0,
                                                                        searchBar.frame.origin.y+55.0,
                                                                        self.view.frame.size.width,
                                                                        40.0)];
    searchButton.tag = searchProfileButtonTag;
    searchButton.backgroundColor = [UIColor blackColor];
    [searchButton setTitle:@"Search" forState:UIControlStateNormal];
    searchButton.titleLabel.textColor = [UIColor whiteColor];
    searchButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    searchButton.titleLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    [searchButton addTarget:self
                     action:@selector(executeSearch)
           forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *exitSearchButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0,
                                                                            searchButton.frame.origin.y+45.0,
                                                                            self.view.frame.size.width,
                                                                            40.0)];
    exitSearchButton.tag = exitSearchButtonTag;
    exitSearchButton.backgroundColor = [UIColor blackColor];
    [exitSearchButton setTitle:@"Exit" forState:UIControlStateNormal];
    exitSearchButton.titleLabel.textColor = [UIColor whiteColor];
    exitSearchButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    exitSearchButton.titleLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    [exitSearchButton addTarget:self
                         action:@selector(dismissSearch)
               forControlEvents:UIControlEventTouchUpInside];
    
    
    /* Table */
    _searchTable = [[UITableView alloc] initWithFrame:CGRectMake(10.0, exitSearchButton.frame.origin.y+50.0,
                                                                 self.view.frame.size.width-20.0,
                                                                 0.0)];
    _searchTable.dataSource = self;
    _searchTable.delegate = self;
    _searchTable.bounces = false;
    _searchTable.backgroundColor = [UIColor clearColor];
    _searchTable.separatorColor = [UIColor clearColor];
    _searchTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _searchTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [searchView addSubview:searchBar];
    [searchView addSubview:searchButton];
    [searchView addSubview:exitSearchButton];
    [searchView addSubview:_searchTable];
    
    [self.view addSubview:searchView];
    
    /* For Dismissing keyboard */
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

// Delegate method from SearchView.m
-(void)executeSearch {
    
    if (_searchTable.frame.size.height < 0.0) {
        [self dismissSearchTable]; // close search table
    }
    
    [self.view viewWithTag:searchProfileButtonTag].userInteractionEnabled = false; // search button
    [self performSelector:@selector(activateSearch) withObject:nil afterDelay:3.0];
    
    SkyFloatingLabelTextField *searchBar = (SkyFloatingLabelTextField *)[self.view viewWithTag:searchProfileTextBarTag];
    NSString *searchProfile = searchBar.text;
    
    if ([searchProfile length] == 0) {
        [AlertView showAlertTab:@"Search is blank" view:self.view];
        [self.view viewWithTag:searchProfileButtonTag].userInteractionEnabled = true;
    } else {
        
        // progress bar
        [SVProgressHUD showWithStatus:@"Loading Profile"];
        
        // Create a new DB method for searching, if only one name comes back, then load the profile -  a perfect match, else
        // display top names that the DB brings back
        [Account searchAccounts:searchProfile message:_mainAccount._accountid callback:^(NSError *error, BOOL success, NSArray *responseArray, NSInteger statusCode) {
            runOnMainThread(^{
                [self.view viewWithTag:searchProfileButtonTag].userInteractionEnabled = true; // search button usable again
                
                // Dismiss Bar
                [SVProgressHUD dismiss];
                
                // Account(s) found
                if (success && [responseArray count] > 0) {
                    
                    if (statusCode == 901) { // Perfect Match
                        
                        NSDictionary *perfectMatchAcc = [responseArray firstObject]; // first and only object in accounts searched
                        
                        /* Init tmpAccount with Sign Up's account info */
                        Account *tmpAccount = [[Account alloc] init];
                        [tmpAccount initWithDictionary:perfectMatchAcc];
                        
                        NSString * storyboardName = @"Main";
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                        ProfileController * pc = [storyboard instantiateViewControllerWithIdentifier:@"ProfileController"];
                        
                        pc.profileAccount = tmpAccount; // Same account in this particular setting
                        pc.loggedInAccount = _mainAccount;
                        
                        [self presentViewController:pc animated:true completion:nil];
                    } else { // Display all accounts recieved in a table view
                        
                        // Load new userNames into table
                        _likelySearchAccounts = [[NSArray alloc] initWithArray:responseArray];
                        [_searchTable reloadData];
                        
                        [UIView transitionWithView:self.view
                                          duration:0.3
                                           options:UIViewAnimationOptionCurveEaseIn
                                        animations:^ {
                                            _searchTable.frame = CGRectMake(10.0, [self.view viewWithTag:exitSearchButtonTag].frame.origin.y+50.0,
                                                                            self.view.frame.size.width-20.0,
                                                                            self.view.frame.size.height/2.5);
                                        }
                                        completion:nil];
                    }
                } else { // account not found or error
                    
                    [self dismissSearchTable];
                    
                    if (!success) {
                        [AlertView showAlertTab:@"Could not load the account..." view:self.view];
                    } else {
                        [AlertView showAlertTab:@"No Accout exists with that Username" view:self.view];
                    }
                    
                }
                
            }); // end async
        }];
    }
}

// After 3 seconds, reactivate the search button
-(void)activateSearch {
    [self.view viewWithTag:searchProfileButtonTag].userInteractionEnabled = true; // search button
}

-(void)dismissSearchTable {
    [UIView transitionWithView:self.view
                      duration:0.2
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^ {
                        _searchTable.frame = CGRectMake(10.0, [self.view viewWithTag:exitSearchButtonTag].frame.origin.y+50.0,
                                                        self.view.frame.size.width-20.0,
                                                        0.0);
                    }
                    completion:^(BOOL finished) { }];
}

-(void)dismissSearch {
    id<SearchViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(dismissSearch)]) {
        [strongDelegate dismissSearch];
    }
}

/* Table View Delegates*/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /* When clicked on, go to player profile */
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text; // userName
    
    [AlertView showAlertTab:@"Loading profile..." view:self.view];
    
    [Account loadAccount:kBaseURL userName:cellText initialLoad:@"no" message:_mainAccount._accountid callback:^(NSError *error, BOOL success, NSDictionary *responseAccount, NSInteger statusCode) {
        runOnMainThread(^{
            if (success && [responseAccount objectForKey:@"userName"] != nil) {
                /* Init tmpAccount with Sign Up's account info */
                Account *tmpAccount = [[Account alloc] init];
                [tmpAccount initWithDictionary:responseAccount];
                
                NSString * storyboardName = @"Main";
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                ProfileController * pc = [storyboard instantiateViewControllerWithIdentifier:@"ProfileController"];
                
                pc.profileAccount = tmpAccount; // Same account in this particular setting
                pc.loggedInAccount = _mainAccount;
                
                [self presentViewController:pc animated:true completion:nil];
                
                [self dismissSearchTable];
            }  else {
                [AlertView showAlertTab:@"Could not load account..." view:self.view];
            }
        });
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_likelySearchAccounts count];
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
    cell.textLabel.text = [_likelySearchAccounts objectAtIndex:row];
    cell.contentView.backgroundColor = [UIColor lightGrayColor];
    cell.textLabel.textColor = [UIColor blackColor];
    
    return cell;
}

// Text Field Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

void runOnMainThread(void (^block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end
