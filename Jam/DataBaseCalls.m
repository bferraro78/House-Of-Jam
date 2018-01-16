//
//  DataBaseCalls.m
//  House Of Jam
//
//  Created by james schuler on 12/10/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBaseCalls.h"

@implementation DataBaseCalls 

+(void)setUpAuthorizationHTTPHeaders:(NSMutableURLRequest*)request  message:(NSString *)message {
    // SEND A TIME STAMP!
    NSString* timeStamp = [Constants getUTCTime];
    [request addValue:[Constants getEncryptConstant:message] forHTTPHeaderField:@"Proxy-Authorization"];
    [request addValue:message forHTTPHeaderField:@"x-req"];
    [request addValue:[Constants encryptKeyOnce:timeStamp] forHTTPHeaderField:@"Authorization"];
}

/* Delete entity from collection */
+(void)deleteFromCollection:(NSString *)collection entity:(NSString *)entity message:(NSString *)message {
    SPAM(("\nDeleting from collection\n"));
    
    /* Full path of collection and entity */
    NSString *collectionAndEntity = [NSString stringWithFormat:@"%@/%@", collection, entity];
    
    NSURL* url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:collectionAndEntity]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"DELETE";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    // Set Up Auth
    [DataBaseCalls setUpAuthorizationHTTPHeaders:request message:message];

    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            SPAM(("\nDeleting %s from %s Successful\n", [entity UTF8String], [collection UTF8String]));
        } else {
            NSLog(@"Error Deleting %s from %s -- %@\n", [entity UTF8String], [collection UTF8String], [error localizedDescription]);
        }
    }];
    
    [dataTask resume];
}

@end
