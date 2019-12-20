//
//  NSString+Additions.m
//  UDown
//
//  Created by 杨 德升 on 12-3-5.
//  Copyright (c) 2012年 YLMF Co.,Inc. All rights reserved.
//

#import "NSString+Additions.h"
#import "NSData+Additions.h"
#import <CommonCrypto/CommonDigest.h>
#import "SWS-Swift.h"

#define kIsNumberRegute @"\\D"
#define kSearchKeyWordColor                 [UIColor colorWithRed:69.0/255.0    green:153.0/255.0  blue:224.0/255.0  alpha:1.0]  // 搜索关键字颜色 - 蓝色

@implementation NSString (UDAdditions)

- (NSString *)pathStringExtension {
    if ([self pathExtension] != nil && [self pathExtension].length > 0) {
        return [self pathExtension];
    } else if ([[self componentsSeparatedByString:@"."] lastObject] != nil) {
        return [[self componentsSeparatedByString:@"."] lastObject];
    } else {
        
        return nil;
    }
}

- (NSString*)md5Hash {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5Hash];
}

- (NSString*)sha1Hash {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha1Hash];
}

- (BOOL)isEmail {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (BOOL)isPassword {
    //8-20位数字和字母组合
    NSString *regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[\\S]{8,20}$";
    NSPredicate *prd = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [prd evaluateWithObject:self];
}

- (BOOL)isMobileNO {
    NSString *regex = @"[0-9]{11}";
    NSPredicate *prd = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [prd evaluateWithObject:self];
}

- (BOOL)isLetters {
    NSString *regex = @"^[A-Za-z]{0,50}$";
    NSPredicate *prd = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [prd evaluateWithObject:self];
}

- (BOOL)isEmpty {
    if (self && self.length > 0) {
        return NO;
    }
    return YES;
}

+ (BOOL) isAllSpacing:(NSString *) str {
    if (!str) {
        return true;
    } else {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}

-(BOOL)isValidateMobile {
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(17[0-9])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //    NSLog(@"phoneTest is %@",phoneTest);
    return [phoneTest evaluateWithObject:self];
}

-(BOOL)stringContainsEmoji {
    __block BOOL returnValue = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    return returnValue;
}

/**
 *  判断字符串中是否存在emoji
 * @return YES(含有表情)
 */
- (BOOL)hasEmoji;
{
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
//    NSString *pattern = @"[\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}

/**
 判断是不是九宫格
 @return YES(是九宫格拼音键盘)
 */
-(BOOL)isNineKeyBoard
{
    NSString *other = @"➋➌➍➎➏➐➑➒";
    int len = (int)self.length;
    for(int i=0;i<len;i++)
    {
        if(!([other rangeOfString:self].location != NSNotFound))
            return NO;
    }
    return YES;
}

- (BOOL)containsString:(NSString *)aString {
    NSRange range = [[self lowercaseString] rangeOfString:[aString lowercaseString]];
    return range.location != NSNotFound;
}

- (NSString *)stringByDetecteURL {
    NSMutableString *mStr = [[self trim] mutableCopy];
    NSRegularExpression *regexhttp = [NSRegularExpression cachedPattern:NSRegularExpression.RegularLink options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *matchs = [regexhttp matchesInString:mStr options:0 range:NSMakeRange(0, [mStr length])];
    NSRegularExpression *regexEmail = [NSRegularExpression cachedPattern:NSRegularExpression.RegularEmail options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *emailMatchs = [regexEmail matchesInString:mStr options:0 range:NSMakeRange(0, [mStr length])];
    for (NSInteger i = matchs.count - 1; i >= 0; i--) {
        NSRange urlRange = [matchs[i] rangeAtIndex:0];
        BOOL needBreak = NO;
        for (NSInteger i = emailMatchs.count - 1; i >= 0; i--) {
            NSRange emailRange = [emailMatchs[i] rangeAtIndex:0];
            if (emailRange.location <= urlRange.location && (emailRange.location + emailRange.length) >= (urlRange.location + urlRange.length)) {
                needBreak = YES;
                break;
            }
        }
        if (needBreak) {
            break;
        }
        NSTextCheckingResult *result = matchs[i];
        NSString *str = [mStr substringWithRange:[result rangeAtIndex:0]];
        if ([regexEmail matchesInString:str options:0 range:NSMakeRange(0, [str length])].count == 0) {
            [mStr replaceCharactersInRange:[result rangeAtIndex:0] withString:[NSString stringWithFormat:@"[url=%@]%@[/url]", str, str]];
        }
    }
    return mStr;
}

+ (NSString *)base36FromDouble:(double)value {
    NSString *base36 = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSString *returnValue = @"";
    NSString *g = @"0";
    int i = 0;
    do {
        int x ;
        if (i == 0) {
            x = fmod(value, [base36 length] );
        } else {
            x = fmod([g doubleValue], [base36 length]);
        }
        NSString *y = [NSString stringWithFormat:@"%c", [base36 characterAtIndex:x]];
        returnValue = [y stringByAppendingString:returnValue];
        value = floor(value / 36);
        i++;
        g = [[NSString alloc] initWithFormat:@"%0.0f", value];
    } while ([g intValue] != 0);
    return [returnValue lowercaseString];
}

+ (NSString *)doubleFromBase36: (NSString *)value {
    NSString *uniValue = [value uppercaseString];
    NSString *base36 = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    double retDouble = 0;
    for (int i=0; i<uniValue.length; i++) {
        NSRange curCharRange = NSMakeRange(uniValue.length-i-1, 1);
        NSString *charStr = [uniValue substringWithRange:curCharRange];
        NSInteger charInd = [base36 rangeOfString:charStr].location;
        retDouble+=charInd*pow(base36.length,i);
    }
    NSString *doubleStr = [NSString stringWithFormat:@"%.0f",retDouble];
    return doubleStr;
}

+ (NSString *)randomPassword {
    return [NSString stringWithFormat:@"%@", [[[NSString stringWithFormat:@"%d", rand()%10000000] md5Hash] substringToIndex:19]];
}

+ (NSString*)fileSHA1:(NSString*)path {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if( handle== nil ) return @"ERROR GETTING FILE MD5"; // file didnt exist
    CC_SHA1_CTX sha1;
    CC_SHA1_Init(&sha1);
    BOOL done = NO;
    while(!done) {
        @autoreleasepool {
            NSData* fileData = [handle readDataOfLength: 4096 ];//CHUNK_SIZE
            CC_SHA1_Update(&sha1, [fileData bytes], (uint32_t)[fileData length]);
            if( [fileData length] == 0 ) done = YES;
        }
    }
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1_Final(digest, &sha1);
    NSString* s = [NSString stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1], digest[2], digest[3], digest[4], digest[5], digest[6], digest[7],
                   digest[8], digest[9], digest[10], digest[11], digest[12], digest[13], digest[14], digest[15],
                   digest[16], digest[17], digest[18], digest[19]
                   ];
    return s;
}


+ (NSString*)fileSHA1To128K:(NSString*)path {
    long long fileSize = [[[[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL] objectForKey:NSFileSize] longLongValue];
    return [self fileBlockSHA1:path withOffset:0 withLength:MIN(128 * 1024, fileSize)];
}

- (NSString *)unescapeUnicodeString {
#if !DEBUG // 该转中文字符的方法可能Crash，只在DEBUG模式使用
    return self;
#endif
    NSString *string = [self stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    string = [[@"\"" stringByAppendingString:string] stringByAppendingString:@"\""];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    id serialization = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:NULL];
    if ([serialization isKindOfClass:[NSString class]]) {
        return serialization;
    }
    return @"";
}

- (NSString *)reformatTelephone {
    NSString *phoneStr = self;
    if ([phoneStr containsString:@"+86"]) {
        phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    }
    NSString *regex = @"[^\\d]";
    return [phoneStr stringByReplacingOccurrencesOfString:regex withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, phoneStr.length)];
}

-(NSString *)html5CodeToString {
    NSString *str = [self stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    str = [str stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    str = [str stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    str = [str stringByReplacingOccurrencesOfString:@"&quot;" withString:@"“"];
    str = [str stringByReplacingOccurrencesOfString:@"&reg;" withString:@"®"];
    str = [str stringByReplacingOccurrencesOfString:@"&copy;" withString:@"©"];
    str = [str stringByReplacingOccurrencesOfString:@"&trade;" withString:@"™"];
    str = [str stringByReplacingOccurrencesOfString:@"&ensp;" withString:@" "];
    str = [str stringByReplacingOccurrencesOfString:@"&emsp;" withString:@" "];
    str = [str stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    return str;
}

//15550925726变成155******26
- (NSString *)formatPhoneString {
    NSString *formatMobile = self;
    if (self.length == 11) {
        formatMobile = [self stringByReplacingCharactersInRange:NSMakeRange(3, 6) withString:@"******"];
    }
    return formatMobile;
}

- (NSString *)stringByDetecteLink {
    NSMutableString *mStr = [[self trim] mutableCopy];
    NSRegularExpression *regexhttp = [NSRegularExpression cachedPattern:NSRegularExpression.RegularLink options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *matchs = [regexhttp matchesInString:mStr options:0 range:NSMakeRange(0, [mStr length])];
    
    NSRegularExpression *regexEmail = [NSRegularExpression cachedPattern:NSRegularExpression.RegularEmail options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *emailMatchs = [regexEmail matchesInString:mStr options:0 range:NSMakeRange(0, [mStr length])];
    
    for (NSInteger i = matchs.count - 1; i >= 0; i--) {
        NSRange urlRange = [matchs[i] rangeAtIndex:0];
        BOOL needBreak = NO;
        for (NSInteger i = emailMatchs.count - 1; i >= 0; i--) {
            NSRange emailRange = [emailMatchs[i] rangeAtIndex:0];
            if (emailRange.location <= urlRange.location && (emailRange.location + emailRange.length) >= (urlRange.location + urlRange.length)) {
                needBreak = YES;
                break;
            }
        }
        if (needBreak) {
            break;
        }
        NSTextCheckingResult *result = matchs[i];
        NSString *str = [mStr substringWithRange:[result rangeAtIndex:0]];
        if ([regexEmail matchesInString:str options:0 range:NSMakeRange(0, [str length])].count == 0) {
            [mStr replaceCharactersInRange:[result rangeAtIndex:0] withString:[NSString stringWithFormat:@"[url=%@]%@[/url]", str, str]];
        }
    }
    return mStr;
}

- (NSString *)stringByDetecteHTMLLink {
    NSMutableString *mStr = [self mutableCopy];
    NSRegularExpression *regexhttp = [NSRegularExpression cachedPattern:NSRegularExpression.RegularLink options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSArray *matchs = [regexhttp matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    for (NSInteger i = matchs.count - 1; i >= 0; i--) {
        NSTextCheckingResult *result = matchs[i];
        NSString *str = [mStr substringWithRange:[result rangeAtIndex:0]];
        [mStr replaceCharactersInRange:[result rangeAtIndex:0] withString:[NSString stringWithFormat:@"<a href=\"%@\" target=\"_blank\">%@</a>", str, str]];
    }
    return mStr;
}

// 秒数变成时分秒("7010"秒变成"01:56:50")
- (NSString *)stringBytimeStringSecond {
    int timeSecond = self.intValue;
    NSString *timeStr = [NSString stringWithFormat:@"%02d:%02d",
                         timeSecond / 60,
                         timeSecond % 60, nil];
    if (timeSecond >= 3600) {
        timeStr = [NSString stringWithFormat:@"%02d:%02d:%02d",
                   timeSecond / 3600,
                   timeSecond % 3600 / 60,
                   timeSecond % 60, nil];
    }
    return timeStr;
}

- (NSString *)getMMSSFromSS {
    NSInteger seconds = [self integerValue];
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02zd",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02zd",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02zd",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    return format_time;
}

- (NSComparisonResult)versionStringCompare:(NSString *)other {
    NSArray *oneComponents = [self componentsSeparatedByString:@"a"];
    NSArray *twoComponents = [other componentsSeparatedByString:@"a"];
    // The parts before the "a"
    NSString *oneMain = [oneComponents objectAtIndex:0];
    NSString *twoMain = [twoComponents objectAtIndex:0];
    // If main parts are different, return that result, regardless of alpha part
    if ([oneMain compare:twoMain] != NSOrderedSame) {
        NSArray *oneMainComponents = [oneMain componentsSeparatedByString:@"."];
        NSArray *twoMainComponents = [twoMain componentsSeparatedByString:@"."];
        NSInteger limit = MIN(oneMainComponents.count, twoMainComponents.count);
        NSInteger i = 0;
        for (i = 0; i < limit; ++i) {
            NSInteger item1 = [[oneMainComponents objectAtIndex:i] integerValue];
            NSInteger item2 = [[twoMainComponents objectAtIndex:i] integerValue];
            if (item1 < item2) {
                return NSOrderedAscending;
            } else if (item1 > item2) {
                return NSOrderedDescending;
            } else {
                continue ;
            }
        }
        // Now, i == limit
        if (oneMainComponents.count < twoMainComponents.count) {
            return NSOrderedAscending;
        } else if (oneMainComponents.count > twoMainComponents.count) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }
    if ([oneComponents count] < [twoComponents count]) {
        return NSOrderedDescending;
    } else if ([oneComponents count] > [twoComponents count]) {
        return NSOrderedAscending;
    } else if ([oneComponents count] == 1) {
        // Neither has an alpha part, and we know the main parts are the same
        return NSOrderedSame;
    }
    // At this point the main parts are the same and both have alpha parts. Compare the alpha parts
    // numerically. If it's not a valid number (including empty string) it's treated as zero.
    NSNumber *oneAlpha = [NSNumber numberWithInt:[[oneComponents objectAtIndex:1] intValue]];
    NSNumber *twoAlpha = [NSNumber numberWithInt:[[twoComponents objectAtIndex:1] intValue]];
    return [oneAlpha compare:twoAlpha];
}

- (NSString *)urlEncoded {
    CFStringRef cfUrlEncodedString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                             (__bridge CFStringRef)self,NULL,
                                                                             (CFStringRef)@"!#$%&'()*+,/:;=?@[]",
                                                                             kCFStringEncodingUTF8);
    NSString *urlEncoded = [NSString stringWithString:(__bridge NSString *)cfUrlEncodedString];
    CFRelease(cfUrlEncodedString);
    return urlEncoded;
}

+ (NSString*)fileBlockSHA1:(NSString*)path withOffset:(long long)fileOffset withLength:(long long)totalLength {
	NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
	if( handle== nil ) return @"ERROR GETTING FILE MD5"; // file didnt exist
    [handle seekToFileOffset:fileOffset];
    long long hashedLen=0;
    CC_SHA1_CTX sha1;
	CC_SHA1_Init(&sha1);
    BOOL done = NO;
	while(!done) {
        @autoreleasepool {
            NSUInteger blockSHA1Len = 4096;
            NSUInteger leftLen = (NSUInteger)(totalLength - hashedLen);
            if (leftLen<blockSHA1Len) {
                blockSHA1Len = leftLen;
            }
            NSData* fileData = [handle readDataOfLength:(NSUInteger)blockSHA1Len];//CHUNK_SIZE
            CC_SHA1_Update(&sha1, [fileData bytes], (uint32_t)[fileData length]);
            if( [fileData length] == 0 ) done = YES;
            
            hashedLen+=blockSHA1Len;
            if (hashedLen==totalLength) {
                done=YES;
            }
        }
	}
	unsigned char digest[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1_Final(digest, &sha1);
    NSString* s = [NSString stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1], digest[2], digest[3], digest[4], digest[5], digest[6], digest[7],
                   digest[8], digest[9], digest[10], digest[11], digest[12], digest[13], digest[14], digest[15],
                   digest[16], digest[17], digest[18], digest[19]
                   ];
	return s;
}

- (CGSize)sizeWithFont:(UIFont *)font forWidth:(CGFloat)width {
    NSParameterAssert(font);
    if (width > 0) {
        CGRect rect = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
        return CGSizeMake(ceil(rect.size.width), ceil(rect.size.height));
    } else {
        CGSize size = [self sizeWithAttributes:@{NSFontAttributeName: font}];
        return CGSizeMake(ceil(size.width), ceil(size.height));
    }
}

- (NSMutableAttributedString *)mutableAttributedString:(NSString *)keyword {
    UIColor *red = [UIColor colorWithRed:229 / 255.0 green:57 / 255.0 blue:72 / 255.0 alpha:1.0];
    return [self mutableAttributedString:keyword andColor:red];
}

- (NSMutableAttributedString *)mutableAttributedString:(NSString *)keyword andColor:(UIColor *)color {
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self];
    NSRange range = [self rangeOfString:keyword options:NSCaseInsensitiveSearch];
    if (keyword.length <= self.length) {
        if (range.location != NSNotFound) {
            [str addAttribute:NSForegroundColorAttributeName value:color range:range];
        }
    }
    return str;
}

- (NSMutableAttributedString *)mutableAttributedStringWithRange:(NSRange)range andColor:(UIColor *)color {
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self];
    if (range.location != NSNotFound) {
        [str addAttribute:NSForegroundColorAttributeName value:color range:range];
    }
    return str;
}

- (NSMutableAttributedString *)mutableAttributedString:(NSString *)keyword bySeparator:(BOOL)isSeparator{
    if (isSeparator) {
        return [self mutableAttributedString:keyword andColor:kSearchKeyWordColor andSeparator:isSeparator];
    }else{
        return [self mutableAttributedString:keyword andColor:kSearchKeyWordColor];
    }
}

/**
 高亮字符串
 
 @param keyword 关键字
 @param color 高亮颜色
 @param isSeparator 是否分割
 @return 返回高亮字符
 */
- (NSMutableAttributedString *)mutableAttributedString:(NSString *)keyword andColor:(UIColor *)color andSeparator:(BOOL)isSeparator{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self];
    if (isSeparator) {
        //        NSArray *keysArray=[keyword componentsSeparatedByString:@""];
        for (NSInteger i=0;i<[keyword trim].length;i++) {
            NSString *key=[NSString stringWithFormat: @"%@",[keyword substringWithRange:NSMakeRange(i, 1)] ];
            if (key && key.length > 0 && key.length <= self.length) {
                NSMutableArray *locations=[self getRangeStr:self findText:key];
                for (NSInteger index=0; index<locations.count; index++) {
                    NSUInteger location=[locations[index] unsignedIntegerValue];
                    NSRange range=NSMakeRange(location, key.length);
                    if (range.location != NSNotFound) {
                        [str addAttribute:NSForegroundColorAttributeName value:color range:range];
                    }
                }
            }
            
        }
    }
    return str;
}

//包含中文
- (BOOL)includeChinese {
    for(int i = 0; i < [self length]; i++) {
        int a = [self characterAtIndex:i];
        if( a > 0x4e00 && a <0x9fff){
            return YES;
        }
    }
    return NO;
}

-(BOOL)isAllNumber {
    NSRegularExpression *friendRegExp =
    [[NSRegularExpression alloc] initWithPattern:kIsNumberRegute options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [friendRegExp matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    if (matches.count > 0) {
        return NO;
    }
    return YES;
}

- (BOOL)settingPassword {
    //8-20位数字和字母组合
    NSString *regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[\\S]{8,20}$";
    //    "^(?![0-9]+$)(?![a-zA-Z]+$)[\\S]{8,20}$"
    NSPredicate *prd = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [prd evaluateWithObject:self];
}

- (BOOL)settingGroupFilePassword {
    NSString *regex = @"^[a-zA-Z0-9_-]{4,50}$";
    NSPredicate *prd = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [prd evaluateWithObject:self];
}

//纯中文
- (BOOL)isChinese {
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

- (NSMutableArray *)getRangeStr:(NSString *)text findText:(NSString *)findText{
    NSMutableArray *arrayRanges = [NSMutableArray arrayWithCapacity:20];
    if (findText == nil && [findText isEqualToString:@""]) {
        return nil;
    }
    NSRange rang = [text rangeOfString:findText options:NSCaseInsensitiveSearch]; //获取第一次出现的range
    if (rang.location != NSNotFound && rang.length != 0) {
        [arrayRanges addObject:[NSNumber numberWithInteger:rang.location]];//将第一次的加入到数组中
        NSRange rang1 = {0,0};
        NSInteger location = 0;
        NSInteger length = 0;
        for (int i = 0;; i++) {
            if (0 == i) {//去掉这个xxx
                location = rang.location + rang.length;
                length = text.length - rang.location - rang.length;
                rang1 = NSMakeRange(location, length);
            } else {
                location = rang1.location + rang1.length;
                length = text.length - rang1.location - rang1.length;
                rang1 = NSMakeRange(location, length);
            }
            //在一个range范围内查找另一个字符串的range
            rang1 = [text rangeOfString:findText options:NSCaseInsensitiveSearch range:rang1];
            if (rang1.location == NSNotFound && rang1.length == 0) {
                break;
            } else {//添加符合条件的location进数组
                [arrayRanges addObject:[NSNumber numberWithInteger:rang1.location]];
            }
            
        }
        return arrayRanges;
    }
    return nil;
}
//判断手机号码格式是否正确
+ (BOOL)valiMobile:(NSString *)mobile {
    mobile = [mobile stringByReplacingOccurrencesOfString:@" "withString:@""];
    if (mobile.length != 11) {
        return NO;
    } else {
        //前端仅检查下列规则, 以1开头11位数字, 更严格逻辑由服务器检查, 以防运营商添加新号段
        NSString *phoneRegex = @"^1[0-9]{10}$";
        NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
        return [phoneTest evaluateWithObject:mobile];
    }
}

+ (BOOL)isNumberCode:(NSString *)str {
    if (str.length == 0) {
        return NO;
    }
	NSString *regex = @"^\\d{4}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

@end

@implementation NSURL (UDAdditions)

- (NSDictionary *)queryPairs {
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    NSArray<NSURLQueryItem *> *items = [components queryItems];
    if (items.count == 0) {
        return nil;
    }
    NSMutableDictionary *pairs = [NSMutableDictionary dictionaryWithCapacity:items.count];
    for (NSURLQueryItem *item in items) {
        [pairs setObject:item.value forKey:item.name];
    }
    return pairs;
}

@end
