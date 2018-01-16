//  ViewController.m
//  RailJam
//
//  Created by Ben Ferraro on 6/22/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

static NSString* const kMarkers = @"markers"; // holds session objects
static NSString* const kFiles = @"files";
static NSString* const kEntryVideos = @"entryVideos";

static NSArray *chooseableQuotes;
static NSMutableDictionary *jamFilters;

/* Log Out User */
-(void)logOut {
    [self.mainAccount updateAccount:kBaseURL message:_mainAccount._accountid];
    
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil]; // aka go back to log in screen
}

/* Updates user when location is found by observing the LocationManager.m locationFound variable */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"locationFound"]) {
        LocationManager *sharedLocationManager = [LocationManager sharedLocationManager];
        if ([sharedLocationManager.locationFound isEqualToString:@"1"]) {
            [AlertView showAlertTab:@"Location Found" view:self.view];
            _centerLat =  sharedLocationManager.userLat; // userLat/Long from LocationManager.m
            _centerLong = sharedLocationManager.userLong;
            // Auto locate camera when position is found
            [_mapView setCamera:[GMSCameraPosition cameraWithLatitude:_centerLat
                                                            longitude:_centerLong
                                                                 zoom:15]];
        }
        
        // Remove Listener, to avoid BAD ACCESS ERROR
        [sharedLocationManager removeObserver:self forKeyPath:@"locationFound"];
    }
}

/* Set up observer for locationFound variable in LocationManager.m */
-(void)setUpLocationFoundObserver:(LocationManager*)sharedLocationManager {
        // KeyPath must match name of varible being changed!
        [sharedLocationManager addObserver:self
                                forKeyPath:@"locationFound"
                                   options:0
                                   context:nil];
        sharedLocationManager.observerAlreadyUsed = true;
        [sharedLocationManager setLocationCoord:^(NSError *error, BOOL success) { }];
}

/* Show alert if location has not been found */
-(void)viewDidAppear:(BOOL)animated {
    // Let user know location is still being calculated
    LocationManager *sharedLocationManager = [LocationManager sharedLocationManager];
    if (sharedLocationManager.userLat == 0 || sharedLocationManager.userLong == 0) {
        [AlertView showAlertTab:@"Location Loading..." view:self.view];
    }
}

/* Set's up inital UI experiance */
-(void)viewDidLoad {
    [super viewDidLoad];
    SPAM(("\nLoading Main Map View...\n\n"));
    
    /* Set Date */
    NSDate *currDate = [NSDate date]; // Get Date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    NSString *stringFromDate = [formatter stringFromDate:currDate];
    _currDate = stringFromDate;
    
    // Local LocationManager Object
    LocationManager *sharedLocationManager = [LocationManager sharedLocationManager];
    
    /* Set up observer for locationFound variable in LocationManager.m */
    if (!sharedLocationManager.observerAlreadyUsed && sharedLocationManager.userLat == 0.0 && sharedLocationManager.userLong == 0.0) {
        [self setUpLocationFoundObserver:sharedLocationManager];
    }

    /* Set Up Map View */
    [self setUpMapView:sharedLocationManager];

    /** Set up Side Menus **/
    [self setUpMainSideMenus];

    /* Update User Account Log In Info */
    [self initialLogInUpdateAccountInfo];
    
    /* Set Up Locaton / UI for main view */
    [self setUpUI];
}

-(void)setUpMapView:(LocationManager*)sharedLocationManager {
    /* Set Location - _centerLat/Long changes when map moves */
    _centerLat =  sharedLocationManager.userLat; // userLat/Long from LocationManager.m
    _centerLong = sharedLocationManager.userLong;
    
    // Create a GMSCameraPosition
    GMSCameraPosition *camera;
    if (_centerLat == 0.0 && _centerLong == 0.0) {
        camera = [GMSCameraPosition cameraWithLatitude:40.7128 // positon over NYC
                                             longitude:-74.0060
                                                  zoom:15];
    } else {
        camera = [GMSCameraPosition cameraWithLatitude:_centerLat // use actual user location
                                             longitude:_centerLong
                                                  zoom:15];
    }
    
    _mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    [self.view addSubview: _mapView]; // add to main view's subview
    
    [_mapView setMinZoom:2 maxZoom:17]; // set min/max zoom
    _mapView.myLocationEnabled = YES;
    _mapView.delegate = self;
    _mapView.settings.myLocationButton = true;
}

/* Update User Account Log In Info */
-(void)initialLogInUpdateAccountInfo {
    /* Remove badge number */
    _mainAccount.badgeNum = [NSNumber numberWithInteger:0];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    /* Send App delegate dev token to DB by adding it and updating account */
    NSData *token = ((AppDelegate *)([UIApplication sharedApplication].delegate)).notificationToken;
    
    if (token != nil) {
        // Make token readable from DB
        const char *tokenBytes = [token bytes];
        NSMutableString* hexToken = [NSMutableString string];
        for (int i = 0; i < [token length]; i++) {
            [hexToken appendFormat:@"%02.2hhX", tokenBytes[i]];
        }
        
        self.mainAccount.notificationToken = hexToken; // set note token
    }
    
    // Update account with
    // 1. notification token
    // 2. updates last logon
    // 3. Badge Number
    [self.mainAccount updateAccount:kBaseURL message:_mainAccount._accountid];

}

/** Set up Side Menus **/
-(void)setUpMainSideMenus {
    // Left side
    MainMenuController *mc = [[MainMenuController alloc] init];
    mc.delegate = self;
    
    CGRect frame = CGRectMake(0.0, 0.0, 400.0, 80.0);
    UILabel *mainMenulabel = [[UILabel alloc] initWithFrame:frame];
    mainMenulabel.font = [UIFont fontWithName:@"ActionMan" size:27.0];
    mainMenulabel.textAlignment = NSTextAlignmentCenter;
    mainMenulabel.textColor = [UIColor blackColor];
    mainMenulabel.text = _mainAccount.userName;
    mc.navigationItem.titleView = mainMenulabel;
    
    UISideMenuNavigationController * slc = [[UISideMenuNavigationController alloc] initWithRootViewController:mc];
    
    // Right side
    MainMenuRight *mcr = [[MainMenuRight alloc] init];
    mcr.delegate = self;
    
    CGRect frameRight = CGRectMake(0.0, 0.0, 400.0, 80.0);
    UILabel *mainMenuRightlabel = [[UILabel alloc] initWithFrame:frameRight];
    mainMenuRightlabel.font = [UIFont fontWithName:@"ActionMan" size:25.0];
    mainMenuRightlabel.textAlignment = NSTextAlignmentCenter;
    mainMenuRightlabel.textColor = [UIColor blackColor];
    mainMenuRightlabel.text = @"Select a Jam Type";
    mcr.navigationItem.titleView = mainMenuRightlabel;
    
    UISideMenuNavigationController* slcr = [[UISideMenuNavigationController alloc] initWithRootViewController:mcr];
    slcr.leftSide = false;
    
    // For both side of menus
    SideMenuManager.menuLeftNavigationController = slc;
    SideMenuManager.menuRightNavigationController = slcr;
    
    SideMenuManager.menuWidth = self.view.frame.size.width*0.75; // how far the menu comes out?
    SideMenuManager.menuFadeStatusBar = false;
    SideMenuManager.menuAnimationBackgroundColor = [UIColor blackColor];
}

/* Set Up Locaton */
-(void)setUpUI {

    /* Set Up Filters */
    jamFilters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"true", @"competition", @"true", @"recreational", @"true", @"invited", @"true", @"signedUp", @"true", @"future", nil];
    
    /* Init local caches of jam locations and pictures */
    _jamSessions = [[NSMutableArray alloc] init]; // Session Objects
    _jamSesssionMarkers = [[NSMutableDictionary alloc] init]; // Marker objects
    _localSignUpPictureCache = [[NSMutableDictionary alloc] init]; // Have the pictures of this jam been loaded?
    
    // Get google's locationButton frame
    UIButton* myLocationButton;
    for (UIView *object in self.mapView.subviews) {
        if([[[object class] description] isEqualToString:@"GMSUISettingsPaddingView"]) {
            for (UIView *v in object.subviews) {
                if ([[[v class] description] isEqualToString:@"GMSUISettingsView"]) {
                    for (UIView *v1 in v.subviews) {
                        if ([[[v1 class] description] isEqualToString:@"GMSx_QTMButton"]) {
                            myLocationButton = (UIButton*)v1;
                        }
                    }
                }
            }
        }
    }
    
    /** Main Screen UI Buttons Set up **/
    
    // Size of stats bar - used (seshButton, menuButton)
    CGFloat statusBarSize = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    /* Menu button */
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = CGRectMake(5.0, statusBarSize+10.0, 40.0, 40.0);
    [self.menuButton addTarget:self
                        action:@selector(showMenu:)
              forControlEvents:UIControlEventTouchUpInside];
    self.menuButton.clipsToBounds = YES;
    self.menuButton.alpha = 0.9;
    [self.menuButton setImage:[UIImage imageNamed:@"HamburgerButton"] forState:UIControlStateNormal];
    
    [_mapView addSubview:self.menuButton];
    
    /* Create Session Button */
    self.seshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.seshButton.frame = CGRectMake(self.view.frame.size.width-55.0, _menuButton.frame.origin.y, 45.0, 45.0);
    [self.seshButton addTarget:self
                        action:@selector(showRightMenu:)
              forControlEvents:UIControlEventTouchUpInside];
    self.seshButton.clipsToBounds = YES;
    self.seshButton.contentMode = UIViewContentModeScaleAspectFill;
    self.seshButton.alpha = 0.9;
    self.seshButton.tag = createJamButtonTag;
    [self.seshButton setBackgroundImage:[UIImage imageNamed:@"J add"] forState:UIControlStateNormal];
    
    [_mapView addSubview:self.seshButton];

    /* Center of Map Marker */
    self.centerOfMapPointer = [UIButton buttonWithType:UIButtonTypeCustom];
    self.centerOfMapPointer.frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
    self.centerOfMapPointer.userInteractionEnabled = false;
    self.centerOfMapPointer.clipsToBounds = YES;
    self.centerOfMapPointer.center = _mapView.center;
    [self.centerOfMapPointer setBackgroundImage:[UIImage imageNamed:@"crosshair.ico"] forState:UIControlStateNormal];
    
    [_mapView addSubview:self.centerOfMapPointer];
    
    /* IG Button */
    self.IGButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.IGButton.frame = CGRectMake(70.0, self.view.frame.size.height-45.0, 35.0, 35.0);
    [self.IGButton addTarget:self
                        action:@selector(IGJam:)
              forControlEvents:UIControlEventTouchUpInside];
    self.IGButton.clipsToBounds = YES;
    self.IGButton.backgroundColor = [UIColor clearColor];
    [self.IGButton setBackgroundImage:[UIImage imageNamed:@"IGPic"] forState:UIControlStateNormal];
    [_mapView addSubview:self.IGButton];
    
    /* Refresh Button */
    self.refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.refreshButton.frame = CGRectMake(myLocationButton.center.x-20.0,
                                          myLocationButton.frame.origin.y-50.0,
                                          40.0, 40.0);
    [self.refreshButton addTarget:self
                           action:@selector(refreshMap:)
                 forControlEvents:UIControlEventTouchUpInside];
    self.refreshButton.contentMode = UIViewContentModeScaleAspectFit;
    self.refreshButton.tag = refreshMapButtonTag;
    [self.refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshMap"] forState:UIControlStateNormal];
    
    [_mapView addSubview:self.refreshButton];

    // Must adjust for blank space at the bottom of the iphoneX
    if (self.view.frame.size.height == 812.0) {
        self.refreshButton.frame = CGRectMake(myLocationButton.center.x-20.0,
                                              myLocationButton.frame.origin.y-85.0,
                                              40.0, 40.0);
        self.IGButton.frame = CGRectMake(70.0, self.view.frame.size.height-80.0, 35.0, 35.0);
    } else {
        self.refreshButton.frame = CGRectMake(myLocationButton.center.x-20.0,
                                              myLocationButton.frame.origin.y-50.0,
                                              40.0, 40.0);
        self.IGButton.frame = CGRectMake(70.0, self.view.frame.size.height-45.0, 35.0, 35.0);
    }
    
    /* Search Address Button */
    self.searchButton = [[UIButton alloc] init];
    self.searchButton.frame = CGRectMake(self.view.frame.size.width-80.0, _seshButton.frame.origin.y+55.0, 70.0, 45.0);
    [self.searchButton addTarget:self
                           action:@selector(searchAddress)
                 forControlEvents:UIControlEventTouchUpInside];
    self.searchButton.layer.borderWidth = 2.5f;
    self.searchButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.searchButton.layer.cornerRadius = 10;
    [self.searchButton setTitle:@"Search Address" forState:UIControlStateNormal];
    [self.searchButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.searchButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.searchButton.titleLabel.numberOfLines = 2;
    self.searchButton.titleLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    
    [_mapView addSubview:self.searchButton];
    
    /* Map Legend Button */
    self.mapLegendButton = [[UIButton alloc] init];
    [self.mapLegendButton setContentEdgeInsets:UIEdgeInsetsMake(-30.0, -30.0, -30.0, -30.0)];
    self.mapLegendButton.frame = CGRectMake(5.0,
                                      self.refreshButton.frame.origin.y,
                                      30.0, 30.0);
    [self.mapLegendButton addTarget:self
                           action:@selector(showMapLegend)
                 forControlEvents:UIControlEventTouchUpInside];
    self.mapLegendButton.contentMode = UIViewContentModeScaleAspectFill;
    [self.mapLegendButton setBackgroundImage:[UIImage imageNamed:@"mapLegend.png"] forState:UIControlStateNormal];
    
    [_mapView addSubview:self.mapLegendButton];

    /* Filter Button */
    self.filterButton = [[UIButton alloc] init];
    self.filterButton.frame = CGRectMake(self.view.frame.size.width-80.0,
                                         self.searchButton.frame.origin.y+55.0,
                                         70.0, 30.0);
    [self.filterButton addTarget:self
                          action:@selector(showFilterView)
                forControlEvents:UIControlEventTouchUpInside];
    self.filterButton.layer.cornerRadius = 10;
    self.filterButton.layer.borderWidth = 2.5f;
    self.filterButton.layer.borderColor = [[UIColor blackColor] CGColor];
    [self.filterButton setTitle:@"Filter" forState:UIControlStateNormal];
    [self.filterButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.filterButton.titleLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    self.filterButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [_mapView addSubview:self.filterButton];

    /* Marketplace Button */
    self.marketPlaceButton = [[UIButton alloc] init];
    self.marketPlaceButton.frame = CGRectMake(self.view.frame.size.width-115.0,
                                         self.filterButton.frame.origin.y+45.0,
                                        105.0, 30.0);
    [self.marketPlaceButton addTarget:self
                          action:@selector(showMarketplace)
                forControlEvents:UIControlEventTouchUpInside];
    self.marketPlaceButton.layer.cornerRadius = 10;
    self.marketPlaceButton.layer.borderWidth = 2.5f;
    self.marketPlaceButton.layer.borderColor = [[UIColor blackColor] CGColor];
    [self.marketPlaceButton setTitle:@"Marketplace" forState:UIControlStateNormal];
    [self.marketPlaceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.marketPlaceButton.titleLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    self.marketPlaceButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_mapView addSubview:self.marketPlaceButton];
    // TODO - world is not ready for the marketplace... 
    self.marketPlaceButton.hidden = true;
    
    /* Load Quotes */
    chooseableQuotes = [[NSArray alloc] initWithObjects:@"To Jam: 1) Means: To relax, or vibe with friends", @"Life is short, stunt it.\n\n-Rod Kimble", @"Out of water I am nothing.\n\n-Duke Kahanamoku", @"Wiping out is an under-appreciated skill.\n\n-Laird Hamilton", @"Style is a natural extension of who you are as a person.\n\n-Mark Richards", @"There are a million ways to surf, and as long as you're smiling you're doing it right.\n\n-Mike Coots", @"If it swells, ride it!\n\n-Random Surfer", @"In skateboarding, you're never bigger than the streets.\n\n-Rob Dyrdek", @"Land on both feet.", @"Don't look back, you're not going that way.\n\n-Unknown", @"Wherever you are, be there totally.\n\n-Eckhart Tolle", @"Those who matter don’t mind, and those who do mind don’t matter.\n\n-Bernard Baruch", @"Shake it off.\n\n-Taylor Swift", @"If I can't do it, it can't be done.\n\n-Curtis Jackson", @"Life is too short to spend it with the wrong people.\n\n-Joel Osteen", @"With the new day comes new strength and new thoughts.\n\n-Eleanor Roosevelt", @"It does not matter how slowly you go as long as you do not stop.\n\n-Confucius", @"It always seems impossible until it's done.\n\n-Nelson Mandela", @"Accept the challenges so that you can feel the exhilaration of victory.\n\n-George Patton", @"Remember to stay hydrated!", nil];
    
    /* Quote Label */
    self.quoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, (self.filterButton.frame.origin.y+35.0),
                                                           self.view.frame.size.width-10.0, 0.0)];
    // Randomly select quote from chooseableQuotes
    int quoteNumber = arc4random() % [chooseableQuotes count];
    self.quoteLabel.text = [chooseableQuotes objectAtIndex:quoteNumber];
    self.quoteLabel.preferredMaxLayoutWidth = self.view.frame.size.width-10.0;
    self.quoteLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.quoteLabel.textAlignment = NSTextAlignmentCenter;
    self.quoteLabel.numberOfLines = 0;
    self.quoteLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
    self.quoteLabel.layer.borderColor = [[UIColor blackColor] CGColor];
    self.quoteLabel.layer.borderWidth = 1.5f;
    self.quoteLabel.layer.cornerRadius = 3;
    self.quoteLabel.alpha = 0.0;
    self.quoteLabel.font = [UIFont fontWithName:@"ActionMan" size:18.0];
    
    _showQuote = true;
    
//    // Auto fit the size if the content
    CGFloat fixedWidth = self.quoteLabel.frame.size.width;
    CGSize newSize = [self.quoteLabel sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = self.quoteLabel.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height+20.0);
    self.quoteLabel.frame = newFrame;

//    CGFloat fixedHeight = self.quote.frame.size.height;
//    CGSize newSizeH = [self.quote sizeThatFits:CGSizeMake(fixedWidth, fixedHeight)];
//    CGRect newFrameH = self.quote.frame;
//    newFrameH.size = CGSizeMake(newSizeH.width+20.0, fmaxf(fixedHeight, newSizeH.height));
//    self.quote.frame = newFrameH;
    
    // Center the quote view
//    CGRect newFrameCenter = self.quote.frame;
//    CGFloat remainingRoom = (self.view.frame.size.width - self.quote.frame.size.width)/2;
//    SPAM(("\nRemaing Room: %f\n", remainingRoom));
//    newFrameCenter.origin.x = remainingRoom;
//    self.quote.frame = newFrameCenter;
    
    self.quoteLabel.translatesAutoresizingMaskIntoConstraints = true;
    
    // With markers with userData containing any info
    [self importJamsFromDB:^(NSError *error, BOOL success, NSArray *responseArray) {
        if (success && responseArray != nil) {
            [self parseAndAddLocations:responseArray toArray:self.jamSessions];
            
            runOnMainThreadWithoutDeadlocking(^{
                /* Create marker objects and place on map */
                [self createAndAddMarkers:false];
            });
        } else {
            /* Loading alert box */
            [AlertView showAlertControllerOkayOption:@"Trouble loading Jams" message:@"Try refreshing the map" view:self];
        }
    }];
    
    /* Show Daily Message */
    [self showDailyMessage];
    
    /* Show greetings */
    [self performSelector:@selector(showGreetings) withObject:nil afterDelay:0.0];
}

