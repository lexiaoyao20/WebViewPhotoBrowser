//
//  UIView+FMAdd.h
//  WebViewPhotoBrowser
//
//  Created by Subo on 16/4/21.
//  Copyright © 2016年 Followme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FMScreenShots)

/**
 *  屏幕截图
 *
 *  @return
 */
- (UIImage *)fm_screenShot;

/**
 *  获取指定区域的屏幕截图
 *
 *  @param frame 指定区域
 *
 *  @return
 */
- (UIImage *)fm_screenShotAtFrame:(CGRect)frame;


@end

@interface UIView (FMAdd)

@property (assign,nonatomic) CGSize  fm_size;
@property (assign,nonatomic) CGFloat fm_width;
@property (assign,nonatomic) CGFloat fm_height;
@property (assign,nonatomic) CGFloat fm_centerX;
@property (assign,nonatomic) CGFloat fm_centerY;
@property (assign,nonatomic) CGFloat fm_bottom;
@property (assign,nonatomic) CGFloat fm_top;

@end
