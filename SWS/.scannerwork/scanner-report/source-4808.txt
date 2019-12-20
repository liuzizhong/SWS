//
//  NSTimer+Additions.m
//  UDPhone
//
//  Created by ZhiXuan Li on 21/3/16.
//  Copyright © 2016 115.com. All rights reserved.
//

#import "NSTimer+Additions.h"

@implementation NSTimer (Additions)

+ (void)execBlock:(NSTimer *)timer {
    if ([timer userInfo]) {
        void (^block)(NSTimer *timer) = (void (^)(NSTimer *timer))[timer userInfo];
        block(timer);
    }
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats {
    return [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(execBlock:) userInfo:[block copy] repeats:repeats];
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats {
    return [NSTimer timerWithTimeInterval:seconds target:self selector:@selector(execBlock:) userInfo:[block copy] repeats:repeats];
}

@end
