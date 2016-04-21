//
//  UIWebView+FMAdd.h
//  WebViewPhotoBrowser
//
//  Created by Subo on 16/4/21.
//  Copyright © 2016年 Followme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (FMAdd)

/**
 *  可以忽略的图片标志 - （如果需要某些图片不被检测，可以使用这个属性来过滤），默认为nil
 *  例如，我需要忽略百度的图片链接，只需设置这个属性的值为：@[@"baidu.com"] 即可,
 *  当然你也可以设置多个过滤条件
 */
@property (copy, nonatomic) NSArray *fm_ignoredImageSymbols;

/**
 *  从WebView上的一个坐标返回图片的链接
 *
 *  @param location webView上的坐标位置
 *
 *  @return 如果坐标处是图片就返回图片的url路径，否则，返回nil
 */
- (NSString *)fm_imageURLAtLocation:(CGPoint)location;

/**
 *  检测webView上的坐标位置是否含有图片
 *
 *  @param location 坐标位置
 *
 *  @return
 */
- (BOOL)fm_imageExistAtLocation:(CGPoint)location;

/**
 *  获取Webview上坐标位置元素的标签名称，如 <img>
 *
 *  @param location 坐标位置
 *
 *  @return
 */
- (NSString *)fm_tagNameAtLocation:(CGPoint)location;

/**
 *  从webView上的坐标取图片的frame
 *
 *  @param location webView上的坐标位置
 *
 *  @return 如果有就返回图片的frame，没有，则返回 CGRectZero
 */
- (CGRect)fm_imageFrameAtLocation:(CGPoint)location;


- (CGFloat)fm_imageLeftFromLocation:(CGPoint)location;
- (CGFloat)fm_imageTopFromLocation:(CGPoint)location;
- (CGFloat)fm_imageWidthFromLocation:(CGPoint)location;
- (CGFloat)fm_imageHeightFromLocation:(CGPoint)location;

/**
 *  webView的内容高度
 *
 *  @return
 */
- (CGFloat)fm_contentHeight;

/**
 *  webView的内容宽度
 *
 *  @return
 */
- (CGFloat)fm_contentWidth;

@end
