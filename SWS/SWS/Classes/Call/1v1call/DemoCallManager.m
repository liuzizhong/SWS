//
//  DemoCallManager.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 22/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "DemoCallManager.h"
#import <YYKit/NSDictionary+YYAdd.h>
#import "EaseSDKHelper.h"
#import "UserCacheManager.h"
#import "EMCallViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "SWS-Swift.h"

static DemoCallManager *callManager = nil;

@interface DemoCallManager()<EMCallManagerDelegate, EMCallBuilderDelegate>

@property (strong, nonatomic) NSObject *callLock;

@property (copy, nonatomic) NSString *regionStr;

@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) EMCallSession *currentSession;

@property (strong, nonatomic) EMCallViewController *currentController;

@end


@implementation DemoCallManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initManager];
    }
    
    return self;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        callManager = [[DemoCallManager alloc] init];
    });
    
    return callManager;
}

- (void)dealloc
{
//    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].callManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_CALL object:nil];
}

#pragma mark - private

- (void)_initManager
{
    _callLock = [[NSObject alloc] init];
    _currentSession = nil;
    _currentController = nil;
    
//    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].callManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].callManager setBuilderDelegate:self];

    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"calloptions.data"];
    EMCallOptions *options = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        options = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    } else {
        options = [[EMClient sharedClient].callManager getCallOptions];
        options.isSendPushIfOffline = YES;
        options.videoResolution = EMCallVideoResolution640_480;
        options.isFixedVideoResolution = YES;
    }
    [[EMClient sharedClient].callManager setCallOptions:options];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeCall:) name:KNOTIFICATION_CALL object:nil];
}

- (void)_clearCurrentCallViewAndData
{
    @synchronized (_callLock) {
        self.currentSession = nil;
        
        self.currentController.isDismissing = YES;
        [self.currentController clearData];
        [self.currentController dismissViewControllerAnimated:NO completion:nil];
        self.currentController = nil;
    }
}

#pragma mark - private timer

/**
 超过固定时间未接听，AB都会进入这里
 */
- (void)_timeoutBeforeCallAnswered
{
    [self hangupCallWithReason:EMCallEndReasonNoResponse];
}

/**
 开始定时器计时
 */
- (void)_startCallTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(self.currentSession.isCaller) ? 50 : 49 target:self selector:@selector(_timeoutBeforeCallAnswered) userInfo:nil repeats:NO];
}

/**
 关闭定时器计时
 */
- (void)_stopCallTimer
{
    if (self.timer == nil) {
        return;
    }
    
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - EMCallManagerDelegate

/*!
 *  \~chinese
 *  用户A拨打用户B，用户B会收到这个回调
 *
 *  @param aSession  会话实例
 */
- (void)callDidReceive:(EMCallSession *)aSession
{
    if (!aSession || [aSession.callId length] == 0) {
        return ;
    }
    
    if ([EaseSDKHelper shareHelper].isShowingimagePicker) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideImagePicker" object:nil];
    }
    
    if(self.isCalling || (self.currentSession && self.currentSession.status != EMCallSessionStatusDisconnected)){
        [[EMClient sharedClient].callManager endCall:aSession.callId reason:EMCallEndReasonBusy];
        return;
    }
    
    [[DemoCallManager sharedManager] setIsCalling:YES];
    @synchronized (_callLock) {
        [self _startCallTimer];
        
        // 接收到语音通话请求时，保存对方传过来的昵称头像
        [UserCacheManager saveWithJson:aSession.ext userName:aSession.remoteName];
        
        if (aSession.ext) {/// 获取分区信息
            NSData *extData = [aSession.ext dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *extDic = [NSJSONSerialization JSONObjectWithData:extData options:0 error:nil];
            self.regionStr = [extDic objectForKey:kChatRegionStr];
        }
        
        self.currentSession = aSession;
        self.currentController = [[EMCallViewController alloc] initWithCallSession:self.currentSession];
        self.currentController.regionStr = self.regionStr;
//        self.currentController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
        if ([self needShowNotification]) {
            UIApplicationState state = [[UIApplication sharedApplication] applicationState];
#if !TARGET_IPHONE_SIMULATOR
            switch (state) {
                case UIApplicationStateBackground:
                    [self showNotificationWithCall];
                    break;
                default:
                    break;
            }
#endif
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.currentController) {
                self.currentController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                [[self.mainController getTopViewController] presentViewController:self.currentController animated:YES completion:nil];
            }
        });
    }
}

/**
 判断是否需要发送通知给对方，要对方在线并接收到了邀请，在后台才会发送

 @return 是否通知
 */
