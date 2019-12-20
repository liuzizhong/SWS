//
//  PHAsset+Hash.h
//  UDPhone
//
//  Created by 杨仕忠 on 11/9/12.
//  Copyright (c) 2012 YLMF Co.,Inc. All rights reserved.
//

@import Photos;

NS_ASSUME_NONNULL_BEGIN

@interface PHAsset (Hash)
- (long long)assetSize;
-(NSString*)blockSHA1WithOffset:(long long)assetOffset withLength:(long long)totalLength;
-(NSString*)assetSHA1;
/** 计算文件前 128k 的 SHA1 值，不足 128k 则取整个文件的长度 */
-(NSString*)assetSHA1To128K;
-(NSString*)assetMD5;
@end

NS_ASSUME_NONNULL_END
