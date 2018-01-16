//
//  ImageVideoUploader.h
//  Jam
//
//  Created by Ben Ferraro on 9/22/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef ImageVideoUploader_h
#define ImageVideoUploader_h
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "DataBaseCalls.h"

@interface ImageVideoUploader : NSObject

+(void)getImageIDDB:(NSString*)kBaseURL collection:(NSString*)collection objData:(NSData*)objData VideoOrImg:(NSString*)VideoOrImg message:(NSString*)message callback:(void (^)(NSError *error, BOOL success, NSDictionary *responseDic))callback;

@end


#endif /* ImageVideoUploader_h */
