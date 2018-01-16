//
//  DataBaseCalls.h
//  House Of Jam
//
//  Created by james schuler on 12/10/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef DataBaseCalls_h
#define DataBaseCalls_h
#import <UIKit/UIKit.h>
#import "Constants.h"

@interface DataBaseCalls : NSObject

// Delete From DB
+(void)deleteFromCollection:(NSString *)collection entity:(NSString *)entity message:(NSString *)message;
+(void)setUpAuthorizationHTTPHeaders:(NSMutableURLRequest*)request  message:(NSString *)message;

@end

#endif /* DataBaseCalls_h */
