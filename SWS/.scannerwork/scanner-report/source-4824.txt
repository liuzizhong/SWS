//
//  UIButton+InsensitiveTouch.h
//  SWS
//
//  Created by jayway on 2018/7/4.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (InsensitiveTouch)
//开启UIButton防连点模式
+ (void)enableInsensitiveTouch;
//关闭UIButton防连点模式
+ (void)disableInsensitiveTouch;
//设置防连续点击最小时间差(s),不设置则默认值是0.5s
+ (void)setInsensitiveMinTimeInterval:(NSTimeInterval)interval;
@end
