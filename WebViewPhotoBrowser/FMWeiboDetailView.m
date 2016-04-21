//
//  FMWeiboDetailView.m
//  WebViewPhotoBrowser
//
//  Created by Subo on 16/4/21.
//  Copyright © 2016年 Followme. All rights reserved.
//

#import "FMWeiboDetailView.h"
#import "HZPhotoBrowser.h"
#import "UIWebView+FMAdd.h"
#import "UIView+FMAdd.h"

@interface FMWeiboDetailView ()<UIWebViewDelegate,UIGestureRecognizerDelegate,HZPhotoBrowserDelegate>

@property (strong, nonatomic) UIWebView *webView;

@property (nonatomic) CGRect currentImageFrame;
@property (copy, nonatomic) NSString *currentImageURL;

@end

@implementation FMWeiboDetailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _webView = [[UIWebView alloc] initWithFrame:self.bounds];
        _webView.delegate = self;
        _webView.scrollView.scrollEnabled = NO;
        _webView.scrollView.bounces = NO;
        _webView.scrollView.scrollsToTop = NO;
        _webView.scalesPageToFit = YES;
        _webView.allowsInlineMediaPlayback = YES;
        [self addSubview:_webView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tapGesture.delegate = self;
        [tapGesture setDelaysTouchesBegan:YES];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)loadContent:(NSString *)content {
    NSString *htmlString = [self htmlStringWithContent:content];
    
    [self.webView loadHTMLString:htmlString baseURL:nil];
}

- (NSString *)htmlStringWithContent:(NSString *)content {
    
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><meta name='viewport' content='width=device-width; \
                            initial-scale=1.0; maximum-scale=1.0;'><link rel='stylesheet' type='text/css' href='editor.css'></head>\
                            <body>%@</body></html>", content];
    
    return htmlString;
}

- (void)tap:(UITapGestureRecognizer *)tapGesture {
    
    CGPoint touchPoint = [tapGesture locationInView:self.webView];
    
    NSString *imageURLString = [self.webView fm_imageURLAtLocation:touchPoint];
    if (imageURLString) {
        self.currentImageFrame = [self.webView fm_imageFrameAtLocation:touchPoint];
        self.currentImageURL = imageURLString;
        
        HZPhotoBrowser *browserVc = [[HZPhotoBrowser alloc] init];
        browserVc.sourceImagesContainerView = self.webView; // 原图的父控件
        browserVc.imageCount = 1; // 图片总数
        browserVc.currentImageIndex = 0;
        browserVc.delegate = self;
        [browserVc show];
    }
}

#pragma mark - ......::::::: UIWebViewDelegate :::::::......

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    CGFloat contentHeight = [webView fm_contentHeight];
    
    self.webView.fm_top = 0;
    self.webView.fm_height = contentHeight;
    
    if (contentHeight > self.fm_height) {
        self.fm_height = contentHeight;
    }
    
    if ([self.delegate respondsToSelector:@selector(weiboDetailViewDidLoadFinished:)]) {
        [self.delegate weiboDetailViewDidLoadFinished:self];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked){
        
        NSURL *url = request.URL;
        NSLog(@"Click url:%@",url.absoluteString);
        
        //如果要自行处理链接，返回NO，再加上自己的处理逻辑
        //        return NO;
    }
    
    return YES;
}

#pragma mark - ......::::::: UIGestureRecognizerDelegate :::::::......

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        //webView加载过程中不响应tap手势
        if (self.webView.isLoading) {
            return NO;
        }
        
        return YES;
    }
    return NO;
}

//解决webView不影响Tap手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - ......::::::: photobrowser代理方法 :::::::......

//获取占位图
- (UIImage *)photoBrowser:(HZPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    
    return [self.webView fm_screenShotAtFrame:self.currentImageFrame];
}

//图片链接
- (NSURL *)photoBrowser:(HZPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    return [NSURL URLWithString:self.currentImageURL];
}

//image源视图，因为没有，所以返回nil
- (UIView *)photoBrowser:(HZPhotoBrowser *)browser imageViewAtIndex:(NSInteger)index {
    return nil;
}

//原图所在的frame - 返回居中的位置
- (CGRect)photoBrowser:(HZPhotoBrowser *)browser imageRectAtIndex:(NSInteger)index {
    CGFloat x = (CGRectGetWidth(self.window.frame) - CGRectGetWidth(self.currentImageFrame)) / 2.0;
    CGFloat y = (CGRectGetHeight(self.window.frame) - CGRectGetHeight(self.currentImageFrame)) / 2.0;
    return CGRectMake(x, y, self.currentImageFrame.size.width, self.currentImageFrame.size.height);
}


@end
