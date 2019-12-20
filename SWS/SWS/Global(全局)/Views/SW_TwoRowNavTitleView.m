//
//  SW_TwoRowNavTitleView.m
//  SWS
//
//  Created by jayway on 2018/5/31.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

#import "SW_TwoRowNavTitleView.h"

@implementation SW_TwoRowNavTitleView

#pragma mark  初始化方法

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.width = 200;
        self.height = 44;
        self.numberOfLines = 2;
        self.textAlignment = NSTextAlignmentCenter;
    
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title detailTitle:(NSString *)detail {
    self = [super init];
    if (self) {
        _title = title;
        _detail = detail;
        [self setUpTitle];
    }
    
    return self;
}

+ (instancetype)titleViewWithTitle:(NSString *)title detailTitle:(NSString *)detail {
    return [[SW_TwoRowNavTitleView alloc] initWithTitle:title detailTitle:detail];
}

- (void)setUpTitle {
    NSString *prefix = self.title;
    NSString *name =self.detail;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:4];        //设置行间距
    [paragraphStyle setLineBreakMode:self.lineBreakMode];
    [paragraphStyle setAlignment:self.textAlignment];
    
    
    NSString *str = [NSString stringWithFormat:@"%@\n%@",prefix,name];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:str];
    
    [attrStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12.0] range:[str rangeOfString:prefix]];
    [attrStr addAttribute:NSForegroundColorAttributeName value:COLOR(51, 51, 51) range:[str rangeOfString:prefix]];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10.0] range:[str rangeOfString:name]];
    [attrStr addAttribute:NSForegroundColorAttributeName value:COLOR(153, 153, 153) range:[str rangeOfString:name]];
    
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
    self.attributedText = attrStr;
}

#pragma mark  setter方法
-(void)setTitle:(NSString *)title {
    _title = title;
    [self setUpTitle];
}

-(void)setDetail:(NSString *)detail {
    _detail = detail;
    [self setUpTitle];
}

@end
