//
//  UIImage+RTTint.h
//
//  Created by Ramon Torres on 7/3/13.
//  Copyright (c) 2013 Ramon Torres <raymondjavaxx@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (RTTint)

-(UIImage*)rt_tintedImageWithColor:(nullable UIColor*)color;
-(UIImage*)rt_tintedImageWithColor:(nullable UIColor*)color level:(CGFloat)level;
-(UIImage*)rt_tintedImageWithColor:(nullable UIColor*)color rect:(CGRect)rect;
-(UIImage*)rt_tintedImageWithColor:(nullable UIColor*)color rect:(CGRect)rect level:(CGFloat)level;
-(UIImage*)rt_tintedImageWithColor:(nullable UIColor*)color insets:(UIEdgeInsets)insets;
-(UIImage*)rt_tintedImageWithColor:(nullable UIColor*)color insets:(UIEdgeInsets)insets level:(CGFloat)level;

-(UIImage*)rt_lightenWithLevel:(CGFloat)level;
-(UIImage*)rt_lightenWithLevel:(CGFloat)level insets:(UIEdgeInsets)insets;
-(UIImage*)rt_lightenRect:(CGRect)rect withLevel:(CGFloat)level;

-(UIImage*)rt_gradientImageWithStartColor:(UIColor*)startColor endColor:(UIColor *)endeColor;

-(UIImage*)rt_darkenWithLevel:(CGFloat)level;
-(UIImage*)rt_darkenWithLevel:(CGFloat)level insets:(UIEdgeInsets)insets;
-(UIImage*)rt_darkenRect:(CGRect)rect withLevel:(CGFloat)level;

@end

NS_ASSUME_NONNULL_END
