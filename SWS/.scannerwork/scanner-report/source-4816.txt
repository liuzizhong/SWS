//
//  MBProgressHUD+Utility.h
//  115
//
//  Created by Cyril Hu on 14-6-7.
//  Copyright (c) 2014年 115. All rights reserved.
//

#import "MBProgressHUD.h"

extern UIImage *kMBProgressHUDImageSuccess; // √
extern UIImage *kMBProgressHUDImageFail;    // X
extern UIImage *kMBProgressHUDImageWarning; // !

/** 显示提醒
 只会显示一个提醒，显示新提醒时，上一个会自动移除。
 text 支持换行显示，title不支持。
 */
@interface MBProgressHUD (Utility)

/** 显示文字提醒，1.5s 后自动消失，text 过长时支持换行显示 */
+ (void)showText:(NSString *)text;
+ (void)showText:(NSString *)text title:(NSString *)title;

/** 显示图片，显示大小即图片实际尺寸，1.0s 后自动消失，text 过长时支持换行显示 */
+ (void)showSuccessImage:(NSString *)text;
+ (void)showFailImage:(NSString *)text;
+ (void)showWarningImage:(NSString *)text;
+ (void)showWarningImageOnWindow:(NSString*)text;
+ (void)showImage:(UIImage *)image text:(NSString *)text;
+ (void)showImage:(UIImage *)image text:(NSString *)text title:(NSString *)title;
- (void)showImage:(UIImage*)image text:(NSString*)text title:(NSString*)title;

/** 显示动态图片 */
+ (void)showGIFView:(UIImageView *)imageView text:(NSString *)text;
- (void)showGIFView:(UIImageView *)imageView text:(NSString *)text;

/** 马上隐藏所有提醒 */
+ (void)hide;

/** 延迟隐藏所有提醒 */
+ (void)hideAfterDelay:(NSTimeInterval)delay;

@end
