
//
//  Account.m
//  RailJam
//
//  Created by Ben Ferraro on 6/24/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"

@implementation Account

static NSString* const kAccounts = @"accounts";


-(id)inituserName:(NSString *)aUserName name:(NSString*)aName email:(NSString *)aEmail password:(NSString *)aPassword hometown:(NSString*)aHometown lastLogOn:(NSString *)aLastLogOn {
    _userName = aUserName;
    _email = aEmail;
    _password = aPassword;
    _hometown = aHometown;
    _name = aName;
    _lastLogOn = aLastLogOn;
    _accountBio = @"";
    _accountPicture = nil;
    _accountPictureID = @"";
    _notificationToken = @"";
    _firstTimeDojo = @"yes";
    
    _accountSessionID = [[NSMutableArray alloc] init]; // max 3
    
    _friendsList = [[NSMutableArray alloc] init];
    _featureVideoIDs = [[NSMutableArray alloc] init];
    
    _profileLineColor = [[NSMutableArray alloc] initWithArray:@[@"255.0",@"255.0",@"255.0"]];
    _profileUNColor = [[NSMutableArray alloc] initWithArray:@[@"0.0",@"0.0",@"0.0"]];
    
    _dailyVoteNumber = [NSNumber numberWithInt:0];
    _dailySubmissionNumber = [NSNumber numberWithInt:0];
    
    _badgeNum = [NSNumber numberWithInt:0];
    
    // Properties that the are updated only on the server side
    _placesIveJammed = [[NSMutableArray alloc] init];
    _wins = [NSNumber numberWithInt:0];
    _numberOfSessionsAttended = [NSNumber numberWithInt:0];
    _totalVideoVotes = [NSNumber numberWithInt:0];
    _totalPoints = [NSNumber numberWithInt:0];
    
    return self;
}

-(void)toString {
    SPAM(("%s | ", [self._accountid UTF8String]));
    SPAM(("%s | ", [self.userName UTF8String]));
    SPAM(("%s | ", [self.email UTF8String]));
    SPAM(("%s | ", [[self.wins stringValue] UTF8String]));
    SPAM(("%s | ", [[self.numberOfSessionsAttended stringValue] UTF8String]));
    SPAM(("%s | ", [self.lastLogOn UTF8String]));
    SPAM(("Count in placesIveJammed: %lu\n", (unsigned long)[self.placesIveJammed count]));
    
}

// POST/PUT
/* Used to Create a JSON object to be put into DB */
#define safeSet(d,k,v) if (v) d[k] = v;
-(NSMutableDictionary*)toDictionary {
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    /* 24 items saved right now -- 11/28/2017 */
    safeSet(jsonable, @"_id", self._accountid);
    safeSet(jsonable, @"userName", self.userName);
    safeSet(jsonable, @"name", self.name);
    safeSet(jsonable, @"password", self.password);
    safeSet(jsonable, @"email", self.email);
    safeSet(jsonable, @"hometown", self.hometown);
    safeSet(jsonable, @"lastLogOn", self.lastLogOn);
    safeSet(jsonable, @"accountSessionID", self.accountSessionID);
    safeSet(jsonable, @"accountPictureID", self.accountPictureID);
    safeSet(jsonable, @"accountBio", self.accountBio);
    safeSet(jsonable, @"firstTimeDojo", self.firstTimeDojo);
    safeSet(jsonable, @"notificationToken", self.notificationToken);
    safeSet(jsonable, @"friendsList", self.friendsList);
    safeSet(jsonable, @"featureVideoIDs", self.featureVideoIDs);
    safeSet(jsonable, @"profileLineColor", self.profileLineColor); // RGB Number Array
    safeSet(jsonable, @"profileUNColor", self.profileUNColor);
    safeSet(jsonable, @"dailyVoteNumber", self.dailyVoteNumber);
    safeSet(jsonable, @"dailySubmissionNumber", self.dailySubmissionNumber);
    safeSet(jsonable, @"badgeNum", self.badgeNum);
    
    // These values are values that are able to be changed by someone other than the main user
    // Values are never updated from the app,
    // the server always updates these values based on entries and jams.
    // When an account is updated, the values from the database are read into the account object
    // before the rest of the object is updated.
    safeSet(jsonable, @"totalVideoVotes", self.totalVideoVotes);
    safeSet(jsonable, @"numberOfSessionsAttended", self.numberOfSessionsAttended);
    safeSet(jsonable, @"wins", self.wins);
    safeSet(jsonable, @"totalPoints", self.totalPoints);
    safeSet(jsonable, @"placesJammed", self.placesIveJammed);
    
    return jsonable;
}