-(void)showGreetings {
    NSString *greetings = [[NSString alloc] initWithFormat:@"Greetings %@", _mainAccount.userName];
    [AlertView showAlertTab:greetings view:self.view];
}

/* Show daily message from menu */
-(void)showDailyMessage {
    /* Show Daily Message */
    UITextView *dm = [DailyMessage getDailyMessage:self.view message:_dailyMessage];
    dm.alpha = 0.0;
    
    /* Touch gesture remove daily message */
    UITapGestureRecognizer *tapRemoveDM = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeDM)];
    tapRemoveDM.delegate = self;
    tapRemoveDM.numberOfTapsRequired = 1;
    [dm addGestureRecognizer:tapRemoveDM];
    
    [self.view addSubview:dm];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
        dm.alpha = 1.0;
    } completion:^(BOOL finished) { /* Do nothing */ }];
}

-(void)removeDM {
    [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
        [self.view viewWithTag:dailyMessageViewTag].alpha = 0.0f;
    } completion:^(BOOL finished) {
        [[self.view viewWithTag:dailyMessageViewTag] removeFromSuperview];
        [self showQuoteLabel];
    }];
}

/* Quote Label Methods */
-(void)showQuoteLabel {
    if (_showQuote) { // quote has not been shown yet!
        
        _showQuote = false;
        [_mapView addSubview:self.quoteLabel]; // add quote
        
        [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
            self.quoteLabel.alpha = 1.0;
        } completion:^(BOOL finished) { /* Do nothing */ }];
        
        // remove after a time limit
        [self performSelector:@selector(removeQuoteLabel) withObject:nil afterDelay:5.0]; // DELAY - QUOTE TIMER
    }
}

-(void)removeQuoteLabel {
    [UIView animateWithDuration:2.0 delay:0.0 options:0 animations:^{
        self.quoteLabel.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.quoteLabel removeFromSuperview];
    }];
}

/** Adding sessions to map local objects **/

/* Return true if dateOne is earlier than dateTwo */
-(BOOL)checkIfEarlierStringDate:(NSString*)dateOne date2:(NSString*)dateTwo {
    
    BOOL isDateOneEarlier = false;
    
    NSArray *arrayDateOne = [dateOne componentsSeparatedByString:@"-"];
    int dateOneDay = [[arrayDateOne objectAtIndex:0] intValue];
    int dateOneMonth = [[arrayDateOne objectAtIndex:1] intValue];
    int dateOneYear = [[arrayDateOne objectAtIndex:2] intValue];

    NSArray *arrayDateTwo = [dateTwo componentsSeparatedByString:@"-"];
    int dateTwoDay = [[arrayDateTwo objectAtIndex:0] intValue];
    int dateTwoMonth = [[arrayDateTwo objectAtIndex:1] intValue];
    int dateTwoYear = [[arrayDateTwo objectAtIndex:2] intValue];
    
    if (dateOneYear == dateTwoYear && dateOneMonth == dateTwoMonth && dateOneDay == dateTwoDay) { // dates are equal
        // auto false
    } else {
        if (dateTwoYear >= dateOneYear) { // Check years first
            if (dateTwoMonth >= dateOneMonth) { // months
                if (dateTwoDay >= dateOneDay) { // days
                    isDateOneEarlier = true;
                }
            }
        }
    }
    return isDateOneEarlier;
}

/* Reads all session objects from DB, (stored in self.jamSessions), creates markers, adds to map */
-(void)createAndAddMarkers:(BOOL)isFromPersist {
    SPAM(("\nCreatAndAddMarkers\n"));
    
    [self updateJamStatusBar]; // update progressbar -- 4
    
    for (Session *jam in self.jamSessions) {
        if (jam != nil) {
            /* Check session variable isAdded, if not create it a marker for the session */
            if (jam.isAddedToMap == false) {
                
                // 1. Create Marker object & load its userData
                GMSMarker *tmpMarker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(
                                                                                                [jam.sessionLat doubleValue], [jam.sessionLong doubleValue])];
                // Determine is user is the host / isOutDated / Jam is Today
                BOOL isHost = [jam.sessionHostName isEqualToString:_mainAccount.userName];
                BOOL jamIsToday =  [jam.jamDate isEqualToString:_currDate];
                BOOL outDatedJam = [self checkIfEarlierStringDate:jam.jamDate date2:_currDate];
                
                // Check if the date is earlier than today's date, if so do not add marker -- UNLESS YOU ARE THE HOST!
                if (!outDatedJam || jamIsToday || isHost) {
                    
                    // Will only make it here if you are the host of an outdated jam
                    // Alert User about info on outdated jams
                    if (outDatedJam) {
                        NSString *alertTitleOutdatedJam = [NSString stringWithFormat:@"One of your Jams is outdated!\nJam Name: %s-%s", [jam.jamName UTF8String], [jam.jamType UTF8String]];
                        NSString *alertMessageOutdatedJam = @"This Jam will not be available to other users. Options:\n1. Change the date\n2. End the Jam successfully\n3. Cancel the Jam";
                        
                        /* Loading alert box */
                        [AlertView showAlertControllerOkayOption:alertTitleOutdatedJam message:alertMessageOutdatedJam view:self];
                    }
                    
                    SPAM(("Marker Lat: %f -- ",tmpMarker.position.latitude));
                    SPAM(("Marker being added: %s\n", [jam._id UTF8String]));
                    
                    tmpMarker.userData = [[NSMutableDictionary alloc] init];
                    // Enter marker's userData from jam object
                    // Local Data held in each marker:
                    // 1. Session _id number
                    // 2  Title
                    // 3. Snippet
                    
                    tmpMarker.userData[@"_id"] = jam._id;
                    tmpMarker.title = jam.jamName;
                    tmpMarker.snippet = [NSString stringWithFormat:@"Jam: %@", jam.jamType];
                    
                    // Set Color of Marker
                    [self setColorOfMarker:jam marker:tmpMarker isHost:isHost];
                    
                    // 2. Set its map
                    tmpMarker.map = _mapView;
                    
                    // 3. Add marker to dictionary of markers
                    self.jamSesssionMarkers[jam._id] = tmpMarker;
                    
                    /* Set isAdded to Map Var */
                    jam.isAddedToMap = true;
                    
                    // 4. Add jam ID to account's local object
                    if (isFromPersist) {
                        [_mainAccount.accountSessionID addObject:jam._id];
                    }
                    
                } // past date check
            }
        } // nil check
    } // end for loop
}

-(void)setColorOfMarker:(Session*)jam marker:(GMSMarker*)tmpMarker isHost:(BOOL)isHost {
    if ([jam.LeisureorComp isEqualToString:@"comp"]) {
        tmpMarker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
    } else {
        tmpMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]]; // Leisure
    }
    
    // Set to gray if the jam is a date that is not today
    if (![_currDate isEqualToString:jam.jamDate]) {
        tmpMarker.icon = [GMSMarker markerImageWithColor:[UIColor grayColor]]; // Jam is not today's date
        tmpMarker.snippet = [NSString stringWithFormat:@"Date of Jam: %@ | %@ | %@",
                             jam.jamDate, jam.startTime, jam.jamType]; // snippet should reflect the date
    }
    
    // Set to yellow if user has been invted to the jam! (mainly for remote notifications)
    for (NSString* invitedJammer in jam.invitedFriends) {
        if ([invitedJammer isEqualToString:_mainAccount.userName]) {
            tmpMarker.icon = [GMSMarker markerImageWithColor:[UIColor colorWithRed:0.00 green:1.00 blue:0.76 alpha:1.0]]; // Invited
        }
    }
    
    // Set to green if user is signed up
    for (NSString* signedUpJammer in jam.jammers) {
        if ([signedUpJammer isEqualToString:_mainAccount.userName]) {
            tmpMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]]; // Sign Up'd
        }
    }
    
    // Host color take precedence
    if (isHost) {
        tmpMarker.icon = [GMSMarker markerImageWithColor:[UIColor cyanColor]]; // Main User is the host
    }
}

/* Adds markers to the current array of locally saved markers (self.jamSessions) */
-(void)parseAndAddLocations:(NSArray*)jamSessionsArr toArray:(NSMutableArray*)destinationArray {
    SPAM(("\nParse And Adding Locations - "));
    
    /* jamSessionsArr is an array of Session objects from the Database */
    for (NSDictionary* item in jamSessionsArr) {
        if (item != nil) {
            SPAM(("JAMS BEING READ, in parseAndAddLoc\n"));
            
            Session *jam = [[Session alloc] initWithDictionary: item]; // getting Session from DB
            
            /* Check if the session should be added to map */
            // 1. Pass Fiters
            // 2. on the invited list of a private jam
            // 3. Is the host
            BOOL okayToAddToMap = [self checkIfAddJamToMap:jam];
            
            if (okayToAddToMap) {
                /* Has not been added to map yet */
                jam.isAddedToMap = false;
                
                /* Adding to the local array of full jam locations (Session objects) - self.jamSessions */
                [destinationArray addObject:jam];
                
                /* Adding jam to localCachePicLoaded (for SignUpView) */
                _localSignUpPictureCache[jam._id] = @"false";
            }
        }
    } // end for loop
}

