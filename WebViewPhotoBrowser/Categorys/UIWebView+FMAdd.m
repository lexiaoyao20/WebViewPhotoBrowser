//
//  UIWebView+FMAdd.m
//  WebViewPhotoBrowser
//
//  Created by Subo on 16/4/21.
//  Copyright © 2016年 Followme. All rights reserved.
//

#import "UIWebView+FMAdd.h"
#import <objc/runtime.h>

@implementation UIWebView (FMAdd)

- (NSString *)fm_ignoredImageSymbols {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFm_ignoredImageSymbols:(NSArray *)ignoredImageSymbols {
    objc_setAssociatedObject(self,
                             @selector(fm_ignoredImageSymbols),
                             ignoredImageSymbols,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/**
 *  从WebView上的一个坐标返回图片的链接
 *
 *  @param location 坐标位置
 *
 *  @return 如果坐标处是图片就返回图片的url路径，否则，返回空
 */
- (NSString *)fm_imageURLAtLocation:(CGPoint)location {
    NSString *imageSRC = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", location.x, location.y];
    NSString *imageURLStr = [self stringByEvaluatingJavaScriptFromString:imageSRC];
    NSURL *imageURL = [NSURL URLWithString:imageURLStr];
    
    if (imageURL && imageURL.scheme && imageURL.host) {
        //过滤非法的图片链接
        for (NSString *ignoredSymbol in self.fm_ignoredImageSymbols) {
            if (ignoredSymbol.length > 0 && [imageURLStr containsString:ignoredSymbol]) {
                return nil;
            }
        }
    }
    
    return imageURLStr;
}

/**
 *  检测webView上的坐标位置是否含有图片
 *
 *  @param location 坐标位置
 *
 *  @return
 */
- (BOOL)fm_imageExistAtLocation:(CGPoint)location {
    NSString *imageURLStr = [self fm_imageURLAtLocation:location];
    
    return imageURLStr.length > 0;
}


/**
 *  从webView上的坐标取图片的frame
 *
 *  @param location webView上的坐标位置
 *
 *  @return 如果有就返回图片的frame，没有，则返回 CGRectZero
 */
- (CGRect)fm_imageFrameAtLocation:(CGPoint)location {
    //先检测图片是否存在
    if (![self fm_imageExistAtLocation:location]) {
        return CGRectZero;
    }
    
//    NSString *js = @"function f(){ var r = document.elementFromPoint(%f, %f).getBoundingClientRect(); \
//    return '{{'+r.left+','+r.top+'},{'+r.width+','+r.height+'}}'; } f();";
//    NSString *result = [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:js, location.x, location.y]];
//    CGRect rect = CGRectFromString(result);
//    
//    return rect;
    
    CGFloat left = [self fm_imageLeftFromLocation:location];
    CGFloat top = [self fm_imageTopFromLocation:location];
    CGFloat width = [self fm_imageWidthFromLocation:location];
    CGFloat height = [self fm_imageHeightFromLocation:location];
    
    return CGRectMake(left, top, width, height);
}

/**
 *  webView的内容高度
 *
 *  @return
 */
- (CGFloat)fm_contentHeight {
    CGFloat height = [[self stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
    
    return height;
}

/**
 *  webView的内容宽度
 *
 *  @return
 */
- (CGFloat)fm_contentWidth {
    CGFloat height = [[self stringByEvaluatingJavaScriptFromString:@"document.width"] floatValue];
    
    return height;
}

- (CGFloat)fm_imageTopFromLocation:(CGPoint)location {
    if (![self fm_imageExistAtLocation:location]) {
        return 0;
    }
    NSString *topDes = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).offsetTop", location.x, location.y];
    return [[self stringByEvaluatingJavaScriptFromString:topDes] floatValue];
}

- (CGFloat)fm_imageLeftFromLocation:(CGPoint)location {
    if (![self fm_imageExistAtLocation:location]) {
        return 0;
    }
    NSString *leftDes = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).offsetLeft", location.x, location.y];
    return [[self stringByEvaluatingJavaScriptFromString:leftDes] floatValue];
}

- (CGFloat)fm_imageWidthFromLocation:(CGPoint)location {
    if (![self fm_imageExistAtLocation:location]) {
        return 0;
    }
    NSString *wdithDes = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).clientWidth", location.x, location.y];
    return [[self stringByEvaluatingJavaScriptFromString:wdithDes] floatValue];
}

- (CGFloat)fm_imageHeightFromLocation:(CGPoint)location {
    if (![self fm_imageExistAtLocation:location]) {
        return 0;
    }
    NSString *heightDes = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).clientHeight", location.x, location.y];
    return [[self stringByEvaluatingJavaScriptFromString:heightDes] floatValue];
}

@end
