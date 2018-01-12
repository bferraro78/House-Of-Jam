//
//  ImageVideoUploader.m
//  Jam
//
//  Created by Ben Ferraro on 9/22/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageVideoUploader.h"

@implementation ImageVideoUploader

/* Simply gets a Video and Picture an ID from the database */
+(void)getImageIDDB:(NSString*)kBaseURL collection:(NSString*)collection objData:(NSData*)objData VideoOrImg:(NSString*)VideoOrImg message:(NSString*)message callback:(void (^)(NSError *error, BOOL success, NSDictionary *responseDic))callback {

    NSURL* url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:collection]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    // Set Up Auth
    [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:message];
    
    if ([@"image" isEqualToString:VideoOrImg]) {
        [request addValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    } else { // video
        [request addValue:@"video/mp4" forHTTPHeaderField:@"Content-Type"];
    }
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* URLsession = [NSURLSession sessionWithConfiguration:config];

    NSURLSessionUploadTask* task = [URLsession uploadTaskWithRequest:request fromData:objData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error == nil && [(NSHTTPURLResponse*)response statusCode] < 300 && data != nil) {
            SPAM(("Getting ID\n"));
            
            NSDictionary* responseDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            callback(error, YES, responseDic);
            
        } else {
            callback(error, NO, nil);
        }
    }];
    [task resume];
}
@end