-(BOOL)checkIfAddJamToMap:(Session*)jam {
    /* Check if it is a private Jam an you are on the invite list */
    BOOL private = false;
    if ([jam.privateJam isEqualToString:@"private"]) {
        private = true;
    }
    
    /* Check if you are the host */
    BOOL isHost = [jam.sessionHostName isEqualToString:_mainAccount.userName];
    
    if (!private || ((private && [jam.invitedFriends containsObject:_mainAccount.userName])
                     || isHost)) {
        /* Only add to map/dictionaries if within 25 miles */
        CLLocation *jamLoc = [[CLLocation alloc] initWithLatitude:[jam.sessionLat doubleValue] longitude:[jam.sessionLong doubleValue]];
        CLLocation *userLoc = [[CLLocation alloc] initWithLatitude:_centerLat longitude:_centerLong];
        if ([jamLoc distanceFromLocation:userLoc] < 40233.6) { // In meters - 25 miles
            // TODO -- add the next lines in here if you you want a 25 mile radius
            
        }
        
        BOOL passFilter = true;
        /* Check Filters */
        for (NSString* filter in jamFilters) {
            NSString* filterValue = [jamFilters objectForKey:filter];
            if ([filterValue isEqualToString:@"false"]) { // do not add these jams
                if ([filter isEqualToString:@"competition"]) {
                    if ([jam.LeisureorComp isEqualToString:@"comp"]) {
                        passFilter = false;
                        break;
                    }
                } else if ([filter isEqualToString:@"recreational"]) {
                    if ([jam.LeisureorComp isEqualToString:@"leisure"]) {
                        passFilter = false;
                        break;
                    }
                } else if ([filter isEqualToString:@"future"]) {
                    // Set tp gray if the jam is a date that is not today
                    if (![_currDate isEqualToString:jam.jamDate]) {
                        passFilter = false;
                        break;
                    }
                } else if ([filter isEqualToString:@"signedUp"]) {
                    for (NSString* signedUpJammer in jam.jammers) {
                        if ([signedUpJammer isEqualToString:_mainAccount.userName]) {
                            passFilter = false; // user is signed up
                        }
                    }
                } else if ([filter isEqualToString:@"invited"]) {
                    for (NSString* invitedJammer in jam.invitedFriends) {
                        if ([invitedJammer isEqualToString:_mainAccount.userName]) {
                            passFilter = false; // user has been invited
                        }
                    }
                }
            }
        }
        
        /** ALWAYS ADD JAM IF YOU ARE THE HOST **/
        if (passFilter || isHost) { // Deemed okay to add to map!
            return true;
        } else {
            return false;
        }
    }
    return false;
}

/***** Map Button Functionalities *****/

/* Search Address Bar Methods */
-(void)searchAddress {
    SPAM(("Searching Address...\n"));
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}

// Handle the user's selection
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    SPAM(("Place name %s", [place.name UTF8String]));
    SPAM(("Place address %s", [place.formattedAddress UTF8String]));

    GMSCameraPosition *newAddr = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude
                                                            longitude:place.coordinate.longitude
                                                                 zoom:18];
    [_mapView setCamera:newAddr];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
        didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/* Show Marketplace */
-(void)showMarketplace {
    /* View Profile Page */
    MarketplaceController * mpc = [[MarketplaceController alloc] init];
    
    [self presentViewController:mpc animated:true completion:nil];  
}

/* Refresh Map Markers */
-(IBAction)refreshMap:(id)sender {
    SPAM(("\nRefreshing Map...\n"));
    
    [self startRefreshStatusBar];
    
    _refreshButton.userInteractionEnabled = false;
    
    /* Loading alert box */
    [AlertView showAlertTab:@"Refreshing map..." view:self.view];
    
    /* Load Markers */
    [self importJamsFromDB:^(NSError *error, BOOL success, NSArray *responseArray) {
        if (success && responseArray != nil) {
            SPAM(("\nSuccess callback -- Import Markers refreshing map\n"));
            
            runOnMainThreadWithoutDeadlocking(^{
                /* Remove markers from Map & Data Strucs */
                [_mapView clear];
                [_jamSessions removeAllObjects];
                [_jamSesssionMarkers removeAllObjects];
                [_localSignUpPictureCache removeAllObjects];
            
                [self parseAndAddLocations:responseArray toArray:self.jamSessions];
            
                /* Create marker objects and place on map */
                [self createAndAddMarkers:false];
            });
        } else {
            /* Loading alert box */
            [AlertView showAlertControllerOkayOption:@"Trouble refreshing map" message:@"Please try again" view:self];
        }
    }];
    [self performSelector:@selector(activateRefresh) withObject:nil afterDelay:5.0];
}

-(void)activateRefresh {
    _refreshButton.userInteractionEnabled = true;
}

-(void)startRefreshStatusBar {
    // Refresh status bar
    UIProgressView *progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(_refreshButton.frame.origin.x,
                                                                                   (_refreshButton.frame.origin.y-2.5),
                                                                                   _refreshButton.frame.size.width,
                                                                                   20.0)];
    progressBar.tag = refreshMapProgressBarTag;
    [self.view addSubview:progressBar];
    
    [self performSelector:@selector(updateRefreshStatusBar:) withObject:progressBar afterDelay:1.0];
    [self performSelector:@selector(updateRefreshStatusBar:) withObject:progressBar afterDelay:2.0];
    [self performSelector:@selector(updateRefreshStatusBar:) withObject:progressBar afterDelay:3.0];
    [self performSelector:@selector(updateRefreshStatusBar:) withObject:progressBar afterDelay:4.0];
    [self performSelector:@selector(updateRefreshStatusBar:) withObject:progressBar afterDelay:5.0];
}

-(void)updateRefreshStatusBar:(UIProgressView*)progressBar {
    float ogProgress = [progressBar progress]+0.2;
    [progressBar setProgress:ogProgress animated:YES];
    if (ogProgress == 1.0) {
        [[self.view viewWithTag:refreshMapProgressBarTag] removeFromSuperview];
    }
}

/*** End map refresh ***/

/* Go to IG Page */
-(IBAction)IGJam:(id)sender {
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://user?username=jamcommunity"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    } else {
        NSURL *NoinstagramURL = [NSURL URLWithString:@"https://www.instagram.com/jamcommunity/"];
        [[UIApplication sharedApplication] openURL:NoinstagramURL];
    }
}

// TODO -- CREATE A BUTTON THAT LINKS TO MY ITUNESAPPLE ID for REVIEW WRITES!!!
-(void)toHOJAppStore {
    //    static NSInteger const kAppITunesItemIdentifier = 324684580; // REPLACE WITH MY APPID!!
    //    [self openStoreProductViewControllerWithITunesItemIdentifier:kAppITunesItemIdentifier];
}

- (void)openStoreProductViewControllerWithITunesItemIdentifier:(NSInteger)iTunesItemIdentifier {
    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
    
    storeViewController.delegate = self;
    
    NSNumber *identifier = [NSNumber numberWithInteger:iTunesItemIdentifier];
    
    NSDictionary *parameters = @{ SKStoreProductParameterITunesItemIdentifier:identifier };
    [storeViewController loadProductWithParameters:parameters
                                   completionBlock:^(BOOL result, NSError *error) {
                                       if (!error)
                                           [self presentViewController:storeViewController
                                                                        animated:YES
                                                                      completion:nil];
                                       else NSLog(@"SKStoreProductViewController: %@", error);
                                   }];
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

/* Show Menu */
-(IBAction)showMenu:(id)sender {
    [self presentViewController:SideMenuManager.menuLeftNavigationController animated:YES completion:nil];
}

/* Menu options Delegate method! */
-(void)menuOption:(NSString *)option {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([option isEqualToString:@"View Profile"]) {
            [self viewProfile];
        } else if ([option isEqualToString:@"Edit Profile"]) {
            [self editProfile];
        } else if ([option isEqualToString:@"Submit Entry"]) {
            [self submitEntry];
        } else if ([option isEqualToString:@"Weekly Entries"]) {
            [self voteOnEntries];
        } else if ([option isEqualToString:@"End Jam"]) {
            [self endJams];
        } else if ([option isEqualToString:@"Search Profiles"]) {
            [self searchProfiles];
        } else if ([option isEqualToString:@"Log Out"]) {
            [self logOut];
        } else if ([option isEqualToString:@"Daily Message"]) {
            [self showDailyMessage];
        } else if ([option isEqualToString:@"Monthly Rewards"]) {
            [self monthlyRewards];
        } else if ([option isEqualToString:@"Tutorial"]) {
            [self showTutorial];
        }
    }];
}

- (IBAction)showRightMenu:(id)sender {
    [self presentViewController:SideMenuManager.menuRightNavigationController animated:YES completion:nil];
}

-(void)menuRightOption:(NSString*)option {
    if ([option isEqualToString:@"Mark a location"]) {
        [self createRecJam];
    } else if ([option isEqualToString:@"Create a competition"]) {
        [self createCompJam];
    } else if ([option isEqualToString:@"Hosting Info"]) {
        [self jamInfo];
    } else if ([option isEqualToString:@"Competition Game Rules"]) {
        [self gameRules];
    }
}

/* For tutorial button */
-(void)showTutorial {
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    
    TutorialControllerMain *tc = [storyboard instantiateViewControllerWithIdentifier:@"TutorialControllerMain"];
    
    [self presentViewController:tc animated:YES completion:nil];
}

-(void)showDojoTutorial {
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        
    DojoTutorial *dtc = [storyboard instantiateViewControllerWithIdentifier:@"DojoTutorial"];
        
    [self presentViewController:dtc animated:YES completion:nil];
}

/* Vote on the entries */
-(void)voteOnEntries {
    // Run through dojo tutoiral
    if ([_mainAccount.firstTimeDojo isEqualToString:@"yes"]) {
        
        [self showDojoTutorial]; // show dojo tutorial
        
        // update account first Time Dojo entry
        _mainAccount.firstTimeDojo = @"no";
        [_mainAccount updateAccount:kBaseURL message:_mainAccount._accountid];
    } else {
        // progress bar
        [SVProgressHUD showWithStatus:@"Loading Entries..."];
        
        [VideoEntry loadEntries:kBaseURL message:_mainAccount._accountid callback:^(NSError *error, BOOL success, NSArray *responseEntryList) {
            if (success && responseEntryList != nil) {
                
                // progress bar
                [SVProgressHUD dismiss];
                runOnMainThreadWithoutDeadlocking(^{
                    NSMutableArray *Entries = [[NSMutableArray alloc] init]; // Holds All Video Entry Objects from DB
                    
                    /* Load all entries */
                    for (NSDictionary* item in responseEntryList) {
                        VideoEntry *entry = [[VideoEntry alloc] initWithDictionary:item];
                        SPAM(("%s - ", [entry._id UTF8String]));
                        [Entries addObject:entry];
                    }
                    
                    /* Check if there is at least 3 videos to load */
                    int dailyVoteNumber = [_mainAccount.dailyVoteNumber intValue];
                    if (dailyVoteNumber + 3 <= [Entries count]) {
                        /* Go to controller view, pass in main account Current Daily number */
                        NSString * storyboardName = @"Main";
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                        
                        VoteEntryController * vc = [storyboard instantiateViewControllerWithIdentifier:@"VoteEntryController"];
                        
                        vc.mainAccount = _mainAccount;
                        
                        vc.Entries = Entries;
                        vc.delegate = self;
                        
                        [self presentViewController:vc animated:YES completion:nil];
                    } else {
                        /* Loading alert box */
                        [AlertView showAlertControllerOkayOption:@"Over 7 billion people live on this earth and no new entries? Shocking." message:@"No new entries to view. Please come back in a little while." view:self];
                    }
                });
                
            } else { // error
                // progress bar
                [SVProgressHUD dismiss];
                /* Loading alert box */
                [AlertView showAlertControllerOkayOption:@"Trouble loading entries" message:@"Please try again" view:self];
            }
        }]; // end loadEntries:
    } // end if statement
}

/* Delegate method for voting page */
-(void)returnToMainViewNoVideos:(NSString*)tag {

    [self dismissViewControllerAnimated:YES completion:^{ // wait until main view is completed its transition
        
        [SVProgressHUD dismiss]; // dismiss any huds
        
        if ([tag isEqualToString:@"1"]) { // no more videos to view
            
            // increment daily vote count on local object (DB already updated this number), this does not get done in VoteVideoController.m
            int ogDailyVoteNum = [_mainAccount.dailyVoteNumber intValue];
            _mainAccount.dailyVoteNumber = [NSNumber numberWithInt:ogDailyVoteNum + 3];
            
            /* Loading alert box */
            [AlertView showAlertControllerOkayOption:@"No entries for now!" message:@"Come back in a little while" view:self];
            
        } else if ([tag isEqualToString:@"2"]) { // error loading videos
            /* Loading alert box */
            [AlertView showAlertControllerOkayOption:@"Trouble loading entries" message:@"Connecting to WiFi will help this cause" view:self];
            
        } else if ([tag isEqualToString:@"3"]) { /* Back button was called -- Do nothing */ }
    }];
}

/** Submit Entry -  Add submission to online que for voters **/
-(void)submitEntry {
    int dailySubmissionNumber = [_mainAccount.dailySubmissionNumber intValue];
    if (dailySubmissionNumber < 2) { // only 2 submissions allowed!
    
        /* Image/Video Picker */
        UIImagePickerController *entryPicker = [[UIImagePickerController alloc] init];
        entryPicker.delegate = self;
        entryPicker.allowsEditing = true;
        entryPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        entryPicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, (NSString*)kUTTypeImage,nil];
        
        [self presentViewController:entryPicker animated:YES completion:nil];
    
    } else { // alert showing user has reached their daily limit of videos
        /* Loading alert box */
        [AlertView showAlertControllerOkayOption:@"No more submissions left!" message:@"Limited to 2 per day, come back tomorrow." view:self];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]) { // photo
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        _entryData = UIImageJPEGRepresentation(image, 0.8);
        _imageOrVideo = @"image";

        runOnMainThreadWithoutDeadlocking(^{
            [self getEntryDescription];
        });
    
    } else { // video
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
        
        float videoSize = (float)videoData.length/1024.0f/1024.0f; // MB
        if (videoSize < allowedVideoSize) {
            _entryData = videoData;
            _imageOrVideo = @"video";
            
            runOnMainThreadWithoutDeadlocking(^{
                [self getEntryDescription];
            });
        } else {
            [AlertView showAlertTab:@"Video can not be greater than 70 MB" view:self.view];
        }
    }
}

