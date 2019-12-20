//
//  NSString+Additions.h
//  UDown
//
//  Created by BOYD on 12-3-5.
//  Copyright (c) 2012年 YLMF Co.,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Json.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSString (UDAdditions)
/**
 * Calculate the md5 hash of this string using CC_MD5.
 *
 * @return md5 hash of this string
 */
@property (nonatomic, readonly) NSString* md5Hash;

/**
 * Calculate the SHA1 hash of this string using CommonCrypto CC_SHA1.
 *
 * @return NSString with SHA1 hash of this string
 */
@property (nonatomic, readonly) NSString* sha1Hash;
@property (nonatomic, readonly) BOOL isEmail;
@property (nonatomic, readonly) BOOL isPassword;
@property (nonatomic, readonly) BOOL isMobileNO;
@property (nonatomic, readonly) BOOL isLetters;

@property (nonatomic, readonly) NSString *pathStringExtension;

- (BOOL)isEmpty;
- (BOOL)isValidateMobile;
- (BOOL)stringContainsEmoji;
- (BOOL)isNineKeyBoard;
- (BOOL)hasEmoji;
- (BOOL)containsString:(NSString*)aString;
- (NSString *)stringByDetecteURL;

+ (BOOL) isAllSpacing:(NSString *) str;//判断全是空格
+ (NSString *)base36FromDouble: (double)value;
+ (NSString *)doubleFromBase36: (NSString *)value;
+ (NSString *)randomPassword;
+ (NSString *)fileSHA1:(NSString*)path;
+ (NSString *)fileSHA1To128K:(NSString*)path;
- (NSString *)unescapeUnicodeString;
- (NSString *)reformatTelephone;
- (NSString *)html5CodeToString;
- (NSString *)formatPhoneString;
- (NSString *)stringByDetecteLink;
- (NSString *)stringByDetecteHTMLLink;
- (NSString *)stringBytimeStringSecond;
- (NSString *)getMMSSFromSS;
- (NSComparisonResult)versionStringCompare:(NSString *)other;
/**
 * Returns a URL Encoded String
 */
- (NSString*)urlEncoded;
//上传模块
+(NSString*)fileBlockSHA1:(NSString*)path withOffset:(long long)fileOffset withLength:(long long)totalLength;
/**
 *  计算字符串显示大小，结果取整以方便设计 UIView 的 frame
 *  @param font  字体，不能为空
 *  @param width 最大显示宽度，为 0 时不限制宽度
 *  @return 返回的大小会取整，如实际高度是 115.15 时，会返回 116.0
 */
- (CGSize)sizeWithFont:(UIFont *)font forWidth:(CGFloat)width;
/**
 *  搜索关键字高亮
 *  @param keyword  关键字
 *  @param color    高亮颜色
 *  @return NSMutableAttributedString
 */
- (NSMutableAttributedString *)mutableAttributedString:(NSString *)keyword;
- (NSMutableAttributedString *)mutableAttributedString:(NSString *)keyword andColor:(UIColor *)color;

/**
 搜索关键字高亮
 
 @param keyword 关键字
 @param isSeparator 高亮颜色
 @return 是否分割  如果分割则以空格分割来挨个匹配
 */
- (NSMutableAttributedString *)mutableAttributedString:(NSString *)keyword bySeparator:(BOOL)isSeparator;
/**
 高亮字符串
 
 @param keyword 关键字
 @param color 高亮颜色
 @param isSeparator 是否分割
 @return 返回高亮字符
 */
- (NSMutableAttributedString *)mutableAttributedString:(NSString *)keyword andColor:(UIColor *)color andSeparator:(BOOL)isSeparator;

- (NSMutableAttributedString *)mutableAttributedStringWithRange:(NSRange)range andColor:(UIColor *)color;

- (BOOL)includeChinese;//判断是否含有汉字

-(BOOL)isAllNumber;

-(BOOL)settingPassword;

- (BOOL)settingGroupFilePassword;

- (BOOL)isChinese;//判断是否是纯汉字

//判断手机号码格式是否正确
+ (BOOL)valiMobile:(NSString *)mobile;

+ (BOOL)isNumberCode:(NSString *)str;

@end

@interface NSURL (UDAdditions)

- (NSDictionary *)queryPairs;

@end

NS_ASSUME_NONNULL_END
