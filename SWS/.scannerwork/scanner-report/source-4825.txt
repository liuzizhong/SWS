//
//  ALiUtil.m
//  ALiVideoRecorder
//
//  Created by LeeWong on 2016/12/5.
//  Copyright © 2016年 LeeWong. All rights reserved.
//

#import "ALiUtil.h"
#include <sys/param.h>
#include <sys/mount.h>
#import <AVFoundation/AVFoundation.h>

@implementation ALiUtil
#pragma mark -播放系统提示音
+ (void)playSystemTipAudioIsBegin:(BOOL)isBegin
{
    //播放系统提示音
    
    SystemSoundID soundIDTest = isBegin ? 1117 : 1118;
    AudioServicesPlaySystemSound(soundIDTest);
}

long long freeSpace() {
    float freeSize;
    NSError *error = nil;
    NSDictionary *infoDic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (infoDic) {
//        NSNumber * fileSystemFreeSize = [infoDic objectForKey: NSFileSystemFreeSize];
//        freeSize = [fileSystemFreeSize floatValue]/1024.0f/1024.0f;
        int64_t space =  [[infoDic objectForKey:NSFileSystemFreeSize] longLongValue];
        if (space < 0) space = -1;
        return space/1024/1024;
    } else {
        return 0;
    }
//    struct statfs buf;
//    long long freespace = -1;
//    if(statfs("/", &buf) >= 0){
//        freespace = (long long)buf.f_bsize * buf.f_bfree;
//    }
//
//    return freespace;
}

+ (long long)diskFreeSpace
{
    return freeSpace();
}

+(float)getTotalDiskSpaceInBytes {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    struct statfs tStats;
    statfs([[paths lastObject] cString], &tStats);
    float totalSpace = (float)(tStats.f_blocks * tStats.f_bsize);
    
    return totalSpace;
}
@end
