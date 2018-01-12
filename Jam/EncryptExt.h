//
//  EncryptExt.h
//  Jam
//
//  Created by Ben Ferraro on 9/28/17.
//  Copyright © 2017 Ben Ferraro. All rights reserved.
//

#ifndef EncryptExt_h
#define EncryptExt_h
#import <CommonCrypto/CommonCryptor.h>

@interface NSData (EncryptExt)

-(NSData*)AES256EncryptWithKey:(NSString *)key;
-(NSData *)AES256DecryptWithKey:(NSString *)key;
+(NSData *)dataWithBase64EncodedString:(NSString *)string;
-(id)initWithBase64EncodedString:(NSString *)string;

@end

#endif /* EncryptExt_h */
