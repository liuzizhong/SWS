//
//  UIButton+UIButtonImageWithLable.m
//  RESwitchExample
//
//  Created by bunsman on 13-11-20.
//  Copyright (c) 2013年 Bunsman. All rights reserved.
//

#import "UIButton+UIButtonImageWithLable.h"

@implementation UIButton (UIButtonImageWithLable)

- (void)resizeWithDistance:(int)distance offset:(CGFloat)offset state:(UIControlState)state {
    if (distance % 2) {
        distance ++;
    }
    if ([self respondsToSelector:@selector(setContentDistance:)]) {
        ((UDButton *)self).contentDistance = distance;
    }
    [self.imageView setContentMode:UIViewContentModeCenter];
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    NSString *title = [self titleForState:state?:UIControlStateNormal];
    UIImage *image = [self imageForState:state?:UIControlStateNormal];
//    CGSize titleSize = [title sizeWithFont:self.titleLabel.font];
    
    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];

    
    float y = titleSize.height + distance / 4.0f;
    UIEdgeInsets titleInset = UIEdgeInsetsMake(distance / 2.0f - y + offset, -image.size.width, -(image.size.height + titleSize.height), 0.0);
    UIEdgeInsets imageInset = UIEdgeInsetsMake(-distance / 2.0f - y + offset, (self.frame.size.width - image.size.width) / 2.0f, 0, (self.frame.size.width - image.size.width) / 2.0f);
    [self setTitleEdgeInsets:titleInset];
    [self setImageEdgeInsets:imageInset];
}

- (void)resizeWithDistance:(int)distance offset:(CGFloat)offset{
    [self resizeWithDistance:distance offset:offset state:UIControlStateNormal];
}

- (void)resizeWithDistance:(int)distance
{
    [self resizeWithDistance:distance offset:0];
}

@end

@implementation UDButton

- (void)resizeWithDistance:(int)distance offset:(CGFloat)offset{
    [super resizeWithDistance:distance offset:offset];
    self.contentDistance = distance;
    self.contentOffset = offset;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.contentDistance > 0) {
        [self resizeWithDistance:self.contentDistance];
    }
}

@end