-(void)getEntryDescription {
    // Get Description
    UIView *getDescription = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-125.0,
                                                                      100.0,
                                                                      250.0, 280.0)];
    getDescription.backgroundColor = [UIColor whiteColor];
    getDescription.layer.borderColor = [[UIColor blackColor] CGColor];
    getDescription.layer.borderWidth = 1.5f;
    getDescription.layer.cornerRadius = 3;
    getDescription.clipsToBounds = YES;
    getDescription.tag = entryDescriptionViewTag;
    
    UIButton *cancelEntryButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0,
                                                                             240.0,
                                                                             getDescription.frame.size.width-20.0,
                                                                             30.0)];
    [cancelEntryButton setBackgroundColor:[UIColor blackColor]];
    [cancelEntryButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelEntryButton.titleLabel setTextColor:[UIColor whiteColor]];
    [cancelEntryButton.titleLabel setFont:[UIFont fontWithName:@"ActionMan" size:17.0]];
    cancelEntryButton.layer.cornerRadius = 3;
    cancelEntryButton.clipsToBounds = YES;
    [cancelEntryButton addTarget:self
                          action:@selector(submitEntryWithDesc:)
                forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *submitEntryButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0,
                                                                             cancelEntryButton.frame.origin.y-40.0,
                                                                             getDescription.frame.size.width-20.0,
                                                                             30.0)];
    [submitEntryButton setBackgroundColor:[UIColor blackColor]];
    [submitEntryButton setTitle:@"Submit Entry" forState:UIControlStateNormal];
    [submitEntryButton.titleLabel setTextColor:[UIColor whiteColor]];
    [submitEntryButton.titleLabel setFont:[UIFont fontWithName:@"ActionMan" size:17.0]];
    submitEntryButton.layer.cornerRadius = 3;
    submitEntryButton.clipsToBounds = YES;
    [submitEntryButton addTarget:self
                          action:@selector(submitEntryWithDesc:)
                forControlEvents:UIControlEventTouchUpInside];
    
    UITextView *entryDescription = [[UITextView alloc] initWithFrame:CGRectMake(5.0,
                                                                                5.0,
                                                                                getDescription.frame.size.width-10.0,
                                                                                submitEntryButton.frame.origin.y-10.0)];
    entryDescription.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    entryDescription.delegate = self;
    entryDescription.text = @"Enter a description...";
    entryDescription.textColor = [UIColor darkGrayColor];
    entryDescription.tag = entryDescriptionTextViewTag;
    
    [getDescription addSubview:entryDescription];
    [getDescription addSubview:submitEntryButton];
    [getDescription addSubview:cancelEntryButton];
    [self.view addSubview:getDescription];
}

-(void)submitEntryWithDesc:(UIButton*)sender {
    
    if ([sender.titleLabel.text isEqualToString:@"Submit Entry"]) {
        NSString *entryDescription = ((UITextView*)[self.view viewWithTag:entryDescriptionTextViewTag]).text;
        
        if ([entryDescription isEqualToString:@"Enter a description..."] || entryDescription.length == 0) {
            entryDescription = @"No Description";
        }
        
        
        [self createEntryProgressBar]; // create progress bar
        [self saveEntryVideo:_entryData imageOrVideo:_imageOrVideo entryDescription:entryDescription]; // this function will retrieve video id and create entry submisson
    }
    
    _entryData = nil;
    _imageOrVideo = nil;
    
    // Remove view
    [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
        [self.view viewWithTag:entryDescriptionViewTag].alpha = 0.0;
    } completion:^(BOOL finished) {
        [[self.view viewWithTag:entryDescriptionViewTag] removeFromSuperview];
    }];
}

/** END Submit Entry **/

/* Cancel Jam */
-(void)cancelSesh:(Session*)session index:(int)index {
    SPAM(("\nCanceling Jam\n"));
    
    /* Cancell Sesh by removing marker from map */
    
    /* Loading alert box */
    UIAlertController *alertControllerEndSesh = [UIAlertController
                                                 alertControllerWithTitle:@"Cancel Jam?"
                                                 message:@"Select this option only if you are scrapping a Jam. To successfully end a Jam, tap the \"End Jam\" button in the main menu."
                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"Cancel Jam" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           // Remove sign up view
                                                           if (_botView != nil)
                                                               [self removeBotView];
                                                           [self cleanUpJam:session index:index];
                                                           // This update is a fail-safe to make sure DB and app are on same page
                                                           [_mainAccount updateAccount:kBaseURL message:_mainAccount._accountid];
                                                           [AlertView showAlertTab:@"Canceled Jam" view:self.view];
                                                       }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Do Not Cancel Jam" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) { /* Do nothing */ }];
    
    [alertControllerEndSesh addAction:okayAction];
    [alertControllerEndSesh addAction:cancelAction];
    [self presentViewController:alertControllerEndSesh animated:YES completion:nil];
}

/* End Jam */
-(void)endJams {
    SPAM(("\End Sesh tapped\n"));
    if ([_mainAccount.accountSessionID count] == 0) {
        [AlertView showAlertTab:@"You are not hosting any jams" view:self.view];
    } else {
        
        /* Loading alert box */
        UIAlertController *alertControllerEndSesh = [UIAlertController
                                                     alertControllerWithTitle:@"Select a Jam to end successfully.\n\nJam Name(s):"
                                                     message:nil
                                                     preferredStyle:UIAlertControllerStyleAlert];
        
        // Load Jam Title Strings with Jam Names
        NSString* jamOneTitle;
        NSString* jamTwoTitle;
        NSString* jamThreeTitle;
        
        for (int i  = 0; i < [_mainAccount.accountSessionID count]; i++) {
            NSString *accSeshID = [_mainAccount.accountSessionID objectAtIndex:i];
            for (int j = 0; j < [self.jamSessions count]; j++) {
                Session *sesh = (Session*)[self.jamSessions objectAtIndex:j];
                if ([accSeshID isEqualToString:sesh._id]) {
                    if (i == 0) { // Jam 1
                        jamOneTitle = [NSString stringWithFormat:@"%s", [sesh.jamName UTF8String]];
                    } else if (i == 1) { // Jam 2
                        jamTwoTitle = [NSString stringWithFormat:@"%s", [sesh.jamName UTF8String]];
                    } else { // Jam 3
                        jamThreeTitle = [NSString stringWithFormat:@"%s", [sesh.jamName UTF8String]];
                    }
                }
            }
        }
        
        // Add Buttons for each hosted jam
        UIAlertAction* jamOneEnd;
        UIAlertAction* jamTwoEnd;
        UIAlertAction* jamThreeEnd;
        
        if ([jamOneTitle length]) {
            jamOneEnd = [UIAlertAction actionWithTitle:jamOneTitle style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [self endAJam:[_mainAccount.accountSessionID objectAtIndex:0]];
                                               }];
            [alertControllerEndSesh addAction:jamOneEnd];
        }

        if ([jamTwoTitle length]) {
            jamTwoEnd = [UIAlertAction actionWithTitle:jamTwoTitle style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [self endAJam:[_mainAccount.accountSessionID objectAtIndex:1]];
                                               }];
            [alertControllerEndSesh addAction:jamTwoEnd];
        }
        
        if ([jamThreeTitle length]) {
            jamThreeEnd = [UIAlertAction actionWithTitle:jamThreeTitle style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [self endAJam:[_mainAccount.accountSessionID objectAtIndex:2]];
                                               }];
            [alertControllerEndSesh addAction:jamThreeEnd];
        }

        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) { /* Do nothing */ }];
        
        [alertControllerEndSesh addAction:cancelAction];
        [self presentViewController:alertControllerEndSesh animated:YES completion:nil];
    }
}

// Delegate method from EndJamController
-(void)endAJam:(NSString*)sessionID {
    
    _timesWinnerSubmitted = 0; // zero times tried
    
    if (_botView != nil) {
        [self removeBotView];
    }
    
    /* 1. loadSession using the sessions ID --  Do this so the user has an updated version of Jam object (client may be behind the updated DB object) */
    // 2. Then pass in jammers list through HTTP body...
    [Session loadSession:kBaseURL seshID:sessionID message:_mainAccount._accountid callback:^(NSError *error, BOOL success, NSDictionary *responseSession) {
        if (success && responseSession != nil) {
            
            // Get the latest version of jammers
            Session *s = [[Session alloc] initWithDictionary:responseSession];
            
            // Find index of jam we are working with -- for deleting purposes later
            int index = 0;
            for (Session *sesh in _jamSessions) {
                if ([sesh._id isEqualToString:s._id]) {
                    break;
                }
                index+=1;
            }
            
            // 0. a. Must either go to select winner page or only increase jammers accounts session attened by one
            if ([s.LeisureorComp isEqualToString:@"comp"]) {

                UIAlertController *alertControllerEndASesh = [UIAlertController
                                                             alertControllerWithTitle:@"End Jam?"
                                                             message:@"This will bring you to the select a winner page (only if there are more than 4 Jammers). Please make sure you have a strong signal or WiFi connection so Jammer's stats are successfully updated!"
                                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"End Jam" style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {
                
                    /* Only select winner if there are more than 4 people in attendence  */
                    if ([s.jammers count] >= 4) {
                        /* Set to nil, about to be loaded into DB */
                        self.tmpSession = s;
                        // 0. b. - Go to select winner page
                        NSString * storyboardName = @"Main";
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                        SelectWinnerController * swc = [storyboard instantiateViewControllerWithIdentifier:@"SelectWinnerController"];
                        
                        swc.selectWinnerSession = self.tmpSession;
                        swc.delegate = self;
                        swc.jamIndex = index;
                        
                        [self presentViewController:swc animated:true completion:nil];
                    } else {
                        // 0. b. - Increase list of jammers sessionsAttened++
                        [self clearJam:s index:(int)index winner:nil];
                    }
                
                }];
                
                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) { /* Do nothing */ }];
                
                [alertControllerEndASesh addAction:okayAction];
                [alertControllerEndASesh addAction:cancelAction];
                
                [self presentViewController:alertControllerEndASesh animated:YES completion:nil];
                                                                       
            } else {
                /* Loading alert box */
                UIAlertController *alertControllerEndSesh = [UIAlertController
                                                             alertControllerWithTitle:@"End Jam?"
                                                             message:@"Please make sure you have a strong signal or WiFi connection so Jammer's stats are successfully updated!"
                                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"End Jam" style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {
                                                                       // 0. b. - Increase list of jammers sessionsAttened++
                                                                       [self clearJam:s index:(int)index winner:nil];
                                                                   }];
                
                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) { /* Do nothing */ }];
                
                [alertControllerEndSesh addAction:okayAction];
                [alertControllerEndSesh addAction:cancelAction];
                
                [self presentViewController:alertControllerEndSesh animated:YES completion:nil];
            }
        }
    }];
}


// Delegate method from SelectWinnerController
-(void)getWinner:(NSString*)winner jamIndex:(NSInteger)jamIndex jam:(Session*)jam {
    SPAM(("\nWinner Chosen\n"));
    [self dismissViewControllerAnimated:YES completion:nil];
    [self clearJam:jam index:(int)jamIndex winner:winner];
}

/* 1. Called when sucessfuly ended session, will increase number of session attended by one
   2. Also carries out all cancel sesh UI Updates and DB Management */
-(void)clearJam:(Session *)session index:(int)index winner:(NSString *)winner {
    SPAM(("\nClearing Jam\n"));
    
    // Show user alert
    if (winner == nil) {
        [AlertView showAlertTab:@"Updating profiles now..." view:self.view];
    } else {
        [AlertView showAlertTab:@"Winner selected! Updating profiles now..." view:self.view];
    }
    
    // 6. Now go through and increase number of sessions attended for each participant
    // Set winner if there is none
    (winner == nil) ? (winner = @"nowinner") : (winner);
    
    // IF THIS FAILS, SEND ALERT, CALL AGAIN -- also check out when a vote for entry fails...call update again?
    // Call to DB, server will take care of work
    [Account increaseJammersSessionsAttendedWins:kBaseURL message:_mainAccount._accountid host:_mainAccount.userName winner:winner jammers:session.jammers currentLocation:session.jamLocation callback:^(NSError *error, BOOL success) {
        if (success) {
            runOnMainThreadWithoutDeadlocking(^{
                [self cleanUpJam:session index:index];
            });
        } else {
            /* Loading alert box */
            runOnMainThreadWithoutDeadlocking(^{
                if (_timesWinnerSubmitted < 3) {
                    // There is an error, call again
                    [AlertView showAlertTab:@"There was an error, resending request" view:self.view];
                    _timesWinnerSubmitted += 1; // update tried
                    [self clearJam:session index:index winner:winner]; // try again
                } else {
                    // If 3 times failed, send alert to email or try later
                    [AlertView showAlertControllerOkayOption:@"Could not successfully end Jam!" message:@"After multiple times, the server could not be reached. Try again later OR email us with the results of your jam." view:self];
                }
            });
        }
    }];
}

/** End End Jam **/

/* Clean ups all local objects as well as DB objects
   Currently Used in Cancel/End Jam */
-(void)cleanUpJam:(Session*)session index:(int)index {
    // 1. REMOVE JAM FROM Markers DB and its images from 'files' DB
    for (NSString *picID in session.sessionPictureIDs) {
        [DataBaseCalls deleteFromCollection:kFiles entity:picID message:_mainAccount._accountid];
    }
    // Then clear both arrays
    session.sessionPictureIDs = nil;
    session.sessionPictures = nil;
    [DataBaseCalls deleteFromCollection:kMarkers entity:session._id message:_mainAccount._accountid]; // remove marker from DB
    
    // 2. Find Marker and Set marker's map to nil and remove from array
    GMSMarker *m = [self.jamSesssionMarkers valueForKey:session._id];
    m.map = nil;
    [self.jamSesssionMarkers removeObjectForKey:self.mainAccount.accountSessionID];
    
    // 3a. - Remove from _jamSessions
    [self.jamSessions removeObjectAtIndex:index];
    // 3b. Remove from _localSignUpPictureCache
    [_localSignUpPictureCache removeObjectForKey:session._id];
    
    // 5.  reset _mainAccount's sessionID -- sessionID is cleared on server when marker is deleted
    for (int i = 0; i < [_mainAccount.accountSessionID count]; i++) {
        if ([[_mainAccount.accountSessionID objectAtIndex:i] isEqualToString:session._id]) {
            SPAM(("\nDELETED LOCAL JAM\n"));
            [_mainAccount.accountSessionID removeObjectAtIndex:i];
            break;
        }
    }
}


