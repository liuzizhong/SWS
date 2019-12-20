//
//  NSData+Additions.h
//  UDown
//
//  Created by 杨 德升 on 12-3-5.
//  Copyright (c) 2012年 YLMF Co.,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (UDAdditions)

- (NSString *)md115Hash;

/**
 * Calculate the md5 hash of this data using CC_MD5.
 *
 * @return md5 hash of this data
 */
@property (nonatomic, readonly) NSString* md5Hash;

/**
 * Calculate the SHA1 hash of this data using CC_SHA1.
 *
 * @return SHA1 hash of this data
 */
@property (nonatomic, readonly) NSString* sha1Hash;

/**
 * Create an NSData from a base64 encoded representation
 * Padding '=' characters are optional. Whitespace is ignored.
 * @return the NSData object
 */
+ (id)dataWithBase64EncodedString:(NSString *)string;

/**
 * Marshal the data into a base64 encoded representation
 *
 * @return the base64 encoded string
 */
- (NSString *)base64Encoding;

//如果是图片数据，根据Data分析图片是什么类型的
- (NSString *)imageType;

@end

NS_ASSUME_NONNULL_END
