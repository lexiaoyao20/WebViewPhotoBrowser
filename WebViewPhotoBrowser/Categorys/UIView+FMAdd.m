//
//  UIView+FMAdd.m
//  WebViewPhotoBrowser
//
//  Created by Subo on 16/4/21.
//  Copyright © 2016年 Followme. All rights reserved.
//

#import "UIView+FMAdd.h"

@implementation UIView (FMScreenShots)

/**
 *  屏幕截图
 *
 *  @return
 */
- (UIImage *)fm_screenShot {
    return [self fm_screenShotAtFrame:self.bounds];
}

/**
 *  获取指定区域的屏幕截图
 *
 *  @param frame 指定区域
 *
 *  @return
 */
- (UIImage *)fm_screenShotAtFrame:(CGRect)frame {
    //for retina displays
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(frame.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(frame.size);
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, -frame.origin.x, -frame.origin.y);
    [self.layer renderInContext:ctx];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

@end

@implementation UIView (FMAdd)

- (CGSize)fm_size {
    return self.frame.size;
}

- (void)setFm_size:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGFloat)fm_width {
    return self.frame.size.width;
}

- (void)setFm_width:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)fm_height {
    return self.frame.size.height;
}

- (void)setFm_height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)fm_centerX {
    return self.center.x;
}

- (void)setFm_centerX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)fm_centerY {
    return self.center.y;
}

- (void)setFm_centerY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)fm_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setFm_bottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)fm_top {
    return self.frame.origin.y;
}

- (void)setFm_top:(CGFloat)top {
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}

@end
