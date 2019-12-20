//
//  UIView+Additions.h
//  UDPhone
//
//  Created by strangeliu on 15/5/18.
//  Copyright (c) 2015年 115.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Additions)

@property (assign, nonatomic) CGFloat originX;
@property (assign, nonatomic) CGFloat originY;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) CGPoint origin;
@property (assign, nonatomic) CGFloat centerX;
@property (assign, nonatomic) CGFloat centerY;

- (void)applyMotionEffect;

+ (UIView *)loadNibName:(NSString *)nibName owner:(id)owner;

@end

@interface UIDevice (WJ)
/**
 *  强制旋转设备
 *  @param  旋转方向
 */
+ (void)setOrientation:(UIInterfaceOrientation)orientation;

@end

@interface NSString (EqualNumber)
- (BOOL)isEqualToNumber:(NSNumber *)number;
@end

@interface NSNumber (EqualString)
- (BOOL)isEqualToString:(NSString *)aString;
@end

NS_ASSUME_NONNULL_END