/* Show Map Legend (Marker Colors) */
-(void)showMapLegend {
        
    BOOL doesContain = [self.view.subviews containsObject:[self.view viewWithTag:mapLegendViewTag]];
    if (doesContain) {
        [self removeLegend];
    } else {
        
        // Get Description
        UIView *legend = [[UIView alloc] initWithFrame:CGRectMake(5.0,
                                                                  (_mapLegendButton.frame.origin.y-272.0),
                                                                  200.0, 343.0)];
        legend.backgroundColor = [UIColor whiteColor];
        legend.layer.borderColor = [[UIColor blackColor] CGColor];
        legend.layer.borderWidth = 1.5f;
        legend.layer.cornerRadius = 3;
        legend.clipsToBounds = YES;
        legend.tag = mapLegendViewTag;
        legend.alpha = 0.0;
        
        UITextView *legendTextView = [[UITextView alloc] initWithFrame:CGRectMake(0.0,
                                                                                  0.0,
                                                                                  legend.frame.size.width,
                                                                                  legend.frame.size.height)];
        legendTextView.delegate = self;
        legendTextView.editable = false;
        legendTextView.bounces = false;
        legendTextView.selectable = false;
        [legend addSubview:legendTextView];
        
        NSMutableAttributedString *legendText = [[NSMutableAttributedString alloc] init];
        
        /* Attributed Strings for Legend */
        UIColor *Blackcolor = [UIColor blackColor];
        UIColor *GColor = [UIColor greenColor];
        UIColor *RColor = [UIColor redColor];
        UIColor *BlueColor = [UIColor blueColor];
        UIColor *GrayColor = [UIColor grayColor];
        UIColor *InvitedColor =[UIColor colorWithRed:0.00 green:1.00 blue:0.76 alpha:1.0];
        
        NSDictionary *attributesBlack = @{
                                          NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:14.0],
                                          NSForegroundColorAttributeName : Blackcolor
                                          };
        NSDictionary *attributesTitle= @{
                                         NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:21.0],
                                         NSForegroundColorAttributeName : Blackcolor
                                         };
        NSDictionary *attributesG = @{
                                      NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:18.0],
                                      NSForegroundColorAttributeName : GColor
                                      };
        NSDictionary *attributesR = @{
                                      NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:18.0],
                                      NSForegroundColorAttributeName : RColor
                                      };
        NSDictionary *attributesBlue = @{
                                         NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:18.0],
                                         NSForegroundColorAttributeName : BlueColor
                                         };
        NSDictionary *attributesInvited = @{
                                            NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:18.0],
                                            NSForegroundColorAttributeName : InvitedColor
                                            };
        NSDictionary *attributesGray = @{
                                         NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:18.0],
                                         NSForegroundColorAttributeName : GrayColor
                                         };
        NSDictionary *attributesPrivate = @{
                                         NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:18.0],
                                         NSForegroundColorAttributeName : Blackcolor
                                         };
        NSDictionary *attributesHost = @{
                                      NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:18.0],
                                      NSForegroundColorAttributeName : [UIColor cyanColor]
                                      };
        
        NSAttributedString *RecreationalStr = [[NSAttributedString alloc] initWithString:@"Recreational - " attributes:attributesBlue];
        NSAttributedString *CompetitionStr = [[NSAttributedString alloc] initWithString:@"Competition - " attributes:attributesR];
        NSAttributedString *InvitedStr = [[NSAttributedString alloc] initWithString:@"Invited - " attributes:attributesInvited];
        NSAttributedString *SignUpStr = [[NSAttributedString alloc] initWithString:@"Signed Up - " attributes:attributesG];
        NSAttributedString *FutureDateStr = [[NSAttributedString alloc] initWithString:@"Future Date - " attributes:attributesGray];
        NSAttributedString *HostStr = [[NSAttributedString alloc] initWithString:@"Jam Host - " attributes:attributesHost];
        NSAttributedString *PrivateStr = [[NSAttributedString alloc] initWithString:@"-----------------------\nPrivate Jam - " attributes:attributesPrivate];
        
        NSAttributedString *legendTitle = [[NSMutableAttributedString alloc] initWithString:@"Jam Color Key:\n\n" attributes:attributesTitle];
        [legendText appendAttributedString:legendTitle];
        
        NSAttributedString *recDescStr = [[NSAttributedString alloc] initWithString:@"A Recreational Jam\n\n" attributes:attributesBlack];
        [legendText appendAttributedString:RecreationalStr];
        [legendText appendAttributedString:recDescStr];
        
        NSAttributedString *compDescStr = [[NSAttributedString alloc] initWithString:@"A Competition Jam\n\n" attributes:attributesBlack];
        [legendText appendAttributedString:CompetitionStr];
        [legendText appendAttributedString:compDescStr];
        
        NSAttributedString *invDescStr = [[NSAttributedString alloc] initWithString:@"A friend has invited you to this Jam\n\n" attributes:attributesBlack];
        [legendText appendAttributedString:InvitedStr];
        [legendText appendAttributedString:invDescStr];
        
        NSAttributedString *signUpDescStr = [[NSAttributedString alloc] initWithString:@"You are signed up for this Jam!\n\n" attributes:attributesBlack];
        [legendText appendAttributedString:SignUpStr];
        [legendText appendAttributedString:signUpDescStr];
        
        NSAttributedString *futureDescStr = [[NSAttributedString alloc] initWithString:@"This Jam is set for a future date. Sign up in advance\n\n" attributes:attributesBlack];
        [legendText appendAttributedString:FutureDateStr];
        [legendText appendAttributedString:futureDescStr];

        NSAttributedString *hostDescStr = [[NSAttributedString alloc] initWithString:@"You are the host of this jam\n" attributes:attributesBlack];
        [legendText appendAttributedString:HostStr];
        [legendText appendAttributedString:hostDescStr];
        
        NSAttributedString *PrivateDescStr = [[NSAttributedString alloc] initWithString:@"A black background indicates a private jam (only visible to invited jammers)" attributes:attributesBlack];
        [legendText appendAttributedString:PrivateStr];
        [legendText appendAttributedString:PrivateDescStr];
        
        
        legendTextView.attributedText = legendText;
        [self.view addSubview:legend];
        
        // Touch gesture remove legend
        UITapGestureRecognizer *tapRemoveLegend = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeLegend)];
        tapRemoveLegend.delegate = self;
        tapRemoveLegend.numberOfTapsRequired = 1;
        [legendTextView addGestureRecognizer:tapRemoveLegend];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
            legend.alpha = 1.0;
        } completion:^(BOOL finished) { /* Do nothing */ }];
    }
}

-(void)removeLegend {
    [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
        [self.view viewWithTag:mapLegendViewTag].alpha = 0.0;
    } completion:^(BOOL finished) {
        [[self.view viewWithTag:mapLegendViewTag] removeFromSuperview];
    }];
}
/** End Map Legend **/

/* Show Filter View */
-(void)showFilterView {
    SPAM(("\nShow Filter Menu\n"));
    _filterView = [[FilterView alloc] init];
    _filterView.view.tag = filterViewTag;
    _filterView.delegate = self;
    _filterView.filters = jamFilters;
    [_filterView setUpFilterView];
    _filterView.view.alpha = 0.0;
    _filterView.view.backgroundColor = [UIColor whiteColor];
    _filterView.view.layer.borderColor = [[UIColor blackColor] CGColor];
    _filterView.view.layer.borderWidth = 1.5f;
    _filterView.view.layer.cornerRadius = 3;
    _filterView.view.frame = CGRectMake(_filterButton.frame.origin.x+70.0-205.0, _filterButton.frame.origin.y, 205.0, 325.0);
    
    [self.view addSubview:_filterView.view];
    
    [UIView transitionWithView:self.view
                      duration:0.2
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^ {
                        _filterView.view.alpha = 1.0;
                    }
                    completion:nil];
}

-(void)dismissFilter:(int)choice {
    if (choice == 1) { // Only display if filters have changed
        [AlertView showAlertTab:@"Filters Changed. Refresh Map" view:self.view];
    }
    [UIView transitionWithView:self.view
                      duration:0.2
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^ {
                        _filterView.view.alpha = 0.0;
                    }
                    completion:^(BOOL Finished) { [[self.view viewWithTag:filterViewTag] removeFromSuperview]; }];
    
}

/** End Filter View **/

/** InfoViews - Faded background to black views **/
-(void)showBlackBackgroundEffect {
    /* Blur effect!! */
    // create effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    effectView.tag = blackBackgroundTag;
    effectView.alpha = 0.0;
    // add the effect view to the image view
    [self.view addSubview:effectView];
    [self.view bringSubviewToFront:effectView];
    
}

/* Monthly Rewards */
-(void)monthlyRewards {
    MonthlyRewardsController *rewardsView = [[MonthlyRewardsController alloc] init];
    rewardsView.view.tag = infoViewTag;
    rewardsView.view.alpha = 0.0;
    rewardsView.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
    rewardsView.delegate = self;
    [rewardsView showRewardsView:[self setUpMonthlyRewardsText]]; // show info view
    
    [self showBlackBackgroundEffect]; // background black fade
    
    [self addChildViewController: rewardsView];
    [self.view addSubview:rewardsView.view];
    
    [UIView transitionWithView:self.view
                      duration:0.2
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^ {
                        rewardsView.view.alpha = 1.0;
                        [self.view viewWithTag:blackBackgroundTag].alpha = 1.0;
                    }
                    completion:nil];
}

-(NSMutableAttributedString*)setUpMonthlyRewardsText {
    // Text Attributes
    NSDictionary *attributesSmall = @{
                                      NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:16.0],
                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                      };
    NSDictionary *attributesLarge = @{
                                      NSFontAttributeName : [UIFont fontWithName:@"ActionMan-Bold" size:18.0],
                                      NSForegroundColorAttributeName : [UIColor redColor]
                                      };
    
    NSAttributedString *onePt = [[NSAttributedString alloc] initWithString:@"1 point"
                                                                attributes:attributesLarge];
    NSAttributedString *fivePt = [[NSAttributedString alloc] initWithString:@"5 points"
                                                                 attributes:attributesLarge];
    NSAttributedString *tenPt = [[NSAttributedString alloc] initWithString:@"10 points"
                                                                attributes:attributesLarge];
    NSAttributedString *twentyPt = [[NSAttributedString alloc] initWithString:@"20 points"
                                                                   attributes:attributesLarge];
    NSAttributedString *thirtyPt = [[NSAttributedString alloc] initWithString:@"30 points"
                                                                   attributes:attributesLarge];
    NSAttributedString *fourtyPt = [[NSAttributedString alloc] initWithString:@"40 points"
                                                                   attributes:attributesLarge];
    NSAttributedString *fiftyPt = [[NSAttributedString alloc] initWithString:@"50 points"
                                                                  attributes:attributesLarge];
    
    NSMutableAttributedString *rewardTextOne = [[NSMutableAttributedString alloc] initWithString:@"- Voting on an EntRy: " attributes:attributesSmall];
    NSMutableAttributedString *rewardTextTwo = [[NSMutableAttributedString alloc] initWithString:@"\n- Receiving a vote for your submitted entry: " attributes:attributesSmall];
    NSMutableAttributedString *rewardTextThree = [[NSMutableAttributedString alloc] initWithString:@"\n- Submitting an entry: " attributes:attributesSmall];
    NSMutableAttributedString *rewardTextFour = [[NSMutableAttributedString alloc] initWithString:@"\n- Attending a jam with 3 or more people: " attributes:attributesSmall];
    NSMutableAttributedString *rewardTextFive = [[NSMutableAttributedString alloc] initWithString:@"\n- Hosting a Jam with 4 or more people: " attributes:attributesSmall];
    NSMutableAttributedString *rewardTextSix = [[NSMutableAttributedString alloc] initWithString:@"\n- Winning your weekly entry pool: " attributes:attributesSmall];
    NSMutableAttributedString *rewardTextSeven = [[NSMutableAttributedString alloc] initWithString:@"\n- Winning a competitive Jam with 4 or more people: " attributes:attributesSmall];
    
    NSMutableAttributedString *rewardDesc = [[NSMutableAttributedString alloc] init];
    [rewardDesc appendAttributedString:rewardTextOne];
    [rewardDesc appendAttributedString:onePt];
    [rewardDesc appendAttributedString:rewardTextTwo];
    [rewardDesc appendAttributedString:fivePt];
    [rewardDesc appendAttributedString:rewardTextThree];
    [rewardDesc appendAttributedString:tenPt];
    [rewardDesc appendAttributedString:rewardTextFour];
    [rewardDesc appendAttributedString:twentyPt];
    [rewardDesc appendAttributedString:rewardTextFive];
    [rewardDesc appendAttributedString:thirtyPt];
    [rewardDesc appendAttributedString:rewardTextSix];
    [rewardDesc appendAttributedString:fourtyPt];
    [rewardDesc appendAttributedString:rewardTextSeven];
    [rewardDesc appendAttributedString:fiftyPt];
    
    return rewardDesc;
}

/* Show Game Rules */
-(void)gameRules {
    [self dismissViewControllerAnimated:YES completion:^{
        
        InfoViewController *infoView = [[InfoViewController alloc] init];
        infoView.view.tag = infoViewTag;
        infoView.view.alpha = 0.0;
        infoView.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
        infoView.delegate = self;
        
        // show info view -- Pass in full text and title
        [infoView showInfoView:[self setUpGameRulesText] title:@"Offical Competition Rules"];
        
        [self showBlackBackgroundEffect]; // background black fade
        
        [self addChildViewController: infoView];
        [self.view addSubview:infoView.view];
        
        [UIView transitionWithView:self.view
                          duration:0.2
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^ {
                            infoView.view.alpha = 1.0;
                            [self.view viewWithTag:blackBackgroundTag].alpha = 1.0;
                        }
                        completion:nil];
    }];
}

