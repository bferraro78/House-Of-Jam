//
//  VideoEntry.h
//  Jam
//
//  Created by Ben Ferraro on 9/6/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef VideoEntry_h
#define VideoEntry_h
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "DataBaseCalls.h"

@interface VideoEntry : NSObject

@property (strong, nonatomic) NSString *_id; // entryID
@property (strong, nonatomic) NSString *accountID; // Poster's accountID
@property (strong, nonatomic) NSString *videoID; // video's ID in database
@property (strong, nonatomic) NSString *username; // Poster's Username
@property (strong, nonatomic) NSString *hometown; // Poster's hometown
@property (strong, nonatomic) NSString *entryDescription;
@property (strong, nonatomic) NSString *contentType; // image/video

// can be affected by multiple people at the same time
@property NSNumber *votes;

// Methods
-(id)initaccountID:(NSString *)aAccountID videoID:(NSString *)aVideoID username:(NSString*)aUsername hometown:(NSString*)aHomeTown entryDescription:(NSString*)aEntryDescription aContentType:(NSString*)aContentType;
-(id)initWithDictionary:(NSDictionary*)dictionary;
-(void)addEntry:(NSString*)kBaseURL message:(NSString*)message userName:(NSString*)userName callback:(void (^)(NSError *error, BOOL success))callback;
-(void)updateEntry:(NSString*)kBaseURL mainUser:(NSString*)mainUser entryPoster:(NSString*)entryPoster message:(NSString*)messae;
+(void)loadEntries:(NSString *)kBaseURL message:(NSString*)message callback:(void (^)(NSError *error, BOOL success, NSArray *responseEntryList))callback;
-(NSMutableDictionary*)toDictionary;

@end

#endif /* VideoEntry_h */
