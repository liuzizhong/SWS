//
//  UIScrollView+Runtime.m
//  CloudOffice
//
//  Created by 江顺金 on 2017/6/7.
//  Copyright © 2017年 115.com. All rights reserved.
//

#import "UIScrollView+Runtime.h"
#import <objc/runtime.h>
#import "SWS-Swift.h"

@implementation UIView (ScrollToTop_Runtime)

/// 所有页面都自动添加滚动按钮

//+ (void)load {
//    Method ori_Method = class_getInstanceMethod([UIView class], @selector(didMoveToSuperview));
//
//    Method ud_Mothod = class_getInstanceMethod([UIView class], @selector(ud_didMoveToSuperview));
//
//    method_exchangeImplementations(ori_Method, ud_Mothod);
//}
//
//- (void)ud_didMoveToSuperview {
//    [self ud_didMoveToSuperview];
//
//    if (self.superview && ([self isMemberOfClass:[UITableView class]])) {
//        for (UIView *view in self.superview.subviews) {
//            if ([view isKindOfClass:[ScrollToTopButton class]]) {
//                return;
//            }
//        }
//        [[ScrollToTopButton alloc] initWithFrame:CGRectMake(self.width, self.height, 44, 44) scrollView:(UIScrollView *)self];
//    }
//}

@end