-(NSMutableAttributedString*)setUpGameRulesText {
    // Set up text
    NSDictionary *attributesSmall = @{
                                      NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:16.0],
                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                      };
    
    NSDictionary *attributesLarge = @{
                                      NSFontAttributeName : [UIFont fontWithName:@"ActionMan-Bold" size:19.0],
                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                      };
    
    NSDictionary *attributesTitle = @{
                                      NSFontAttributeName : [UIFont fontWithName:@"ActionMan-Bold" size:22.0],
                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                      };
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Offical Competition Rules:\n\n"
                                                                attributes:attributesTitle];
    
    NSAttributedString *skate = [[NSAttributedString alloc] initWithString:@"S-K-A-T-E\n"
                                                                attributes:attributesLarge];
    NSAttributedString *bestLine = [[NSAttributedString alloc] initWithString:@"Best Line\n"
                                                                   attributes:attributesLarge];
    NSAttributedString *bestTrick = [[NSAttributedString alloc] initWithString:@"Best Trick\n"
                                                                    attributes:attributesLarge];
    NSAttributedString *entryFee = [[NSAttributedString alloc] initWithString:@"Entry Fee Rules\n"
                                                                   attributes:attributesLarge];
    
    NSAttributedString *skateDesc = [[NSAttributedString alloc] initWithString:@"Played the same as H-O-R-S-E. Choose an order of jammers. Jammer one chooses a feature, names a trick, and attempts to stomp it. If successful, all jammers in specified order gets one attempt at the trick. If they fail, take a letter. If the trick creator fails to complete the trick, the next jammer in the order creates the next trick. The winner is the last person to not have all 5 letters. It is of upmost importance that jammers honor all fellow jammers and respect the game.\n\n"
                                                                    attributes:attributesSmall];
    NSAttributedString *bestLineDesc = [[NSAttributedString alloc] initWithString:@"A designated line of features or flat ground is chosen. Each jammer has a chance to complete the designated line to the best of their ability. This game has 5 rounds. A round ends when each jammer has had one attempt at the chosen line. A line should be judged based on the level of difficulty of all tricks, quantity of tricks, and cleanest execution. It is recommended that each judge rates the line on a 1-10 scale and average the scores of each judge. Judges consist of each other jammer as well as any person that wishes to partake in judging the jam. The winner of this game is the jammer with the highest average score on a single line throughout all 5 rounds. It is of upmost importance that jammers use fair judgement, honor all fellow jammers, and respect the game.\n\n"
                                                                       attributes:attributesSmall];
    NSAttributedString *bestTrickDesc = [[NSAttributedString alloc] initWithString:@"Jammers attempt to do their best trick on the specified feature as chosen in the create jam form page. This game has 5 rounds. A round ends when each jammer has had one attempt at a trick of their choosing on the specified feature. Tricks should be judged based on the level of difficulty and cleanest execution. It is reccomended that each judge rates the trick on a 1-10 scale and average the scores of each judge. Judges consist of each other jammer as well as any person that wishes to partake in judging the jam. The winner of this game is the jammer with the highest average score on a single trick throuhgout all 5 rounds. It is of upmost importance that jammers use fair judgement, honor all fellow jammers, and respect the game.\n\n"
                                                                        attributes:attributesSmall];
    
    NSAttributedString *entryFeeDesc = [[NSAttributedString alloc] initWithString:@"If an entry fee is specified, all jammers must pay an entry fee to the jam's host. The host is in charge of holding onto the submitted fees. The winner of the jam is awarded the whole pot."
                                                                       attributes:attributesSmall];
    
    
    NSMutableAttributedString *explainText = [[NSMutableAttributedString alloc] init];
    [explainText appendAttributedString:title];
    [explainText appendAttributedString:skate];
    [explainText appendAttributedString:skateDesc];
    [explainText appendAttributedString:bestTrick];
    [explainText appendAttributedString:bestTrickDesc];
    [explainText appendAttributedString:bestLine];
    [explainText appendAttributedString:bestLineDesc];
    [explainText appendAttributedString:entryFee];
    [explainText appendAttributedString:entryFeeDesc];
    return explainText;
}

/* Jam Info */
-(void)jamInfo {
    [self dismissViewControllerAnimated:YES completion:^{
        
        InfoViewController *infoView = [[InfoViewController alloc] init];
        infoView.view.tag = infoViewTag;
        infoView.view.alpha = 0.0;
        infoView.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
        infoView.delegate = self;
        
        [infoView showInfoView:[self setUpJamInfoText] title:@"Host A Jam"]; // show info view
        
        [self showBlackBackgroundEffect]; // background black fade
        
        [self addChildViewController: infoView];
        [self.view addSubview:infoView.view];
        
        [UIView transitionWithView:self.view
                          duration:0.2
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^ {
                            infoView.view.alpha = 1.0;
                            [self.view viewWithTag:blackBackgroundTag].alpha = 1.0;
                        }
                        completion:nil];
    }];
}

-(NSMutableAttributedString*)setUpJamInfoText {
    // Set up text
    NSDictionary *attributesSmall = @{
                                      NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:16.0],
                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                      };
    NSDictionary *attributesLargeRec = @{
                                         NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:20.0],
                                         NSForegroundColorAttributeName : [UIColor blueColor]
                                         };
    NSDictionary *attributesLargeComp = @{
                                          NSFontAttributeName : [UIFont fontWithName:@"ActionMan" size:20.0],
                                          NSForegroundColorAttributeName : [UIColor redColor]
                                          };
    
    NSAttributedString *recTitle = [[NSAttributedString alloc] initWithString:@"Recreational Jam" attributes:attributesLargeRec];
    NSAttributedString *compTitle = [[NSAttributedString alloc] initWithString:@"Competitive Jam" attributes:attributesLargeComp];
    NSAttributedString *recDesc = [[NSAttributedString alloc] initWithString:@"\n(Mark a location)\n- Select an event or activity\n- Upload an optional photo of the location\n- Write a description of the event (chill out, hike, pick up ball, flea market, etc...)\n\n" attributes:attributesSmall];
    NSAttributedString *compDesc = [[NSAttributedString alloc] initWithString:@"\n(Create a competition)\n- Geared towards extreme sports...Set up a competition:\n- Choose a game type (Official rules can be found in this menu)\n- Upload any photos of the Jam feature or site\n- Post an optional prize photo and entry fee...that's it!\n- Winning a competitive Jam with 4 or more jammers awards one competitive win" attributes:attributesSmall];
    
    NSMutableAttributedString *infoString = [[NSMutableAttributedString alloc] init];
    [infoString appendAttributedString:recTitle];
    [infoString appendAttributedString:recDesc];
    [infoString appendAttributedString:compTitle];
    [infoString appendAttributedString:compDesc];
    return infoString;
}

-(void)dismissInfo {
    // Show peak-a-boo view of sign up sheet
    [UIView transitionWithView:self.view
                      duration:0.2
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^ {
                        [self.view viewWithTag:infoViewTag].alpha = 0.0; // info view tag
                        [self.view viewWithTag:blackBackgroundTag].alpha = 0.0; // black background tag
                    }
                    completion:^(BOOL finished) {
                        [[self.view viewWithTag:infoViewTag] removeFromSuperview];
                        [[self.view viewWithTag:blackBackgroundTag] removeFromSuperview];
                    }];
    
}

/** End InfoViews **/

/* Search for Profiles */
-(void)searchProfiles {
    _searchView = [[SearchView alloc] init];
    _searchView.view.tag = searchViewTag;
    _searchView.mainAccount = _mainAccount;
    _searchView.view.frame = CGRectMake(0.0, 0.0,
                                       self.view.frame.size.width,
                                       self.view.frame.size.height);
    _searchView.view.alpha = 0.0;
    _searchView.delegate = self;
    [_searchView loadSearchContent]; // preps the search screen

    [self showBlackBackgroundEffect]; // background black fade
    
    [self.view addSubview:_searchView.view];

    // Show Search Profile View
    [UIView transitionWithView:self.view
                      duration:0.2
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^ {
                        _searchView.view.alpha = 1.0;
                        [self.view viewWithTag:blackBackgroundTag].alpha = 1.0;
                    }
                    completion:^(BOOL finished) { }];
}

-(void)dismissSearch {
    
    // Dismiss Bar
    [SVProgressHUD dismiss];
    
    [UIView transitionWithView:self.view
                      duration:0.3
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^ {
                        _searchView.view.alpha = 0.0;
                        [self.view viewWithTag:blackBackgroundTag].alpha = 0.0;
                    }
                    completion:^(BOOL sucess){
                        [[self.view viewWithTag:searchViewTag] removeFromSuperview];
                        [[self.view viewWithTag:blackBackgroundTag] removeFromSuperview];
                    }];
}

/*** Creating a Jam ***/
-(void)createSesh:(NSString*)type {
    /* Create Session and set its data to a dictionary to store info in DB */
    
    // progress bar
    [SVProgressHUD showWithStatus:@"Loading necessary info"];
    
    /* Update the local _mainAccount object with the new DB info BEFORE CREATING ANY SESSIONS */
    [Account loadAccount:kBaseURL userName:_mainAccount.userName initialLoad:@"no" message:_mainAccount._accountid callback:^(NSError *error, BOOL success, NSDictionary *responseAccount, NSInteger statusCode) {
        if (success && [responseAccount objectForKey:@"userName"] != nil) {
            SPAM(("\nGot Account success -- Updating mainAccount local object with new data\n"));
            
            /* Must do segue in main thread */
            runOnMainThreadWithoutDeadlocking(^{
                
                // Dismiss Bar
                [SVProgressHUD dismiss];
                
                _mainAccount = nil; // about to be reloaded
                _mainAccount = [[Account alloc] init];
                
                /* Init tmpAccount with Sign Up's account info */
                [_mainAccount initWithDictionary:responseAccount];
                
                /* Main Account can not already have a session in place */
                if ([_mainAccount.accountSessionID count] >= 3) {
                    /* Loading alert box */
                    [AlertView showAlertControllerOkayOption:@"You may only host up to three Jams at a time..." message:@"You must END or CANCEL one of your Jams" view:self];
                } else {
                    if ([type isEqualToString:@"Recreational"]) {
                        NSString * storyboardName = @"Main";
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                        
                        SeshLeisureController * slc = [storyboard instantiateViewControllerWithIdentifier:@"SeshLeisureController"];
                        
                        slc.mainAccountUsername = self.mainAccount.userName;
                        slc.mainAccountFriendList = self.mainAccount.friendsList;
                        slc.seshController = nil;
                        slc.delegate = self;
                        
                        [self presentViewController:slc animated:true completion:nil];
                    } else { // Competition
                        NSString * storyboardName = @"Main";
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                        
                        SeshController * sc = [storyboard instantiateViewControllerWithIdentifier:@"SeshController"];
                        
                        sc.mainAccountUsername = self.mainAccount.userName;
                        sc.mainAccountFriendList = self.mainAccount.friendsList;
                        sc.seshController = nil;
                        sc.delegate = self;
                        
                        [self presentViewController:sc animated:true completion:nil];
                    }
                }
            });
        } else { // failure to load account
            // Dismiss HUD
            [SVProgressHUD dismiss];
            /* Loading alert box */
            [AlertView showAlertControllerOkayOption:@"Trouble loading info to create a Jam" message:@"Please try again" view:self];
        }
    }];
}

-(void)createCompJam {
    [self dismissViewControllerAnimated:YES completion:^{
        [self createSesh:@"Competition"];
    }];
}

-(void)createRecJam {
    [self dismissViewControllerAnimated:YES completion:^{
        [self createSesh:@"Recreational"];
    }];
}

/** End creating a Jam **/

/* Edit Profile Page */
- (void)editProfile {
    /* Edit Profile Page */
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    editProfileController * ec = [storyboard instantiateViewControllerWithIdentifier:@"editProfileController"];
    
    ec.editAccount = self.mainAccount;
    ec.deleAcc = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).defaultAccount;
    ec.delegate = self;
    
    [self presentViewController:ec animated:true completion:nil];
}
/* Edit Profile delegate */
-(void)endEdit:(NSString*)tag {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([tag isEqualToString:@"0"]) {
            // nothing updated
        } else {
            [AlertView showAlertTab:@"Profile updated successfully" view:self.view];
        }
    }];
}


- (void)viewProfile {
    /* View Profile Page */
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    ProfileController * pc = [storyboard instantiateViewControllerWithIdentifier:@"ProfileController"];
    
    pc.profileAccount = _mainAccount; // Same account in this particular setting
    pc.loggedInAccount = _mainAccount;
    
    [self presentViewController:pc animated:true completion:nil];
}

/** Map View Delegates **/
-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    
}

-(void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    _centerLat = position.target.latitude;
    _centerLong = position.target.longitude;
}

// Remove bot view if tapped screen
-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if (_botView != nil) { // remove sign up view
        [self removeBotView];
    }
    if ([self.view viewWithTag:dailyMessageViewTag] != nil) { // removes DM
        [self removeDM];
    }
}

- (void)mapView:(GMSMapView *)mapView didLongPressInfoWindowOfMarker:(nonnull GMSMarker *)marker {
    SPAM(("\nID: %s\n", [marker.userData[@"_id"] UTF8String]));
    // call cancel sesh
    
    NSString* jamID = marker.userData[@"_id"];
    BOOL isHost = false;
    Session *markerJam;
    int indexOfJam = -1;
    
    // Get Index of Jam in jamSession arrays
    for (int i = 0; i < [self.jamSessions count]; i++) {
        Session *tmpJam = (Session*)[self.jamSessions objectAtIndex:i];
        if ([tmpJam._id isEqualToString:jamID]) {
            markerJam = (Session*)[self.jamSessions objectAtIndex:i];
            if ([markerJam.sessionHostName isEqualToString:_mainAccount.userName]) {
                isHost = true;
                indexOfJam = i;
            }
            break;
        }
    }
    
    if (isHost && indexOfJam != -1)
        [self cancelSesh:markerJam index:indexOfJam];

}

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    [self showSignUpView:marker.userData[@"_id"]];
    return false;
}

/* Show Sign Up View */
-(void)showSignUpView:(NSString*)seshID  {
    /* Bot view doesn't exist */
    if ([self.view viewWithTag:bottomSignUpViewTag] != nil) {
        [[self.view viewWithTag:bottomSignUpViewTag] removeFromSuperview];
    }
    
    /* Set to nil, about to be loaded */
    self.tmpSession = nil;
    
    /* Get the session by using the marker's set session _id */
    for (Session *s in self.jamSessions) {
        if ([s._id isEqualToString:seshID]) {
            SPAM(("\nFound marker's session in DB\n"));
            self.tmpSession = s; // Set the sign up session
            break;
        }
    }
    
    /* Check if a session was found */
    if (self.tmpSession != nil) {

        [self setUpSignUpView];
        [self addChildViewController: _botView];
        [self.view addSubview:_botView.view];
        
        // Show peak-a-boo view of sign up sheet
        [UIView transitionWithView:self.view
                          duration:0.2
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^ {
                            _botView.view.frame = CGRectMake(0.0,
                                                            self.view.frame.size.height-_botView.SignUpButton.frame.origin.y-50.0,
                                                             self.view.frame.size.width,
                                                             self.view.frame.size.height);
                        }
                        completion:nil];
        
        [_botView didMoveToParentViewController:self];
    }
    
}

