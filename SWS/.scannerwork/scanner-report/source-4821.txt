//
//  UIButton+UIButtonImageWithLable.h
//  RESwitchExample
//
//  Created by bunsman on 13-11-20.
//  Copyright (c) 2013年 Bunsman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (UIButtonImageWithLable)

/**
 *  自动设置按钮的图片和文字的位置
 *
 *  使用前要先设好按钮的大小、normal状态的图标和文字
 *  @param distance 图标和文字的距离
 */

- (void)resizeWithDistance:(int)distance;
- (void)resizeWithDistance:(int)distance offset:(CGFloat)offset;
- (void)resizeWithDistance:(int)distance offset:(CGFloat)offset state:(UIControlState)state;

@end

/**
 *  在layoutSubviews方法里自动设置按钮的图片和文字的位置
 */
@interface UDButton : UIButton

@property(nonatomic) float contentDistance;
@property(nonatomic) float contentOffset;

@end
