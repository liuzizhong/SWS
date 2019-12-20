//
//  SW_TwoRowNavTitleView.h
//  SWS
//
//  Created by jayway on 2018/5/31.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SW_TwoRowNavTitleView : UILabel

/**
 第一行标题
 */
@property(nonatomic,copy) NSString *title;

/**
 第二行标题
 */
@property(nonatomic,copy) NSString *detail;

/**
 初始化方法

 @param title 第一行标题
 @param detail 第二行标题
 @return titleview对象
 */
- (instancetype)initWithTitle:(NSString *)title detailTitle:(NSString *)detail;

/**
 类快速初始化方法
 
 @param title 第一行标题
 @param detail 第二行标题
 @return titleview对象
 */
+ (instancetype)titleViewWithTitle:(NSString *)title detailTitle:(NSString *)detail;

@end
