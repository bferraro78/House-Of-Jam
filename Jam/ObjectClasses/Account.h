//
//  Account.h
//  RailJam
//
//  Created by Ben Ferraro on 6/24/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef Account_h
#define Account_h
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "DataBaseCalls.h"

@interface Account : NSObject

@property (strong, nonatomic) NSString *_accountid; // DB ID
@property NSString *email;
@property NSString *userName;
@property NSString *name;
@property NSString *password;
@property NSString *hometown;
@property NSString *lastLogOn;
@property NSNumber *badgeNum;

// 12/13/17 -- changed to an array!! (3 jams hostable at any moment)
@property NSMutableArray *accountSessionID; // Current User's hosted sessionID, local to him/her

@property NSString *accountPictureID;
@property UIImage *accountPicture;
@property NSString *accountBio;

// Entry Submission data
@property NSNumber *dailyVoteNumber; // what video group is the user on
@property NSNumber *dailySubmissionNumber; // only 3 submissions a day

/* Feature Videos/ ID's  */
@property (strong, nonatomic) NSMutableDictionary *featureVideos; // hold local file URLs in IOS's temp dir
@property (strong, nonatomic) NSMutableArray *featureVideoIDs;
@property (strong, nonatomic) NSMutableDictionary *featureVideoThumbnails; // hold actually UIImages of thumbnails

/* Array of usernames that allow easy access to invite to sessions */
@property NSMutableArray *friendsList;

/* RGB Number Color Arrays */
@property NSMutableArray *profileLineColor;
@property NSMutableArray *profileUNColor;

@property NSString *notificationToken;

// @"Yes" == enabled
@property NSString *autoLogIn;

// First time enetering Dojo, run tutorial
@property NSString *firstTimeDojo;

/* These are not updated from the app, this is taken care of on the server side.
   This is due to the fact that this number is updated from another
   logged in person when they are voting on your video. */
@property NSNumber *totalVideoVotes;
@property NSNumber *wins;
@property NSNumber *numberOfSessionsAttended;
@property NSNumber *totalPoints;
@property NSMutableArray *placesIveJammed; /* Array of strings of @"City Country Lat Long" */


// METHODS
-(id)inituserName:(NSString *)aUserName name:(NSString*)aName email:(NSString *)aEmail password:(NSString *)aPassword hometown:(NSString*)aHometown lastLogOn:(NSString *)aLastLogOn;
- (void)initWithDictionary:(NSDictionary*)dictionary;
-(NSMutableDictionary*)toDictionary;
+(NSMutableDictionary*)jammersCurrLocationJSON:(NSString*)currentLocation jammers:(NSMutableArray*)jammers;
-(void)toString;

+(void)loadAccount:(NSString *)kBaseURL userName:(NSString *)userName initialLoad:(NSString*)initialLoad message:(NSString *)message callback:(void (^)(NSError *error, BOOL success, NSDictionary *responseAccount, NSInteger statusCode))callback;
+(void)searchAccounts:(NSString*)searchUserName message:(NSString *)message callback:(void (^)(NSError *error, BOOL success, NSArray *responseArray, NSInteger statusCode))callback;
-(void)addAccount:(NSString*)kBaseURL message:(NSString *)message;
-(void)updateAccount:(NSString*)kBaseURL message:(NSString *)message;
+(void)increaseJammersSessionsAttendedWins:(NSString*)kBaseURL message:(NSString *)message host:(NSString*)host winner:(NSString*)winner jammers:(NSMutableArray*)jammers currentLocation:(NSString*)currentLocation callback:(void (^)(NSError *error, BOOL success))callback;


@end

#endif /* Account_h */
