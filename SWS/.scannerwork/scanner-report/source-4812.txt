//
//  ALAsset+Hash.m
//  UDPhone
//
//  Created by 杨仕忠 on 11/9/12.
//  Copyright (c) 2012 YLMF Co.,Inc. All rights reserved.
//

#import "PHAsset+Hash.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSData+Additions.h"

#define BLOCK_SHA1_LEN 4096

@implementation PHAsset (Hash)

- (long long)assetSize {// 不想在MKNetworkOperation.m 的 startSendAsset代码里引入 CloudOffice-Swift.h，所以做了这个函数
    __block long long size = 0;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;// 这个选项表示同步，执行完才下一步,否则后面的hash计算没有意义
    [[PHImageManager defaultManager] requestImageDataForAsset:self options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
     {
         size = imageData.length;
    }];
    return size;
}

-(NSString*)blockSHA1WithOffset:(long long)assetOffset withLength:(long long)totalLength {
    __block CC_SHA1_CTX sha1;
    CC_SHA1_Init(&sha1);
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;// 这个选项表示同步，执行完才下一步,否则后面的hash计算没有意义
    [[PHImageManager defaultManager] requestImageDataForAsset:self options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
     {
         long long imageSize = imageData.length;
         if (imageSize >= assetOffset + totalLength) {
             Byte *testByte = (Byte *)[imageData bytes];
             long long hashedLen = 0;
             long long hashOffset = assetOffset;
             uint8_t *bufferSHA1 = malloc(BLOCK_SHA1_LEN);
             assert(bufferSHA1 != NULL);
             long long blockSHA1Len = BLOCK_SHA1_LEN;
             long long leftLen = (NSUInteger)(totalLength - hashedLen);
             
             BOOL done = NO;
             while(!done) {
                 if (leftLen < blockSHA1Len) {
                     blockSHA1Len = leftLen;
                 }
                 memcpy(bufferSHA1, testByte+hashOffset, blockSHA1Len);
                 
                 CC_SHA1_Update(&sha1, bufferSHA1, (uint32_t)blockSHA1Len);
                 hashedLen += blockSHA1Len;
                 hashOffset += blockSHA1Len;
                 leftLen = totalLength - hashedLen;
                 if (hashedLen == totalLength) {
                     done=YES;
                 }
             }
             free(bufferSHA1);
         }
     }];
    
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

-(NSString*)assetSHA1
{
    NSNumber *fileLengthNum = [NSNumber numberWithLongLong:[self assetSize]];
    assert( [fileLengthNum isKindOfClass:[NSNumber class]] );
    
    return [self blockSHA1WithOffset:0 withLength:fileLengthNum.doubleValue];
}

-(NSString*)assetSHA1To128K {
    NSNumber *fileLengthNum = [NSNumber numberWithLongLong:[self assetSize]] ;
    assert( [fileLengthNum isKindOfClass:[NSNumber class]] );
    return [self blockSHA1WithOffset:0 withLength:MIN(128 * 1024, fileLengthNum.doubleValue)];
}

-(NSString*)assetMD5
{
    NSNumber *fileLengthNum = [NSNumber numberWithLongLong:[self assetSize]] ;
    assert( [fileLengthNum isKindOfClass:[NSNumber class]] );
    __block CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;// 这个选项表示同步，执行完才下一步，否则后面的hash计算没有意义
    [[PHImageManager defaultManager] requestImageDataForAsset:self options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
     {
         double imageSize = imageData.length;
         long long totalLength = fileLengthNum.doubleValue;
         if (imageSize >= totalLength) {
             Byte *testByte = (Byte *)[imageData bytes];
             long long hashedLen=0;
             long long hashOffset =0;
             uint8_t *bufferSHA1 = malloc(BLOCK_SHA1_LEN);
             assert(bufferSHA1 != NULL);
             long long blockSHA1Len = BLOCK_SHA1_LEN;
             long long leftLen = totalLength - hashedLen;
             
             BOOL done = NO;
             while(!done)
             {
                 leftLen = totalLength - hashedLen;
                 if (leftLen < blockSHA1Len) {
                     blockSHA1Len = leftLen;
                 }
                 memcpy(bufferSHA1, testByte+hashOffset, blockSHA1Len);
                 
                 CC_MD5_Update(&md5, bufferSHA1, (uint32_t)blockSHA1Len);
                 
                 hashedLen += blockSHA1Len;
                 hashOffset += blockSHA1Len;
                 if (hashedLen == totalLength) {
                     done=YES;
                 }
             }
             free(bufferSHA1);
         }
     }];
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    return s;
}
@end
