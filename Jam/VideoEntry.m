//
//  VideoEntry.m
//  Jam
//
//  Created by Ben Ferraro on 9/6/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoEntry.h"

@implementation VideoEntry

static NSString* const kOnlineEntries = @"onlineEntries";

-(id)initaccountID:(NSString *)aAccountID videoID:(NSString *)aVideoID username:(NSString*)aUsername hometown:(NSString*)aHomeTown entryDescription:(NSString*)aEntryDescription aContentType:(NSString*)aContentType {
    _accountID = aAccountID;
    _videoID = aVideoID;
    _username = aUsername;
    _hometown = aHomeTown;
    _entryDescription = aEntryDescription;
    _contentType = aContentType;
    _votes = [NSNumber numberWithInteger:0];
 
    return self;
}


/* Used to Create a JSON object to be put into DB */
#define safeSet(d,k,v) if (v) d[k] = v;
-(NSMutableDictionary*)toDictionary {
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    /* 5 items saved right now -- 9/6/2017 */
    safeSet(jsonable, @"_id", self._id);
    safeSet(jsonable, @"accountID", self.accountID);
    safeSet(jsonable, @"videoID", self.videoID);
    safeSet(jsonable, @"votes", self.votes);
    safeSet(jsonable, @"username", self.username);
    safeSet(jsonable, @"hometown", self.hometown);
    safeSet(jsonable, @"entryDescription", self.entryDescription);
    safeSet(jsonable, @"Content-Type", self.contentType);
    

    return jsonable;
}

/* JSON object from DB, turning into a session object */
-(id)initWithDictionary:(NSDictionary*)dictionary {
    self._id = dictionary[@"_id"];
    self.accountID = dictionary[@"accountID"];
    self.videoID = dictionary[@"videoID"];
    self.votes = dictionary[@"votes"];
    self.username = dictionary[@"username"];
    self.hometown = dictionary[@"hometown"];
    self.entryDescription = dictionary[@"entryDescription"];
    self.contentType = dictionary[@"Content-Type"];
    return self;
}

/** DB Methods **/
/* Add Online Entry to DB */
-(void)addEntry:(NSString*)kBaseURL message:(NSString*)message userName:(NSString*)userName callback:(void (^)(NSError *error, BOOL success))callback {
    SPAM(("\nAdding Entry\n"));
    
    NSString* locations = [kBaseURL stringByAppendingPathComponent:kOnlineEntries];
    NSString *collectionAndEntity = [NSString stringWithFormat:@"%@/%@", locations, userName];
    NSURL *url = [NSURL URLWithString:collectionAndEntity];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:[self toDictionary] options:0 error:nil]; // session object has updated info
    request.HTTPBody = data;
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // Set Up Auth
    [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:message];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* URLsession = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [URLsession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            SPAM(("No Error in Adding Entry\n"));
            callback(error, YES); // too saveEntryVideo: in ViewController
        } else {
            NSLog(@"%@",[error localizedDescription]);
            callback(error, NO); // too saveEntryVideo: in ViewController
        }
    }];
    [dataTask resume];
}

/* Update Entry Info, USING _id */
-(void)updateEntry:(NSString*)kBaseURL mainUser:(NSString*)mainUser entryPoster:(NSString*)entryPoster message:(NSString*)message {
    SPAM(("\nEntry ID IN UPDATE: %s\n", [self._id UTF8String]));
    
    NSString *locations = [kBaseURL stringByAppendingPathComponent:kOnlineEntries];
    NSString *collectionAndEntity = [NSString stringWithFormat:@"%@/%@/%@/%@", locations, self._id, mainUser, entryPoster];
    NSURL *url = [NSURL URLWithString:collectionAndEntity];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:[self toDictionary] options:0 error:nil]; // session object has updated info
    request.HTTPBody = data;
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // Set Up Auth
    [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:message];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* URLsession = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [URLsession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            SPAM(("No Error in Updating Entry\n"));
        } else {
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
    
    [dataTask resume];
}

/* Gets an entry from DB, USING _id */
+(void)loadEntries:(NSString *)kBaseURL message:(NSString*)message callback:(void (^)(NSError *error, BOOL success, NSArray *responseEntryList))callback {
    SPAM(("\nLoading Entries\n"));
    
    NSURL* url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kOnlineEntries]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    // Set Up Auth
    [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:message];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil && data != nil) {
            SPAM(("\nInside data task, importing online entries\n"));
            NSArray* responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]; 
            callback(error, YES, responseArray); // call to callback in VoteController
        } else {
            SPAM(("\nError here Load Entries\n"));
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
    
    [dataTask resume]; //8
}

@end
