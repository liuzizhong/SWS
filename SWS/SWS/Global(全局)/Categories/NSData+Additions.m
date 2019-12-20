//
//  NSData+Additions.m
//  UDown
//
//  Created by 杨 德升 on 12-3-5.
//  Copyright (c) 2012年 YLMF Co.,Inc. All rights reserved.
//

#import "NSData+Additions.h"
#import <CommonCrypto/CommonDigest.h>
//#import "YYImageCoder.h"

@implementation NSData (UDAdditions)

///////////////////////////////////////////////////////////////////////////////////////////////////
//md115算法 creat by wunan
- (NSString *)md115Hash {
    
    NSUInteger dataLength = self.length;
    NSString *dataLengthStr = [NSString stringWithFormat:@"%lu",(unsigned long)dataLength];
    NSUInteger blockLength = 5120;
    NSData *block1Data = [self subdataWithRange:NSMakeRange(0, blockLength)];
    NSData *block2Data = [self subdataWithRange:NSMakeRange((NSUInteger)floor(0.13*dataLength), blockLength)];
    NSData *block3Data = [self subdataWithRange:NSMakeRange((NSUInteger)floor(0.37*dataLength), blockLength)];
    NSData *block4Data = [self subdataWithRange:NSMakeRange((NSUInteger)floor(0.62*dataLength), blockLength)];
    NSData *block5Data = [self subdataWithRange:NSMakeRange(dataLength-blockLength, blockLength)];
    NSMutableData *blockConnectData = [NSMutableData data];
    [blockConnectData appendData:block1Data];
    [blockConnectData appendData:block2Data];
    [blockConnectData appendData:block3Data];
    [blockConnectData appendData:block4Data];
    [blockConnectData appendData:block5Data];
    [blockConnectData appendData:[dataLengthStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *md115SHA1Str = [[blockConnectData sha1Hash] uppercaseString];
    return md115SHA1Str;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)md5Hash {
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5([self bytes], (uint32_t)[self length], result);
  
  return [NSString stringWithFormat:
          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
          result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
          result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
          ];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)sha1Hash {
  unsigned char result[CC_SHA1_DIGEST_LENGTH];
  CC_SHA1([self bytes], (uint32_t)[self length], result);
  
  return [NSString stringWithFormat:
          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
          result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
          result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15],
          result[16], result[17], result[18], result[19]
          ];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// base64 code found on http://www.cocoadev.com/index.pl?BaseSixtyFour
// where the poster released it to public domain
// style not exactly congruous with normal three20 style, but kept mostly intact with the original
static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSData*)dataWithBase64EncodedString:(NSString *)string {
    if ([string length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    char *tempBytes = bytes;
    bytes = realloc(tempBytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)base64Encoding {
    if ([self length] == 0)
        return @"";
    
    char *characters = malloc((([self length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [self length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [self length])
            buffer[bufferLength++] = ((char *)[self bytes])[i++];
        
        // Encode the bytes in the buffer to four characters,
        // including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length
                                        encoding:NSASCIIStringEncoding freeWhenDone:YES];
}
// end recycled base64 code
///////////////////////////////////////////////////////////////////////////////////////////////////



//- (NSString *)imageType {
//    YYImageType type = YYImageDetectType((__bridge CFDataRef _Nonnull)(self));
//    switch (type) {
//        case YYImageTypeGIF:
//            return @"GIF";
//        case YYImageTypeJPEG:
//        case YYImageTypeJPEG2000:
//            return @"JPEG";
//        case YYImageTypePNG:
//            return @"PNG";
//        case YYImageTypeWebP:
//            return @"WEBP";
//        case YYImageTypeTIFF:
//            return @"TIFF";
//        case YYImageTypeBMP:
//            return @"BMP";
//        case YYImageTypeICO:
//            return @"ICO";
//        case YYImageTypeICNS:
//            return @"ICNS";
//        default:
//            return @"JPG";
//            break;
//    }
//}

@end