- (BOOL)needShowNotification
{
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    if (options.noDisturbStatus != EMPushNoDisturbStatusDay) {
        return ![SW_IgnoreManager isIgnoreStaff:_currentSession.remoteName];
    }
    //免打扰则不发通知
    return NO;
}

/**
 发送本地推送通知
 */
- (void)showNotificationWithCall
{
    NSString *alertBody = nil;
    
    if (_currentSession.type == EMCallTypeVideo) {
        alertBody = [NSString stringWithFormat:@"%@：邀请您进行视频通话", [UserCacheManager getNickName:_currentSession.remoteName]];
    } else {
        alertBody = [NSString stringWithFormat:@"%@：邀请您进行语音通话", [UserCacheManager getNickName:_currentSession.remoteName]];
    }
    
    //发送本地推送
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        
        content.sound = [UNNotificationSound defaultSound];
        
        content.body =alertBody;
        
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:_currentSession.remoteName content:content trigger:trigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
    }
    else {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date]; //触发通知的时间
        notification.alertBody = alertBody;
        notification.alertAction = NSLocalizedString(@"open", @"Open");
        notification.timeZone = [NSTimeZone defaultTimeZone];
        
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        //发送通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
}

/*!
 *  \~chinese
 *  通话通道建立完成，用户A和用户B都会收到这个回调
 *
 *  @param aSession  会话实例
 */
- (void)callDidConnect:(EMCallSession *)aSession
{
    if ([aSession.callId isEqualToString:self.currentSession.callId]) {
        [self.currentController stateToConnected];
    }
}
/*!
 *  \~chinese
 *  用户B同意用户A拨打的通话后，用户A会收到这个回调
 *
 *  @param aSession  会话实例
 */
- (void)callDidAccept:(EMCallSession *)aSession
{
    if ([aSession.callId isEqualToString:self.currentSession.callId]) {
        [self _stopCallTimer];
        [self.currentController stateToAnswered];
    }
}
/*!
 *  \~chinese
 *  1. 对方结束通话，结束通话后，己方会收到该回调
 *  2. 通话出现错误，双方都会收到该回调
 *
 *  @param aSession  会话实例
 *  @param aReason   结束原因
 *  @param aError    错误
 */
- (void)callDidEnd:(EMCallSession *)aSession
            reason:(EMCallEndReason)aReason
             error:(EMError *)aError
{
    if ([aSession.callId isEqualToString:self.currentSession.callId]) {
        self.isCalling = NO;
        [self _stopCallTimer];
        
        EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
        options.enableCustomizeVideoData = NO;
        
        /// 接通过则是时间长度，否则是  已取消
        NSString *reasonStr = [self.currentController getCallDuration];
        if (![reasonStr isEqualToString:@"已取消       "]) {
            reasonStr = [NSString stringWithFormat:@"通话时长 %@       ",reasonStr];
        }
//        NSString *reasonStr = @"通话结束";
        if (aReason != EMCallEndReasonHangup) {
            switch (aReason) {
                case EMCallEndReasonNoResponse:
                {
                    reasonStr = @"对方未接听       ";
                }
                    break;
                case EMCallEndReasonDecline:
                {
                    reasonStr = @"对方已拒绝       ";
                }
                    break;
                case EMCallEndReasonBusy:
                {
                    reasonStr = @"对方繁忙       ";
                }
                    break;
                case EMCallEndReasonFailed:
                {
                    reasonStr = @"通话失败       ";
                }
                    break;
                default:
                    break;
            }
            NSLog(@"%@",reasonStr);
            [self saveCallRecordWithText:reasonStr];
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:reasonStr delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", @"确定") otherButtonTitles:nil, nil];
//                [alertView show];
            
        } else {// 对方挂断
            //            可能是通话中挂断，，还可能是对方取消通话
            NSLog(@"对方挂断");
            [self saveCallRecordWithText:reasonStr];
        }
        @synchronized (_callLock) {
            self.currentSession = nil;
            [self _clearCurrentCallViewAndData];
        }
    }
}
/*!
 *  \~chinese
 *  用户A和用户B正在通话中，用户A中断或者继续数据流传输时，用户B会收到该回调
 *
 *  @param aSession  会话实例
 *  @param aType     改变类型
 */
- (void)callStateDidChange:(EMCallSession *)aSession
                      type:(EMCallStreamingStatus)aType
{
    if ([aSession.callId isEqualToString:self.currentSession.callId]) {
        [self.currentController setStreamType:aType];
    }
}
/*!
 *  \~chinese
 *  用户A和用户B正在通话中，用户A的网络状态出现不稳定，用户A会收到该回调
 *
 *  @param aSession  会话实例
 *  @param aStatus   当前状态
 */