-(void)setUpSignUpView {
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    _botView = [storyboard instantiateViewControllerWithIdentifier:@"SignUpController"]; // loads constraints and subView placement
    _botView.view.tag = bottomSignUpViewTag;
    _botView.mainSignUpSession = self.tmpSession;
    _botView.loggedInSignUpAccount = self.mainAccount;
    [_botView loadSessionContent:_localSignUpPictureCache]; // load data from session
    
    /* Swipe down to remove */
    _botView.swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(removeBotView)];
    _botView.swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [_botView.view addGestureRecognizer:_botView.swipeDown];
    
    _botView.view.frame = CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height); // start off screen
    _botView.view.layer.cornerRadius = 10; // rounded edges
    _botView.view.clipsToBounds = YES;
    
    _botView.fromAppDelegateSignUp = false;
    
    _botView.delegate = self;
}

/* Remove Signup (pull up) view*/
-(void)removeBotView {
    [UIView transitionWithView:self.view
                      duration:0.1
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^ {
                        [self.view viewWithTag:bottomSignUpViewTag].frame = CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                    }
                    completion:^(BOOL finished) { [[self.view viewWithTag:bottomSignUpViewTag] removeFromSuperview]; _botView = nil; }];
}

// Delegate method from singUpSheet
-(void)refreshMarker:(NSString*)seshID {
    
    // Reload Jam session
    [Session loadSession:kBaseURL seshID:seshID message:_mainAccount._accountid callback:^(NSError *error, BOOL success, NSDictionary *responseSession) {
        if (success && responseSession != nil) {
            runOnMainThreadWithoutDeadlocking(^{
                // Remove from local Data stuctures
                int index = 0;
                for (Session *s in _jamSessions) {
                    if ([s._id isEqualToString:seshID]) {
                        [_jamSessions removeObjectAtIndex:index];
                        break;
                    }
                    index+=1;
                }
                
                // Remove from marker dictionary
                GMSMarker *tmpMarker = _jamSesssionMarkers[seshID];
                tmpMarker.map = nil;
                [_jamSesssionMarkers removeObjectForKey:seshID];
                [_localSignUpPictureCache removeObjectForKey:seshID];
                
                /* Load Session from DB */
                NSArray *responseArray = @[responseSession]; // array with reloaded Jam session object
                
                [self parseAndAddLocations:responseArray toArray:self.jamSessions];
                /* Create marker objects and place on map */
                [self createAndAddMarkers:false];
            });
        } else {
            // This means the database has been updated with jammer info, but could not retrieve the marker
            // Thus, jammer list on DB and locally are updated, color out of date
            runOnMainThreadWithoutDeadlocking(^{
                // Remove from local Data stuctures
                int index = 0;
                for (Session *s in _jamSessions) {
                    if ([s._id isEqualToString:seshID]) {
                        [_jamSessions removeObjectAtIndex:index];
                        break;
                    }
                    index+=1;
                }
                
                // Remove from marker dictionary
                GMSMarker *tmpMarker = _jamSesssionMarkers[seshID];
                tmpMarker.map = nil;
                [_jamSesssionMarkers removeObjectForKey:seshID];
                [_localSignUpPictureCache removeObjectForKey:seshID];
            
                
                [AlertView showAlertControllerOkayOption:@"Trouble refreshing Jam" message:@"Try refreshing map" view:self];
                
            });
        }
    }];
}

// Delegate called from signUp sheet, open up a jam form with details set in place
-(void)editJam:(Session*)mainSession editSession:(Session*)editSession {
    
    // Remove bot view
    [self removeBotView];
    
    if ([editSession.LeisureorComp isEqualToString:@"leisure"]) {
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        
        SeshLeisureController * slc = [storyboard instantiateViewControllerWithIdentifier:@"SeshLeisureController"];
        
        slc.mainAccountUsername = self.mainAccount.userName;
        slc.mainAccountFriendList = self.mainAccount.friendsList;
        slc.seshController = editSession; // temp session that is being edited
        slc.mainLocalSession = mainSession; 
        slc.delegate = self;
        
        [self presentViewController:slc animated:true completion:nil];
    } else { // comp
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        
        SeshController * sc = [storyboard instantiateViewControllerWithIdentifier:@"SeshController"];
        
        sc.mainAccountUsername = self.mainAccount.userName;
        sc.mainAccountFriendList = self.mainAccount.friendsList;
        sc.seshController = editSession; // temp session that is being edited
        sc.mainLocalSession = mainSession;
        sc.delegate = self;
        
        [self presentViewController:sc animated:true completion:nil];
    }
}

// -- Delegate method from SeshController/LeisureController
// Gets new image id's the updates Session object in DB, or just updates Session Object in DB
// New Pics are appeneded to already saved pics on server
-(void)finishEditingJam:(Session*)mainSession editSession:(Session *)editSession extraPicturesArr:(NSMutableArray*)extraPicturesArr extraFriendsArr:(NSMutableArray*)extraFriendsArr {
    
    // Add progress bar
    [self createEditJamProgressBar];
    
    /* Add extra friends to session object if the name does not exist before it is updated */
    for (int i = 0; i < [extraFriendsArr count]; i++) {
        if (![editSession.invitedFriends containsObject:[extraFriendsArr objectAtIndex:i]]) {
            [editSession.invitedFriends addObject:[extraFriendsArr objectAtIndex:i]];
        }
    }
    
    [self updateEditJamStatusBar];
    
    if ([extraPicturesArr count] == 0) { // no new pictures added!! -- just update Sesion object
        [self updateEditJamStatusBar];
        [self sendEditToDB:mainSession editSession:editSession extraFriendsArr:extraFriendsArr];
    } else {
        // Background Thread, gets Image ID's
        __block int imagesGotID = 0;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
            
            for (int i = 0; i < [extraPicturesArr count]; i++) { // runs for each new picture added
                
                UIImage *preImage = [extraPicturesArr objectAtIndex:i];
                NSData* bytesImage = UIImageJPEGRepresentation(preImage, 0.8);
                
                [ImageVideoUploader getImageIDDB:kBaseURL collection:kFiles objData:bytesImage VideoOrImg:@"image" message:_mainAccount._accountid callback:^(NSError *error, BOOL success, NSDictionary *responseDic) {
                    
                    if (success && responseDic != nil) {
                        [editSession.sessionPictureIDs insertObject:responseDic[@"_id"] atIndex:0]; // insert ID at the front
                        [self updateEditJamStatusBar];
                        imagesGotID += 1;
                        
                        /* Ready to add to DB */
                        if (imagesGotID == [extraPicturesArr count]) {
                            [self sendEditToDB:mainSession editSession:editSession extraFriendsArr:extraFriendsArr];
                        }
                    } else { // error
                        NSLog(@"Error in getting a Image ID: -- %@\n", error);
                        runOnMainThreadWithoutDeadlocking(^{
                            [self cancelEditJamStatusBar];
                            [AlertView showAlertTab:@"Could not update Jam..." view:self.view]; // if error
                        });
                    }
                }]; // end getImageIDDB
            } // end for loops
        }); // end dispatch
    }
}

-(void)sendEditToDB:(Session*)mainSession editSession:(Session *)editSession extraFriendsArr:(NSMutableArray*)extraFriendsArr {
    [Session editJam:kBaseURL session:editSession message:_mainAccount._accountid callback:^(NSError *error, BOOL success) {
        runOnMainThreadWithoutDeadlocking(^{
            [self updateEditJamStatusBar];
            // Refresh the marker
            if (success) {
                [self refreshMarker:mainSession._id];
                // Send APN to Invited Jammers
                [self sendAPNInvitedJammers:editSession extraFriendsArr:extraFriendsArr];
            }
        });
    }];
}

-(void)sendAPNInvitedJammers:(Session*)jam extraFriendsArr:(NSMutableArray*)extraFriendsArr {
    
    /* Call function that sends push notifications to sessions.invitedFriends list */
    
    NSMutableArray *friendArr;
    if (extraFriendsArr == nil) { // not editing the jam!!
        friendArr = jam.invitedFriends;
     } else {
        friendArr = extraFriendsArr;
    }
    
    for (NSString *friend in friendArr) {
        
        [Account loadAccount:kBaseURL userName:friend initialLoad:@"no" message:_mainAccount._accountid callback:^(NSError *error, BOOL success, NSDictionary *responseAccount, NSInteger statusCode) {
            
            if (success && [responseAccount objectForKey:@"userName"] != nil) {
                
                SPAM(("\nSENING APN to Friend!\n"));
                
                NSString *noteToken = responseAccount[@"notificationToken"];
                NSString *userName = responseAccount[@"userName"];
                NSString *seshID = jam._id;
                
                NSString *dateOrTime;
                // Give date or time depending on the day
                if (![_currDate isEqualToString:jam.jamDate]) {
                    dateOrTime = jam.jamDate;
                } else { // set the time as the message
                    dateOrTime = jam.startTime;
                }
                
                /* Send Notification */
                NSString *tokenStr = [[NSString alloc] initWithFormat:@"%@", noteToken];
                NSString *messageStr = [[NSString alloc] initWithFormat:@"Invited to Jam by %@|%@ - %@", jam.sessionHostName, dateOrTime, jam.jamType];
                NSString *payloadStr = [[NSString alloc] initWithFormat:@"%@|%@", seshID, userName];
                
                // SEND A TIME STAMP!
                NSString* timeStamp = [Constants getUTCTime];
                
                NSDictionary *headers = @{ @"content-type": @"application/json", //@"application/x-www-form-urlencoded",
                                           @"cache-control": @"no-cache",
                                           @"Proxy-Authorization": [Constants getEncryptConstant:_mainAccount._accountid],
                                           @"Authorization": [Constants encryptKeyOnce:timeStamp],
                                           @"x-req": _mainAccount._accountid
                                           };
                
                NSURL *url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:@"sendNotification"]];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                   timeoutInterval:10.0];

                NSData* dataBody = [NSJSONSerialization dataWithJSONObject:[self jammersCurrLocationJSON:tokenStr payload:payloadStr message:messageStr] options:0 error:nil]; // session object has updated info
                request.HTTPBody = dataBody;
                
                [request setHTTPMethod:@"POST"];
                [request setAllHTTPHeaderFields:headers];
                
                NSURLSession *session = [NSURLSession sharedSession];
                NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                if (error) {
                                                                    SPAM(("\nAPN Error\n"));
                                                                } else {
                                                                    SPAM(("\nAPN Went Thru\n"));
                                                                }
                                                            }];
                [dataTask resume];
            } else {
                SPAM(("APN load account did not work!!\n")); // Load account did not work
            }
        }];
    }
}

-(NSMutableDictionary*)jammersCurrLocationJSON:(NSString*)token payload:(NSString*)payload message:(NSString*)message {
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    /* 2 items saved right now -- 10/2/2017 */
    jsonable[@"token"] = token;
    jsonable[@"message"] = message;
    jsonable[@"payload"] = payload;
    return jsonable;
}

/* Marker has been placed, save to DB
 * Place marker, function called from SeshController.m/SeshLesisureController.m */
-(void)placeMarker:(Session*)session {
    SPAM(("\nPlacing Sesh Marker\n"));
    
    // Show alert
    [AlertView showAlertTab:@"Creating Jam...Loading Marker" view:self.view];
    
    // Progress bar
    [self createJamProgressBar];
    
    /* Set the three attributes that are not filled in
       within the Create Session View */
    session.sessionLat = [NSString stringWithFormat:@"%f", _centerLat];
    session.sessionLong = [NSString stringWithFormat:@"%f", _centerLong];
    session.jammers = [[NSMutableArray alloc] init]; // Empty set, will be filled
    [session.jammers addObject:_mainAccount.userName]; // AUTO ADD THE HOST!!! -- can not take them selves off list
    
    // Reverse geoCode location and add it to the session object (lat, long --> "city, country")
    CLLocation *jamLocation = [[CLLocation alloc]
                             initWithLatitude:_centerLat
                             longitude:_centerLong];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:jamLocation
     completionHandler:^(NSArray *placemarks, NSError *error) {
         if (error == nil && [placemarks count] > 0) {
             CLPlacemark *placemark = [placemarks lastObject];
             NSString *vendorLocation = [NSString stringWithFormat:@"%s,%s,%f,%f",
                                          [placemark.locality UTF8String],
                                          [placemark.country UTF8String], _centerLat, _centerLong];
             
             SPAM(("\nLOCATION: - %s\n", [vendorLocation UTF8String]));
             session.jamLocation = vendorLocation;
         } else { // could not get location
             SPAM(("\nCould not get Location - only store Lat and Long of Jam...\n"));
             session.jamLocation = [NSString stringWithFormat:@" , ,%f,%f", _centerLat, _centerLong];
         }
         
         /* 1. Get Image ID's
          2. Call persist */
         if ([session.LeisureorComp isEqualToString:@"comp"]) {
             [self saveNewLocationImageFirst:session];
         } else { // for Leisure
             /* If no image, just add it to DB with Persist */
             if ([session.sessionPictures count] != 0) {
                 [self saveNewLocationImageFirst:session]; // Leisure
             } else {
                 
                 [self updateJamStatusBar]; // update progressbar -- 1 (no pictures)
                 [self updateJamStatusBar]; // update progressbar -- 2 (no pictures)
                 
                 __weak ViewController *weakSelf = self;
                 /* Add to DB and mapView */
                 [self addJamToDB:session callback:^(NSError *error, BOOL success, NSArray *responseArray) {
                     if (success && responseArray != nil) {
                         SPAM(("\nSuccess callback, persist\n"));
                            
                         /* Only adds the one new created session */
                         [weakSelf parseAndAddLocations:responseArray toArray:weakSelf.jamSessions];
                         
                         runOnMainThreadWithoutDeadlocking(^{
                             /* Create marker objects and place on map */
                             [AlertView showAlertTab:@"Created Jam!" view:weakSelf.view];
                             [weakSelf createAndAddMarkers:true];
                             
                         });
                     } else {
                         SPAM(("\nCall back didn't work from persist\n"));
                     }
                 }]; // end persist
             }
         }
     }]; // end geoCode
}