// GET
/* JSON object from DB, turning into a session object */
- (void)initWithDictionary:(NSDictionary*)dictionary {
    /* 24 items HERE saved right now -- 10/25/2017 */
    self._accountid = dictionary[@"_id"];
    self.email = dictionary[@"email"];
    self.userName = dictionary[@"userName"];
    self.name = dictionary[@"name"];
    self.password = dictionary[@"password"];
    self.firstTimeDojo = dictionary[@"firstTimeDojo"];
    self.hometown = dictionary[@"hometown"];
   
    self.lastLogOn = dictionary[@"lastLogOn"];
    self.accountPictureID = dictionary[@"accountPictureID"];
    self.accountBio = dictionary[@"accountBio"];
    self.notificationToken = dictionary[@"notificationToken"];
    self.accountSessionID = [NSMutableArray arrayWithArray:dictionary[@"accountSessionID"]];
    
    self.friendsList = [NSMutableArray arrayWithArray:dictionary[@"friendsList"]];
    
    self.featureVideoIDs = [NSMutableArray arrayWithArray:dictionary[@"featureVideoIDs"]];
    
    self.profileLineColor = [NSMutableArray arrayWithArray:dictionary[@"profileLineColor"]];
    self.profileUNColor = [NSMutableArray arrayWithArray:dictionary[@"profileUNColor"]];
    
    self.dailyVoteNumber = dictionary[@"dailyVoteNumber"];
    self.dailySubmissionNumber = dictionary[@"dailySubmissionNumber"];
    
    self.badgeNum = dictionary[@"badgeNum"];
    
    // These values are values that are able to be changed by someone other than the main user
    // Values are never updated from the app,
    // the server always updates these values based on entries and jams.
    // When an account is updated, the values from the database are read into the account object
    // before the rest of the object is updated.
    self.totalVideoVotes = dictionary[@"totalVideoVotes"];
    self.numberOfSessionsAttended = dictionary[@"numberOfSessionsAttended"];
    self.wins = dictionary[@"wins"];
    self.totalPoints = dictionary[@"totalPoints"];
    self.placesIveJammed = [NSMutableArray arrayWithArray:dictionary[@"placesJammed"]]; // Array of places jammed (City Country Lat Long)
}

/** Encoding and Decoding objects for NSUserDefaults **/
- (void)encodeWithCoder:(NSCoder *)encoder {
    // 4, only used by AppDelegates default account -- 10/11/2017
    [encoder encodeObject:self._accountid forKey:@"_id"]; // This field is used for defaultAccount._accountid for APN in AppDelegate.m
    [encoder encodeObject:self.userName forKey:@"userName"];
    [encoder encodeObject:self.password forKey:@"password"];
    [encoder encodeObject:self.autoLogIn forKey:@"autoLogIn"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self._accountid = [decoder decodeObjectForKey:@"_id"];
        self.userName = [decoder decodeObjectForKey:@"userName"];
        self.password = [decoder decodeObjectForKey:@"password"];
        self.autoLogIn = [decoder decodeObjectForKey:@"autoLogIn"];
    }
    return self;
}

/** DB METHODS **/

/* Gets an account from DB, USING userName
  initialLoad determines if the dailyMessage should be gathered as well for login purposes */
+(void)loadAccount:(NSString *)kBaseURL userName:(NSString *)userName initialLoad:(NSString*)initialLoad  message:(NSString *)message callback:(void (^)(NSError *error, BOOL success, NSDictionary *responseAccount, NSInteger statusCode))callback {
    SPAM(("\nLoading Account\n"));
    
    /* Full path of collection and entity */
    NSString *collectionAndEntity;
    if ([initialLoad isEqualToString:@"yes"]) {
        collectionAndEntity = [NSString stringWithFormat:@"%@/%@/%@", kAccounts, userName, initialLoad];
    } else {
        collectionAndEntity = [NSString stringWithFormat:@"%@/%@", kAccounts, userName];
    }
    
    NSString *locations = [kBaseURL stringByAppendingPathComponent:collectionAndEntity];
    // Encoded for special charcaters in usernames
    NSString *encodedString = [locations stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSURL* url = [NSURL URLWithString:encodedString];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    // Set Up Auth
    [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:message];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSDictionary* responseAccount;
        if (data == nil) {
            responseAccount = nil;
        } else {
            responseAccount = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        }
        
        if (error == nil) {
            SPAM(("\nInside data task, loading Account\n"));
            callback(error, YES, responseAccount, [httpResponse statusCode]); // call to callback in viewDidLoad
        } else {
            NSLog(@"%@",[error localizedDescription]);
            callback(error, NO, nil, [httpResponse statusCode]);
        }
    }];
    
    [dataTask resume];
}

