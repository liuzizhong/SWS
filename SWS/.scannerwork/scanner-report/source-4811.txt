//
//  UIView+Additions.m
//  UDPhone
//
//  Created by strangeliu on 15/5/18.
//  Copyright (c) 2015年 115.com. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)

- (void)setOriginX:(CGFloat)originX {
    CGRect frame = self.frame;
    frame.origin.x = originX;
    self.frame = frame;
}

- (CGFloat)originX {
    return self.frame.origin.x;
}

- (void)setOriginY:(CGFloat)originY {
    CGRect frame = self.frame;
    frame.origin.y = originY;
    self.frame = frame;
}

- (CGFloat)originY {
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setCenterX:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)applyMotionEffect {
    UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    CGFloat depth = 15;
    effectX.maximumRelativeValue = @(depth);
    effectX.minimumRelativeValue = @(-depth);
    effectY.maximumRelativeValue = @(depth);
    effectY.minimumRelativeValue = @(-depth);
    
    [self addMotionEffect:effectX];
    [self addMotionEffect:effectY];
}

+ (UIView *)loadNibName:(NSString *)nibName owner:(id)owner{
    NSArray *items = [[NSBundle mainBundle] loadNibNamed:nibName owner:owner options:nil];
    for (UIView *item in items) {
        NSString *className = NSStringFromClass(item.class);
        if ([className isEqualToString:nibName]){
            return item;
        }else{
            NSString *moduleName = [[className componentsSeparatedByString:@"."] lastObject]; // swift className == module.className
            if ([moduleName isEqualToString:nibName]){
                return item;
            }
        }
    }
    return nil;
}

@end

@implementation UIDevice (WJ)
//调用私有方法实现
+ (void)setOrientation:(UIInterfaceOrientation)orientation {
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[self currentDevice]];
    int val = orientation;
    [invocation setArgument:&val atIndex:2];
    [invocation invoke];
}
@end

@implementation NSString (EqualNumber)

- (BOOL)isEqualToNumber:(NSNumber *)number {
    if ([number isKindOfClass:[NSNumber class]]) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *thisNumber = [f numberFromString:self];
        if (thisNumber) {
            return [thisNumber isEqualToNumber:number];
        }
    }
    return NO;
}

@end

@implementation NSNumber (EqualString)
- (BOOL)isEqualToString:(NSString *)aString {
    if ([aString isKindOfClass:[NSString class]]) {
        NSString *thisString = [NSString stringWithFormat:@"%@", self];
        return [thisString isEqualToString:aString];
    }
    return NO;
}
@end