/** Progress bars **/
/* Create Jam progress bar */
-(void)createJamProgressBar {
    // Refresh status bar
    UIProgressView *progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(10.0, (_refreshButton.frame.origin.y-15.0),
                                                                                   self.view.frame.size.width-20.0,
                                                                                   20.0)];
    progressBar.tag = createJamProgressBarTag;
    
    UILabel *creatingJamLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                          progressBar.frame.origin.y-35.0,
                                                                          self.view.frame.size.width, 35.0)];
    creatingJamLabel.tag = createJamLabelProgressBarTag;
    creatingJamLabel.textAlignment = NSTextAlignmentCenter;
    creatingJamLabel.text = @"Creating Jam...";
    creatingJamLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    
    [self.view addSubview:creatingJamLabel];
    [self.view addSubview:progressBar];
}

-(void)updateJamStatusBar {
    runOnMainThreadWithoutDeadlocking(^{
        UIProgressView *progressBar = (UIProgressView*)[self.view viewWithTag:createJamProgressBarTag];
        float ogProgress = [progressBar progress]+0.25; // 4 progresses
        [progressBar setProgress:ogProgress animated:YES];
        if (ogProgress >= 1.0) {
            [self cancelJamStatusBar]; // cancel progress bar
        }
    });
}

-(void)cancelJamStatusBar {
    [[self.view viewWithTag:createJamProgressBarTag] removeFromSuperview];
    [[self.view viewWithTag:createJamLabelProgressBarTag] removeFromSuperview];
}

/* Entry Submit progress bar */
-(void)createEntryProgressBar {
    // Refresh status bar
    UIProgressView *progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(10.0, (_refreshButton.frame.origin.y-15.0),
                                                                                   self.view.frame.size.width-20.0,
                                                                                   20.0)];
    progressBar.tag = submitEntryProgressBarTag;
    
    UILabel *submitEntryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                          progressBar.frame.origin.y-35.0,
                                                                          self.view.frame.size.width, 35.0)];
    submitEntryLabel.tag = submitEntryLabelProgressBarTag;
    submitEntryLabel.textAlignment = NSTextAlignmentCenter;
    submitEntryLabel.text = @"Submitting Entry...";
    submitEntryLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    
    [self.view addSubview:submitEntryLabel];
    [self.view addSubview:progressBar];
}

-(void)updateEntryStatusBar {
    runOnMainThreadWithoutDeadlocking(^{
        UIProgressView *progressBar = (UIProgressView*)[self.view viewWithTag:submitEntryProgressBarTag];
        float ogProgress = [progressBar progress]+0.34; // 3 progresses
        [progressBar setProgress:ogProgress animated:YES];
        if (ogProgress >= 1.0) {
            [self cancelEntryStatusBar]; // cancel progress bar
        }
    });
}

-(void)cancelEntryStatusBar {
    [[self.view viewWithTag:submitEntryProgressBarTag] removeFromSuperview];
    [[self.view viewWithTag:submitEntryLabelProgressBarTag] removeFromSuperview];
}

/* EditJam progress bar */
-(void)createEditJamProgressBar {
    // Refresh status bar
    UIProgressView *progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(10.0, (_refreshButton.frame.origin.y-15.0),
                                                                                   self.view.frame.size.width-20.0,
                                                                                   20.0)];
    progressBar.tag = editJamProgressBarTag;
    
    UILabel *submitEntryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                          progressBar.frame.origin.y-35.0,
                                                                          self.view.frame.size.width, 35.0)];
    submitEntryLabel.tag = editJamLabelProgressBarTag;
    submitEntryLabel.textAlignment = NSTextAlignmentCenter;
    submitEntryLabel.text = @"Editing Jam...";
    submitEntryLabel.font = [UIFont fontWithName:@"ActionMan" size:17.0];
    
    [self.view addSubview:submitEntryLabel];
    [self.view addSubview:progressBar];
}

-(void)updateEditJamStatusBar {
    runOnMainThreadWithoutDeadlocking(^{
        UIProgressView *progressBar = (UIProgressView*)[self.view viewWithTag:editJamProgressBarTag];
        float ogProgress = [progressBar progress]+0.34;
        [progressBar setProgress:ogProgress animated:YES];
        if (ogProgress >= 1.0) {
            [self cancelEditJamStatusBar]; // cancel progress bar
        }
    });
}

-(void)cancelEditJamStatusBar {
    [[self.view viewWithTag:editJamProgressBarTag] removeFromSuperview];
    [[self.view viewWithTag:editJamLabelProgressBarTag] removeFromSuperview];
}

/**** DB METHODS ****/

/* Response array is a list of session objects, to be turned into markers */
-(void)importJamsFromDB:(void (^)(NSError *error, BOOL success, NSArray *responseArray))callback {
    SPAM(("\nImporting Markers\n"));
    
    NSURL* url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kMarkers]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    // Set Up Auth
    [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:_mainAccount._accountid];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil && data != nil) {
            SPAM(("\nInside data task, importing markers\n"));
            NSArray* responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            callback(error, YES, responseArray); // call to callback in viewDidLoad
        } else {
            runOnMainThreadWithoutDeadlocking(^(void) {
                [AlertView showAlertTab:@"Error Loading Jams, Refresh Map" view:self.view];
                
            });
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
    
    [dataTask resume];
}


/* Adding session to DB, currently only called when a new Session is added */
-(void)addJamToDB:(Session*)session callback:(void (^)(NSError *error, BOOL success, NSArray *responseArray))callback {
    SPAM(("\nPersist\n"));
    
    if (!session || session.sessionHostName == nil || session.sessionHostName.length == 0) {
        return; //input safety check
    }
    
    NSString* locations = [kBaseURL stringByAppendingPathComponent:kMarkers];
    
    NSURL* url = [NSURL URLWithString:locations];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // Set Up Auth
    [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:_mainAccount._accountid];
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:[session toDictionary] options:0 error:nil]; // session object has updated info
    request.HTTPBody = data;
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* URLsession = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [URLsession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) {
            NSArray* responseArray = @[[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]];
            
            if ([responseArray count] > 0) {
                NSDictionary *jamObj = [responseArray firstObject];
                session._id = jamObj[@"_id"]; // get jam ID from DB response
                SPAM(("Success, adding Session %s to DB\n", [session._id UTF8String]));
            }
            
            if (!error && [session._id length] != 0 && session._id != nil) {
                runOnMainThreadWithoutDeadlocking(^{
                    // Send APN to Invited Jammers
                    [self sendAPNInvitedJammers:session extraFriendsArr:nil]; // pass in empty array
                    
                    [self updateJamStatusBar]; // update progressbar -- 3
                    
                }); // end main que dispatch
                
                callback(error, YES, responseArray); // call to callback in placeMarkers
                
            } else {
                NSLog(@"Error adding Session %s to DB -- %@\n", [session._id UTF8String],[error localizedDescription]);
                runOnMainThreadWithoutDeadlocking(^{
                    [self cancelJamStatusBar]; // cancel progress bar
                    /* Loading alert box */
                    [AlertView showAlertControllerOkayOption:@"Trouble creating Jam" message:@"Please try again" view:self];
                });
            }
        } else {
            // Data is nil
            runOnMainThreadWithoutDeadlocking(^{
                [self cancelJamStatusBar]; // cancel progress bar
                /* Loading alert box */
                [AlertView showAlertControllerOkayOption:@"Trouble creating Jam" message:@"Please try again" view:self];
            });
        }
    }];
    [dataTask resume];
}

/**
 Saving and loading files requires an extra request for each object to transfer the file data. The order of operations is important 
 to make sure the file id is property associated with the object. When you save a file, you must send the file first in order to 
 receive the associated id to link it with the location’s data.
 **/
/* Saves both Images (Rail and Prize, if they exist), then will only call one Persist function based on 
   which picture ID is retrieved first */
-(void)saveNewLocationImageFirst:(Session*)session {
    SPAM(("\nsaveNewLocationImageFirst -- %s\n", [session.LeisureorComp UTF8String]));
    
    [self updateJamStatusBar]; // update progressbar -- 1 (has pictures)
    
    /* To see when to call persist, making sure both imageID's have been retrieved */
    __block int imagesGotID = 0;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        // Background Thread, gets Image ID's
        SPAM((" -- Saving a pic\n"));
        
        for (UIImage *preImage in session.sessionPictures) {
            NSData* bytesRail = UIImageJPEGRepresentation(preImage, 0.8);
            
            [ImageVideoUploader getImageIDDB:kBaseURL collection:kFiles objData:bytesRail VideoOrImg:@"image" message:_mainAccount._accountid callback:^(NSError *error, BOOL success, NSDictionary *responseDic) {
                
                if (success && responseDic != nil) {
                    [session.sessionPictureIDs addObject:responseDic[@"_id"]];
                    
                    imagesGotID += 1;
                    
                    /* Ready to add to DB */
                    if (imagesGotID == [session.sessionPictures count]) {
                        SPAM(("Calling Persist\n"));
                        
                        [self updateJamStatusBar]; // update progressbar -- 2 (has pictures)
                        
                        __weak ViewController *weakSelf = self;
                        /* Adds to DB and map view */
                        [self addJamToDB:session callback:^(NSError *error, BOOL success, NSArray *responseArray) {
                            if (success && responseArray != nil) {
                                SPAM(("\nSuccess callback, persist\n"));
                                
                                /* Only adds the one new created session */
                                [weakSelf parseAndAddLocations:responseArray toArray:weakSelf.jamSessions];
                                
                                /* Loading alert box */
                                runOnMainThreadWithoutDeadlocking(^{
                                    [AlertView showAlertTab:@"Created Jam!" view:weakSelf.view];
                                    /* Create marker objects and place on map */
                                    [weakSelf createAndAddMarkers:true];
                                });
                            } else {
                                SPAM(("\nCall back didn't work from persist\n"));
                            }
                        }]; // end persist
                    }
                
                } else { // error
                    NSLog(@"Error in getting a Image ID: -- %@\n", error);
                    runOnMainThreadWithoutDeadlocking(^{
                        [self cancelJamStatusBar];// cancel progress bar
                        /* Loading alert box */
                        [AlertView showAlertControllerOkayOption:@"Trouble uploading Jam pictures" message:@"Please try again (connecting to WiFi will help this cause)" view:self];
                    });
                }
                
            }]; // end getImageIDDB
        } // end for loops
    }); // end dispatch
}

/* Saves Video, also updates entry submission and increases user's submission number
   -- is called on main thread */
-(void)saveEntryVideo:(NSData*)videoData imageOrVideo:(NSString *)imageOrVideo entryDescription:(NSString*)entryDescription {
    SPAM(("\nsaveEntryVideo - Saving Entry\n"));
    
    [self updateEntryStatusBar]; // update entry submit bar -- 1
    
    NSData* bytesVideo = videoData; // NSData element for the video
    
    [ImageVideoUploader getImageIDDB:kBaseURL collection:kEntryVideos objData:bytesVideo VideoOrImg:imageOrVideo message:_mainAccount._accountid callback:^(NSError *error, BOOL success, NSDictionary *responseDic) {
        
        if (error == nil && responseDic != nil) {
            SPAM(("\nEntry ID Retrived\n"));
            
            [self updateEntryStatusBar]; // update entry submit bar -- 2
            
            /* Create Entry*/
            VideoEntry *entry = [[VideoEntry alloc] initaccountID:_mainAccount._accountid videoID:responseDic[@"_id"] username:_mainAccount.userName hometown:_mainAccount.hometown entryDescription:entryDescription aContentType:imageOrVideo];
            
            /* Add Entry */
            [entry addEntry:kBaseURL message:_mainAccount._accountid userName:_mainAccount.userName callback:^(NSError *error, BOOL success) {
                if (success) {
                    
                    // updates accounts dailySubmissionNumber (already happened on DB)
                    int dailySubmissionNumber = [_mainAccount.dailySubmissionNumber intValue];
                    _mainAccount.dailySubmissionNumber = [NSNumber numberWithInt:dailySubmissionNumber + 1];
                    
                    runOnMainThreadWithoutDeadlocking(^{
                        [self updateEntryStatusBar]; // update entry submit bar -- 3
                        /* Tell user -- Loading alert box */
                        [AlertView showAlertTab:@"Entry Submitted!" view:self.view];
                    });
                } else {
                    runOnMainThreadWithoutDeadlocking(^{
                        [self cancelEntryStatusBar]; // cancel update bar
                        /* Loading alert box */
                        [AlertView showAlertControllerOkayOption:@"Trouble not Upload Entry" message:@"Try again -- Entry submissions will upload quicker if you are connected to WiFi!" view:self];
                    });
                }
            }];
        } else {
            NSLog(@"ERROR: %@\n", error);
            runOnMainThreadWithoutDeadlocking(^{
                [self cancelEntryStatusBar]; // cancel update bar
                /* Loading alert box */
                [AlertView showAlertControllerOkayOption:@"Trouble not Upload Entry" message:@"Try again -- Entry submissions will upload quicker if you are connected to WiFi!" view:self];
            });
        }
    }]; // end getID
}


/********************************************** END DB METHODS ***************************************************************/

/* Main thread function */
void runOnMainThreadWithoutDeadlocking(void (^block)(void)) {
    if ([NSThread isMainThread]) {
        block(); // if already on main que, just call block of code
    } else {
        dispatch_sync(dispatch_get_main_queue(), block); // execute passed in block of code on main queue
    }
}

/** Button Selection Code **/
-(IBAction)buttonNormal:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == createJamButtonTag) { // create session
        button.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5];
    }
}

-(IBAction)buttonDown:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == createJamButtonTag) { // create session
        button.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1.0];
    } else if (button.tag == cancelJamButtonTag) { // cancel
        button.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1.0];
    }
}

/* Spacing in text views */
- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    return 8; // Line spacing of 19 is roughly equivalent to 5 here.
}

/** Text View Delegates **/
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.tag == entryDescriptionTextViewTag) { // submitting an entry
        if ([textView.text isEqualToString:@"Enter a description..."]) {
            textView.text = @"";
            textView.textColor = [UIColor blackColor];
        } else {
            textView.textColor = [UIColor blackColor];
        }
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {

}

// Removes Keyboard with "return" key -  For entry submission!
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    return YES;
}

/** End Text View Delegates **/

/* SEGUE CODE */
// Pass in info to next page
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender { }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