- (void)callNetworkDidChange:(EMCallSession *)aSession
                      status:(EMCallNetworkStatus)aStatus
{
    if ([aSession.callId isEqualToString:self.currentSession.callId]) {
        [self.currentController setNetwork:aStatus];
    }
}

#pragma mark - EMCallBuilderDelegate
/*!
 *  \~chinese
 *  用户A给用户B拨打实时通话，用户B不在线，并且用户A设置了[EMCallOptions.isSendPushIfOffline == YES],则用户A会收到该回调
 *
 *  @param aRemoteName  用户B的环信ID
 */
- (void)callRemoteOffline:(NSString *)aRemoteName
{
    NSString *text = @"";
    if (self.currentSession.type == EMCallTypeVideo) {
        text = @"邀请您进行视频通话";
    } else {
        text = @"邀请您进行语音通话";
    }
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
    NSString *fromStr = [EMClient sharedClient].currentUsername;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aRemoteName from:fromStr to:aRemoteName body:body ext:@{}];// 不传拓展消息的消息不会加入到对方消息记录中
//    @"em_apns_ext":@{@"em_push_title":text}
    message.chatType = EMChatTypeChat;
    //xxx邀请您语音/视频通话
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil
                                          completion:^(EMMessage *message, EMError *error) {
                                              [[[EMClient sharedClient].chatManager getConversation:aRemoteName type:EMConversationTypeChat createIfNotExist:YES] deleteMessageWithId:message.messageId error:nil];
                                          }];

}

#pragma mark - NSNotification

/**
 点击了通话按钮，收到通知，发起通话

 @param notify 点击按钮发出的通知
 */
- (void)makeCall:(NSNotification*)notify
{
    if (!notify.object) {
        return;
    }
    
    EMCallType type = (EMCallType)[[notify.object objectForKey:@"type"] integerValue];
    [self makeCallWithUsername:[notify.object valueForKey:@"chatter"] regionStr:[notify.object valueForKey:@"regionStr"] type:type isCustomVideoData:NO];
//    if (type == EMCallTypeVideo) {
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//
//        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"title.conference.default", @"Default") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self makeCallWithUsername:[notify.object valueForKey:@"chatter"] type:type isCustomVideoData:NO];
//        }];
//        [alertController addAction:defaultAction];
//
//        UIAlertAction *customAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"title.conference.custom", @"Custom") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self makeCallWithUsername:[notify.object valueForKey:@"chatter"] type:type isCustomVideoData:YES];
//        }];
//        [alertController addAction:customAction];
//
//        [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel") style: UIAlertActionStyleCancel handler:nil]];
//
//        [[self.mainController getTopViewController] presentViewController:alertController animated:YES completion:nil];
//    } else {
//        [self makeCallWithUsername:[notify.object valueForKey:@"chatter"] type:type isCustomVideoData:NO];
//    }
}

#pragma mark - public
/**
 保存通话设置
 */
- (void)saveCallOptions
{
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"calloptions.data"];
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    [NSKeyedArchiver archiveRootObject:options toFile:file];
}

/**
 新建通话根据用户名
 
 @param aUsername 环信用户名
 @param aType 通话类型：视频或者通话
 */
- (void)makeCallWithUsername:(NSString *)aUsername
                   regionStr:(NSString *)aRegionStr
                        type:(EMCallType)aType
           isCustomVideoData:(BOOL)aIsCustomVideo
{
    if ([aUsername length] == 0) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    void (^completionBlock)(EMCallSession *, EMError *) = ^(EMCallSession *aCallSession, EMError *aError) {
        DemoCallManager *strongSelf = weakSelf;
        if (strongSelf) {
            if (aError || aCallSession == nil) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"通话创建失败", @"通话创建失败") message:aError.errorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", @"确定") otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            
            @synchronized (self.callLock) {
                strongSelf.currentSession = aCallSession;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (aType == EMCallTypeVideo) {
                        strongSelf.currentController = [[EMCallViewController alloc] initWithCallSession:strongSelf.currentSession isCustomData:aIsCustomVideo];
                        strongSelf.currentController.regionStr = aRegionStr;
                    } else {
                        strongSelf.currentController = [[EMCallViewController alloc] initWithCallSession:strongSelf.currentSession];
                        strongSelf.currentController.regionStr = aRegionStr;
                    }
                    
                    if (strongSelf.currentController) {
                        strongSelf.currentController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                        [[strongSelf.mainController getTopViewController] presentViewController:strongSelf.currentController animated:YES completion:nil];
                    }
                });
            }
            
            [weakSelf _startCallTimer];
        }
        else {
            [[EMClient sharedClient].callManager endCall:aCallSession.callId reason:EMCallEndReasonNoResponse];
        }
    };
    
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    options.enableCustomizeVideoData = aIsCustomVideo;
    
    // 请求语音通话时，将昵称头像通过扩展属性传递过去
    NSMutableDictionary *extDic = [NSMutableDictionary dictionaryWithDictionary:[UserCacheManager getMyMsgExt]];
    self.regionStr = aRegionStr;
    extDic[kChatRegionStr] = aRegionStr;
    NSString *ext = [extDic jsonStringEncoded];
    [[EMClient sharedClient].callManager startCall:aType remoteName:aUsername ext:ext completion:^(EMCallSession *aCallSession, EMError *aError) {
        completionBlock(aCallSession, aError);
    }];
}
/**
 接受通话邀请
 
 @param aCallId 通话id
 */
