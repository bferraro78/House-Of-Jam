//
//  Constants.m
//  Jam
//
//  Created by Ben Ferraro on 9/29/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
@implementation Constants

/* Set kBaseURL */

NSString* const kBaseURL = @"https://thehouseoj.com:4000"; // - DEV SERVER @"http://72.89.228.101:3000";

static NSString *key = @"JohnnyKnoxville"; // secret key only phone and server know about
static NSString *PWkey = @"MattHoffman"; // secret key for password

// Uploading video limit (profile video and video entry)
float const allowedVideoSize = 70.0;

/* View Tags */
NSInteger const createJamButtonTag = 1;
NSInteger const cancelJamButtonTag = 2;
NSInteger const refreshMapButtonTag = 6;

NSInteger const refreshMapProgressBarTag = 550;

NSInteger const createJamProgressBarTag = 551;
NSInteger const createJamLabelProgressBarTag = 552;

NSInteger const submitEntryProgressBarTag = 553;
NSInteger const submitEntryLabelProgressBarTag = 554;

NSInteger const editJamProgressBarTag = 555;
NSInteger const editJamLabelProgressBarTag = 556;

NSInteger const entryDescriptionViewTag = 50;
NSInteger const entryDescriptionTextViewTag = 51;

NSInteger const mapLegendViewTag = 60;

NSInteger const infoViewTag = 6969;
NSInteger const blackBackgroundTag = 6970;

NSInteger const bottomSignUpViewTag = 8069;
NSInteger const searchViewTag = 8070;
NSInteger const filterViewTag = 8080;
NSInteger const endJamViewTag = 8090;

/* 9000's mean tag is not used in ViewController.m */
NSInteger const datePickerViewTag = 9050;

NSInteger const dailyMessageViewTag = 1002;
NSInteger const navBarViewTag = 1003;

//alertViewTag ranges from 10,000-10,150

+(NSString*)getEncryptConstant:(NSString*)accountID {
    
    // pass in account ID (instead of phrase, pass in account'sID) for every database method (they are all written down on pad)
    // encryptKeyOnce on accountID using secret key,
    // SHA hash on it,  pass it through as a header
    // send the accountID inside the header of the request
    // encrypt then hash on the account id passed in thru the body of the message
    // if they are equal, all is good
    
    NSString *message = accountID; // message to go to header
    NSString *encryptedPhrase; // first encrypt
    NSString* signature; // then hash
    
    if ([encryptedPhrase length] == 0) {
        encryptedPhrase = [self encryptKeyOnce:message];
        signature = [self sha1:encryptedPhrase];
    }
    
    return signature;
}

+(NSString*)encryptKeyOnce:(NSString*)message {
    
    NSData *plain = [message dataUsingEncoding:NSUTF8StringEncoding];
    // Encyptes phrase with hash key "key"
    NSData *encryptedData = [plain AES256EncryptWithKey:key]; // function in EncyptExt.m
    
    NSString* cipher = [encryptedData base64EncodedStringWithOptions:0];
    
    return cipher;
}

+(NSString*)encryptPW:(NSString*)message {
    
    NSData *plain = [message dataUsingEncoding:NSUTF8StringEncoding];
    // Encyptes phrase with hash key "key"
    NSData *encryptedData = [plain AES256EncryptWithKey:PWkey]; // function in EncyptExt.m
    
    NSString* cipher = [encryptedData base64EncodedStringWithOptions:0];
    
    return cipher;
}

+(NSString*)decryptPW:(NSString*)message {
    
    NSData *plain = [NSData dataWithBase64EncodedString:message];
    
    // Encyptes phrase with hash key "key"
    NSData *plainData = [plain AES256DecryptWithKey:PWkey]; // function in EncyptExt.m
    
    NSString *plainString = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
    
    return plainString;
}


+(NSString *)sha1:(NSString*)encryptedPhrase {
    NSData *data = [encryptedPhrase dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+(NSString*)getUTCTime {
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    NSString* timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    return timeStamp;
}


@end
