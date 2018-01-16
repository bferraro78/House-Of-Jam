//
//  Session.h
//  RailJam
//
//  Created by Ben Ferraro on 6/30/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef Session_h
#define Session_h
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Constants.h"
#import "DataBaseCalls.h"

// Holds all data for a Jam
// These objects are stored in the database, when loading the main view
// with markers, static data about that Session may be loaded into userData
@interface Session : NSObject

/* Is marker representing the jam added to map view? */
@property BOOL isAddedToMap;

/* Text Fields*/
@property (strong, nonatomic) NSString *_id;
@property (strong, nonatomic) NSString *jamName;
@property (strong, nonatomic) NSString *sessionHostName;
@property (strong, nonatomic) NSString *entryFee;
@property (strong, nonatomic) NSString *startTime;
@property (strong, nonatomic) NSString *seshDescription;
@property (strong, nonatomic) NSString *LeisureorComp; // recreational or competitive jam
@property (strong, nonatomic) NSString *jamDate;
@property (strong, nonatomic) NSString *privateJam;

/* Lat/Long*/
@property NSString *sessionLat;
@property NSString *sessionLong;

/* Location */
@property NSString *jamLocation; // "town,country,lat,long"

/* Jam type */
@property (strong, nonatomic) NSString *jamType;

/* Rail and Prize Images/ID's */
@property (strong, nonatomic) NSMutableArray *sessionPictures;
@property (strong, nonatomic) NSMutableArray *sessionPictureIDs;

/* Invited friends to this session */
@property (strong, nonatomic) NSMutableArray *invitedFriends;

/* List of Participants */
// can be affected by multiple people at the same time
@property NSMutableArray *jammers;


// METHODS
-(id) init;
-(id) initWithDictionary:(NSDictionary*)dictionary;
-(NSMutableDictionary*)toDictionary;

+(void)loadSession:(NSString *)kBaseURL seshID:(NSString *)seshID message:(NSString*)message callback:(void (^)(NSError *error, BOOL success, NSDictionary *responseSession))callback;
+(void)updateJammer:(NSString *)kBaseURL seshID:(NSString*)seshID userName:(NSString*)userName actionMode:(NSString*)actionMode message:(NSString*)message callback:(void (^)(NSError *error, BOOL success))callback;
+(void)editJam:(NSString*)kBaseURL session:(Session*)session message:(NSString*)message callback:(void (^)(NSError *error, BOOL success))callback;

@end

#endif /* Session_h */
