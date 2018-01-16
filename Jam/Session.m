//
//  Session.m
//  RailJam
//
//  Created by Ben Ferraro on 6/30/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"

@implementation Session

static NSString* const kMarkers = @"markers";

-(id)init {
    return self;
}

/* JSON object from DB, turning into a session object */
- (id)initWithDictionary:(NSDictionary*)dictionary {

    self._id = dictionary[@"_id"];
    self.jamName = dictionary[@"jamName"];
    self.sessionHostName = dictionary[@"sessionHostName"]; // Account name
    self.entryFee = dictionary[@"entryFee"];
    self.startTime = dictionary[@"startTime"];
    self.jamType = dictionary[@"jamType"];
    self.seshDescription = dictionary[@"sessionDescription"];
    self.sessionLat = dictionary[@"sessionLat"];
    self.sessionLong = dictionary[@"sessionLong"];
    self.jamLocation = dictionary[@"jamLocation"];
    self.LeisureorComp = dictionary[@"LorC"];
    self.privateJam = dictionary[@"privateJam"];
    self.jamDate = dictionary[@"jamDate"];
    self.sessionPictureIDs = [NSMutableArray arrayWithArray:dictionary[@"sessionPictureIDs"]];
    self.jammers = [NSMutableArray arrayWithArray:dictionary[@"jammers"]];
    self.invitedFriends = [NSMutableArray arrayWithArray:dictionary[@"invitedFriends"]];
    return self;
}

/* Used to Create a JSON object to be put into DB */
#define safeSet(d,k,v) if (v) d[k] = v;
-(NSMutableDictionary*)toDictionary {
    
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    /* 15 items saved right now -- 12/4/2017 */
    safeSet(jsonable, @"_id", self._id);
    safeSet(jsonable, @"jamName", self.jamName);
    safeSet(jsonable, @"sessionHostName", self.sessionHostName);
    safeSet(jsonable, @"entryFee", self.entryFee);
    safeSet(jsonable, @"startTime", self.startTime);
    safeSet(jsonable, @"jamType", self.jamType);
    safeSet(jsonable, @"sessionDescription", self.seshDescription);
    safeSet(jsonable, @"sessionPictureIDs", self.sessionPictureIDs);
    safeSet(jsonable, @"sessionLat", self.sessionLat);
    safeSet(jsonable, @"sessionLong", self.sessionLong);
    safeSet(jsonable, @"jamLocation", self.jamLocation);
    safeSet(jsonable, @"LorC", self.LeisureorComp);
    safeSet(jsonable, @"privateJam", self.privateJam);
    safeSet(jsonable, @"jamDate", self.jamDate);
    safeSet(jsonable, @"jammers", self.jammers); // Array of Accounts usernames
    safeSet(jsonable, @"invitedFriends", self.invitedFriends); // Array of friend usernames
    
    return jsonable;
}

/** DB METHODS */
/* Gets an Session from DB, USING userName */
+(void)loadSession:(NSString *)kBaseURL seshID:(NSString *)seshID message:(NSString*)message callback:(void (^)(NSError *error, BOOL success, NSDictionary *responseSession))callback {
    SPAM(("\nLoading Session\n"));
    
    /* Full path of collection and entity */
    NSString *collectionAndEntity = [NSString stringWithFormat:@"%@/%@", kMarkers, seshID];
    
    NSString *locations = [kBaseURL stringByAppendingPathComponent:collectionAndEntity];
    
    NSString * encodedString = [locations stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSURL* url = [NSURL URLWithString:encodedString];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    // Set Up Auth
    [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:message];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil && data != nil) {
            SPAM(("\nInside data task, loading Session\n"));
            NSDictionary* responseSession = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            callback(error, YES, responseSession); // call to callback in viewDidLoad
        } else {
            NSLog(@"Load Session error: %@",[error localizedDescription]);
        }
    }];
    
    [dataTask resume];
}

/* Adds or removes jammer from Session DB object */
+(void)updateJammer:(NSString *)kBaseURL seshID:(NSString*)seshID userName:(NSString*)userName actionMode:(NSString*)actionMode message:(NSString*)message callback:(void (^)(NSError *error, BOOL success))callback {
    
    NSString* locations = [kBaseURL stringByAppendingPathComponent:kMarkers];
    
    NSString *collectionAndEntity = [NSString stringWithFormat:@"%@/%@/%@/%@", locations, seshID, userName, actionMode];
    NSURL *url = [NSURL URLWithString:collectionAndEntity];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // Set Up Auth
    [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:message];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* URLsession = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [URLsession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            SPAM(("\nAdded or Removed Jammer\n"));
            callback(error, YES);
        } else {
            NSLog(@"Error while loading participant into session...%@\n",[error localizedDescription]);
            callback(error, NO);
        }
    }];
    [dataTask resume];
}

+(void)editJam:(NSString*)kBaseURL session:(Session*)session message:(NSString*)message callback:(void (^)(NSError *error, BOOL success))callback {
    NSString* locations = [kBaseURL stringByAppendingPathComponent:kMarkers];
    
    NSString *collectionAndEntity = [NSString stringWithFormat:@"%@/%@", locations, session._id];
    NSURL *url = [NSURL URLWithString:collectionAndEntity];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:[session toDictionary] options:0 error:nil]; // session object has updated info
    request.HTTPBody = data;
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // Set Up Auth
    [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:message];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* URLsession = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [URLsession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            SPAM(("\nSuccessfully Updated jam\n"));
            callback(error, YES);
        } else {
            NSLog(@"Error while loading participant into session...%@\n",[error localizedDescription]);
            callback(error, NO);
        }
    }];
    [dataTask resume];
}

@end
