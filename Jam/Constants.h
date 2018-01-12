//
//  Constants.h
//  Jam
//
//  Created by Ben Ferraro on 9/29/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef Constants_h
#define Constants_h
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "EncryptExt.h"


/* Set Up Debugging statements */
#define DEBUG_PRINT 0 // set to 0 if you want print statements, 1 otherwise

#if DEBUG_PRINT == 0
#define SPAM(a) printf a
#else
#define SPAM(a) (void)0
#endif

@interface Constants : NSObject


// extern is used so all other classes may see these variables, const won't let it change
// can only declare static in the .m files

extern float const allowedVideoSize;

extern NSString* const kBaseURL;

extern NSInteger const createJamButtonTag;
extern NSInteger const cancelJamButtonTag;
extern NSInteger const refreshMapButtonTag;

extern NSInteger const refreshMapProgressBarTag;
extern NSInteger const createJamProgressBarTag;
extern NSInteger const createJamLabelProgressBarTag;

extern NSInteger const submitEntryProgressBarTag;
extern NSInteger const submitEntryLabelProgressBarTag;

extern NSInteger const entryDescriptionViewTag;
extern NSInteger const entryDescriptionTextViewTag;

extern NSInteger const editJamProgressBarTag;
extern NSInteger const editJamLabelProgressBarTag;

extern NSInteger const mapLegendViewTag;

extern NSInteger const infoViewTag;
extern NSInteger const blackBackgroundTag;

extern NSInteger const bottomSignUpViewTag;

extern NSInteger const searchViewTag;
extern NSInteger const filterViewTag;
extern NSInteger const endJamViewTag;

extern NSInteger const datePickerViewTag;

extern NSInteger const dailyMessageViewTag;
extern NSInteger const navBarViewTag;

// Methods
+(NSString*)getEncryptConstant:(NSString*)accountID;
+(NSString*)encryptKeyOnce:(NSString*)messge;
+(NSString*)encryptPW:(NSString*)message;
+(NSString*)decryptPW:(NSString*)message;
+(NSString*)sha1:(NSString*)encryptedPhrase;
+(NSString*)getUTCTime;

@end

#endif /* Constants_h */