- (void)answerCall:(NSString *)aCallId
{
    if (!self.currentSession || ![self.currentSession.callId isEqualToString:aCallId]) {
        return ;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient].callManager answerIncomingCall:weakSelf.currentSession.callId];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error.code == EMErrorNetworkUnavailable) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"网络断开", @"网络断开") delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", @"确定") otherButtonTitles:nil, nil];
                    [alertView show];
                }
                else{/// 接受通话失败
                    [weakSelf hangupCallWithReason:EMCallEndReasonFailed];
                }
            });
        }
    });
}

/**
 自己这边结束通话调用，添加记录显示
 
 @param aReason 结束原因
 */
- (void)hangupCallWithReason:(EMCallEndReason)aReason
{
    self.isCalling = NO;
    [self _stopCallTimer];
    
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    options.enableCustomizeVideoData = NO;
    
//    4中情况  EMCallEndReasonNoResponse 要区分isCaller  其他3种都是自己挂断
//    EMCallEndReasonNoResponse// EMCallEndReasonFailed//EMCallEndReasonDecline//EMCallEndReasonHangup
    
    /// 接通过则是时间长度，否则是  已取消
    NSString *reasonStr = [self.currentController getCallDuration];
    if (![reasonStr isEqualToString:@"已取消       "]) {
        reasonStr = [NSString stringWithFormat:@"通话时长 %@       ",reasonStr];
    }
    //        NSString *reasonStr = @"通话结束";
    if (aReason != EMCallEndReasonHangup) {
        switch (aReason) {
            case EMCallEndReasonNoResponse:
            {
                reasonStr = self.currentSession.isCaller ? @"对方未接听       " : @"未接听       " ;
            }
                break;
            case EMCallEndReasonDecline:
            {
                reasonStr = @"已拒绝       ";
            }
                break;
            case EMCallEndReasonFailed:
            {
                reasonStr = @"通话失败       ";
            }
                break;
            default:
                break;
        }
        NSLog(@"%@",reasonStr);
        [self saveCallRecordWithText:reasonStr];
    } else {// 对方挂断
        //            可能是通话中挂断，，还可能是对方取消通话
        NSLog(@"自己挂断");
        [self saveCallRecordWithText:reasonStr];
    }
    
    if (self.currentSession) {
        [[EMClient sharedClient].callManager endCall:self.currentSession.callId reason:aReason];
    }
    
    [self _clearCurrentCallViewAndData];
}



/**
 本地插入消息，

 @param text 消息提示文本
 */
- (void)saveCallRecordWithText:(NSString *)text
{
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
    NSNumber *callType = self.currentSession.type == EMCallTypeVoice ? @0 : @1;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:self.currentSession.remoteName from:self.currentSession.isCaller ? self.currentSession.localName : self.currentSession.remoteName to:self.currentSession.isCaller ? self.currentSession.remoteName : self.currentSession.localName body:body ext:@{@"callType":callType}];
//    EMCallTypeVoice = 0,    /*! \~chinese 实时语音 \~english Voice call */
//    EMCallTypeVideo,
    
    message.chatType = EMChatTypeChat;
    message.direction = self.currentSession.isCaller ? EMMessageDirectionSend : EMMessageDirectionReceive;
    message.status = EMMessageStatusSucceed;
    message.messageId = [[NSUUID UUID] UUIDString];
    message.isRead = self.currentSession.isCaller;
    
    [[[EMClient sharedClient].chatManager getConversation:self.currentSession.remoteName type:EMConversationTypeChat createIfNotExist:YES] insertMessage:message error:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_INSERTMSG object:@{@"message":message}];
}

@end
