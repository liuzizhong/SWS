//
//  DemoCallManager.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 22/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Hyphenate/Hyphenate.h>
#import "EMCallOptions+NSCoding.h"

@protocol DemoCallManagerDelegate <NSObject>

@optional
- (UIViewController *)getTopViewController;

@optional
- (UINavigationController *)getCurrentNaVController;
@end

//@class MainViewController;
@interface DemoCallManager : NSObject

@property (nonatomic) BOOL isCalling;

@property (weak, nonatomic) UIViewController<DemoCallManagerDelegate> *mainController;

+ (instancetype)sharedManager;

/**
 保存通话设置
 */
- (void)saveCallOptions;

/**
 新建通话根据用户名

 @param aUsername 环信用户名
 @param aType 通话类型：视频或者通话
 */
- (void)makeCallWithUsername:(NSString *)aUsername
                   regionStr:(NSString *)aRegionStr
                        type:(EMCallType)aType
           isCustomVideoData:(BOOL)aIsCustomVideo;

/**
 接受通话邀请

 @param aCallId 通话id
 */
- (void)answerCall:(NSString *)aCallId;

/**
 结束通话

 @param aReason 结束原因
 */
- (void)hangupCallWithReason:(EMCallEndReason)aReason;

@end