/* Response array is a list of accounts with a close username to the one searched by the user */
+(void)searchAccounts:(NSString*)searchUserName message:(NSString *)message callback:(void (^)(NSError *error, BOOL success, NSArray *responseArray, NSInteger statusCode))callback {
    SPAM(("\nSearch Accounts\n"));
    
    /* Full path of collection and entity */
    NSString *collectionAndEntity = [NSString stringWithFormat:@"searchAccounts/%@", searchUserName];
    NSString *locations = [kBaseURL stringByAppendingPathComponent:collectionAndEntity];
    NSString *encodedString = [locations stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSURL* url = [NSURL URLWithString:encodedString];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    // Set Up Auth
    [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:message];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // For status code
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        
        if (error == nil && data != nil) {
            SPAM(("\nAccounts recieved\n"));
            NSArray* responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            callback(error, YES, responseArray, [httpResponse statusCode]); // call to callback in viewDidLoad
        } else {
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
    
    [dataTask resume];
}


/* Add account to DB */
-(void)addAccount:(NSString*)kBaseURL message:(NSString *)message {
    SPAM(("\nAdding Account\n"));
    
    NSString* locations = [kBaseURL stringByAppendingPathComponent:kAccounts];
    NSURL* url = [NSURL URLWithString:locations];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:[self toDictionary] options:0 error:NULL];
    request.HTTPBody = data;
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // Set Up Auth
    [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:message];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* URLsession = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [URLsession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            SPAM(("No Error in Adding Account\n"));
        } else {
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
    [dataTask resume];
}

/* Update account Info, USING ACCOUNT _ID */
-(void)updateAccount:(NSString*)kBaseURL message:(NSString *)message {
    SPAM(("\nAccount ID IN UPDATE: %s\n", [self._accountid UTF8String]));
    
    NSString* locations = [kBaseURL stringByAppendingPathComponent:kAccounts];
    NSURL* url = [NSURL URLWithString:[locations stringByAppendingPathComponent:__accountid]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:[self toDictionary] options:0 error:NULL];
    request.HTTPBody = data;
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // Set Up Auth
    [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:message];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* URLsession = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [URLsession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            SPAM(("No Error in Updating Account\n"));
        } else {
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
    
    [dataTask resume];
}

+(NSMutableDictionary*)jammersCurrLocationJSON:(NSString*)currentLocation jammers:(NSMutableArray*)jammers {
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    /* items saved right now -- 12/7/2017 */
    jsonable[@"currentLocation"] = currentLocation;
    jsonable[@"jammers"] = jammers;
    return jsonable;
}

/* Increases Jammers numberOfJamsAttended and doles out a win after a Jam is successfully ended */
+(void)increaseJammersSessionsAttendedWins:(NSString*)kBaseURL message:(NSString *)message host:(NSString*)host winner:(NSString*)winner
                                   jammers:(NSMutableArray*)jammers currentLocation:(NSString*)currentLocation callback:(void (^)(NSError *error, BOOL success))callback {
    
    NSString* locations = [kBaseURL stringByAppendingPathComponent:kAccounts];
    NSString *winnerStr = [NSString stringWithFormat:@"%@/%@", winner, host];
    
    NSURL* url = [NSURL URLWithString:[locations stringByAppendingPathComponent:winnerStr]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:[self jammersCurrLocationJSON:currentLocation jammers:jammers] options:0 error:nil]; // session object has updated info
    request.HTTPBody = data;
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // Set Up Auth
    [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:message];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* URLsession = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [URLsession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            SPAM(("No Error in Updating Jammers\n"));
            callback(nil, YES);
        } else {
            NSLog(@"%@",[error localizedDescription]);
            callback(error, NO);
        }
    }];
    
    [dataTask resume];
}


@end
