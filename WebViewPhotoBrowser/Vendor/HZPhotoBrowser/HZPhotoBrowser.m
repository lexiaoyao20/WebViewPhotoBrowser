//
//  HZPhotoBrowser.m
//  photoBrowser
//
//  Created by huangzhenyu on 15/6/23.
//  Copyright (c) 2015年 eamon. All rights reserved.
//

#import "HZPhotoBrowser.h"
#import "HZPhotoBrowserConfig.h"
#import "DDGifSupport.h"
#import <SDWebImage/SDImageCache.h>

@interface HZPhotoBrowser() <UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,assign) BOOL hasShowedPhotoBrowser;
@property (nonatomic,strong) UILabel *indexLabel;
@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic,strong) UIButton *saveButton;
@end

@implementation HZPhotoBrowser

- (void)loadView {
    // 隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.view = [[UIView alloc] init];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _hasShowedPhotoBrowser = NO;
    self.view.backgroundColor = kPhotoBrowserBackgrounColor;
    [self addScrollView];
    [self addToolbars];
    [self setUpFrames];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_hasShowedPhotoBrowser) {
        [self showPhotoBrowser];
    }
}

#pragma mark 重置各控件frame（处理屏幕旋转）
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self setUpFrames];
}

#pragma mark 设置各控件frame
- (void)setUpFrames
{
    CGRect rect = self.view.bounds;
    rect.size.width += kPhotoBrowserImageViewMargin * 2;
    _scrollView.bounds = rect;
    _scrollView.center = CGPointMake(kAPPWidth *0.5, kAppHeight *0.5);
    
    CGFloat y = 0;
    __block CGFloat w = kAPPWidth;
    CGFloat h = kAppHeight;
    
    //设置所有HZPhotoBrowserView的frame
    [_scrollView.subviews enumerateObjectsUsingBlock:^(HZPhotoBrowserView *obj, NSUInteger idx, BOOL *stop) {
        CGFloat x = kPhotoBrowserImageViewMargin + idx * (kPhotoBrowserImageViewMargin * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
    }];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.subviews.count * _scrollView.frame.size.width, kAppHeight);
    _scrollView.contentOffset = CGPointMake(self.currentImageIndex * _scrollView.frame.size.width, 0);
    
    _indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    _indexLabel.center = CGPointMake(kAPPWidth * 0.5, 30);
    _saveButton.frame = CGRectMake(30, kAppHeight - 70, 55, 30);
}

#pragma mark 显示图片浏览器
- (void)showPhotoBrowser
{
    UIView *sourceView = [self.delegate photoBrowser:self imageViewAtIndex:self.currentImageIndex];
    UIView *parentView = [self getParsentView:sourceView];
    CGRect rect = [sourceView.superview convertRect:sourceView.frame toView:parentView];
    if (!sourceView) {
        if ([self.delegate respondsToSelector:@selector(photoBrowser:imageRectAtIndex:)]) {
            rect = [self.delegate photoBrowser:self imageRectAtIndex:self.currentImageIndex];
        }else {
            rect = parentView.bounds;
        }
    }
    
    //如果是tableview，要减去偏移量
    if ([parentView isKindOfClass:[UITableView class]]) {
        UITableView *tableview = (UITableView *)parentView;
        rect.origin.y =  rect.origin.y - tableview.contentOffset.y;
    }
    
    UIImageView *tempImageView = [[UIImageView alloc] init];
    tempImageView.frame = rect;
    tempImageView.image = [self placeholderImageForIndex:self.currentImageIndex];
    [self.view addSubview:tempImageView];
    tempImageView.contentMode = UIViewContentModeScaleAspectFit;

    CGFloat placeImageSizeW = tempImageView.frame.size.width;
    CGFloat placeImageSizeH = tempImageView.frame.size.height;
    if (tempImageView.image) {
        placeImageSizeW = tempImageView.image.size.width;
        placeImageSizeH = tempImageView.image.size.height;
    }
    placeImageSizeW = placeImageSizeW == 0 ? kAPPWidth/3*2 : placeImageSizeW;
    placeImageSizeH = placeImageSizeH == 0 ? kAppHeight / 2 : placeImageSizeH;
    CGRect targetTemp;
    
    if (!kIsFullWidthForLandScape) {
        if (kAPPWidth < kAppHeight) {
            CGFloat placeHolderH = (placeImageSizeH * kAPPWidth)/placeImageSizeW;
            if (placeHolderH <= kAppHeight) {
                targetTemp = CGRectMake(0, (kAppHeight - placeHolderH) * 0.5 , kAPPWidth, placeHolderH);
            } else {
                targetTemp = CGRectMake(0, 0, kAPPWidth, placeHolderH);
            }
        } else {
            CGFloat placeHolderW = (placeImageSizeW * kAppHeight)/placeImageSizeH;
            if (placeHolderW < kAPPWidth) {
                targetTemp = CGRectMake((kAPPWidth - placeHolderW)*0.5, 0, placeHolderW, kAppHeight);
            } else {
                targetTemp = CGRectMake(0, 0, placeHolderW, kAppHeight);
            }
        }

    } else {
        CGFloat placeHolderH = (placeImageSizeH * kAPPWidth)/placeImageSizeW;

        if (placeHolderH <= kAppHeight) {
            targetTemp = CGRectMake(0, (kAppHeight - placeHolderH) * 0.5 , kAPPWidth, placeHolderH);
        } else {
            targetTemp = CGRectMake(0, 0, kAPPWidth, placeHolderH);
        }
    }
    
    _scrollView.hidden = YES;
    _indexLabel.hidden = YES;
    _saveButton.hidden = YES;

    [UIView animateWithDuration:kPhotoBrowserShowDuration animations:^{
        tempImageView.frame = targetTemp;
    } completion:^(BOOL finished) {
        _hasShowedPhotoBrowser = YES;
        [tempImageView removeFromSuperview];
        _scrollView.hidden = NO;
        _indexLabel.hidden = NO;
        _saveButton.hidden = NO;
    }];
}

#pragma mark 添加scrollview
- (void)addScrollView
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = self.view.bounds;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.hidden = YES;
    [self.view addSubview:_scrollView];
    
    for (int i = 0; i < self.imageCount; i++) {
        HZPhotoBrowserView *view = [[HZPhotoBrowserView alloc] init];
        view.imageview.tag = i;
        
        //处理单击
        __weak __typeof(self)weakSelf = self;
        view.singleTapBlock = ^(UITapGestureRecognizer *recognizer){
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf hidePhotoBrowser:recognizer];
        };
        
        [_scrollView addSubview:view];
    }
    [self setupImageOfImageViewForIndex:self.currentImageIndex];
}

#pragma mark 添加操作按钮
- (void)addToolbars
{
    //序标
    UILabel *indexLabel = [[UILabel alloc] init];
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont boldSystemFontOfSize:20];
    indexLabel.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
    indexLabel.bounds = CGRectMake(0, 0, 100, 40);
    indexLabel.center = CGPointMake(kAPPWidth * 0.5, 30);
    indexLabel.layer.cornerRadius = 15;
    indexLabel.clipsToBounds = YES;
 
    if (self.imageCount > 1) {
        indexLabel.text = [NSString stringWithFormat:@"1/%ld", (long)self.imageCount];
    }
    _indexLabel = indexLabel;
    [self.view addSubview:indexLabel];
    
    // 2.保存按钮
    UIButton *saveButton = [[UIButton alloc] init];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.layer.borderWidth = 0.1;
    saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
    saveButton.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
    saveButton.layer.cornerRadius = 2;
    saveButton.clipsToBounds = YES;
    [saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    _saveButton = saveButton;
    [self.view addSubview:saveButton];
}

#pragma mark 保存图像
- (void)saveImage
{
    int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    NSURL *imageURL = [self.delegate photoBrowser:self highQualityImageURLForIndex:index];
    HZPhotoBrowserView *currentView = _scrollView.subviews[index];
    
    if ([currentView.imageview.image isGif]) {
        NSString *imagePath = [[SDImageCache sharedImageCache] defaultCachePathForKey:imageURL.absoluteString];
        NSData *data = [imagePath gifData];
        [DDGifSupport saveGifData:data ?: currentView.imageview.image finished:^(NSError * _Nonnull error) {
            [self saveImageFinished:error];
        }];
    }else {
        UIImageWriteToSavedPhotosAlbum(currentView.imageview.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.view.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [self saveImageFinished:error];
}

- (void)saveImageFinished:(NSError *)error {
    [_indicatorView removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.50f];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.bounds = CGRectMake(0, 0, 150, 60);
    label.center = self.view.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:21];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    if (error) {
        label.text = @"保存失败";
    }   else {
        label.text = @"保存成功";
    }
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}

- (void)show
{
//    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:self animated:NO completion:nil];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
}

#pragma mark 单击隐藏图片浏览器
- (void)hidePhotoBrowser:(UITapGestureRecognizer *)recognizer
{
    _scrollView.hidden = YES;
    _indexLabel.hidden = YES;
    HZPhotoBrowserView *currentImageView = (HZPhotoBrowserView *)recognizer.view;
    
    UIView *sourceView = [self.delegate photoBrowser:self imageViewAtIndex:self.currentImageIndex];
    if (!sourceView) {
        [UIView animateWithDuration:kPhotoBrowserHideDuration animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
        return;
    }
    CGRect targetTemp = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self.view];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.image = currentImageView.imageview.image;
    CGFloat h = (self.view.bounds.size.width / currentImageView.imageview.image.size.width) * currentImageView.imageview.image.size.height;
    
    if (!currentImageView.imageview.image) { // 防止 因imageview的image加载失败 导致 崩溃
        h = self.view.bounds.size.height;
    }
    
    tempView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, h);
    tempView.center = self.view.center;
    
    [self.view addSubview:tempView];
    
    _saveButton.hidden = YES;
    
    [UIView animateWithDuration:kPhotoBrowserHideDuration animations:^{
        tempView.frame = targetTemp;
        self.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
    
//    HZPhotoBrowserView *view = (HZPhotoBrowserView *)recognizer.view;
//    UIImageView *currentImageView = view.imageview;
//    
//    UIView *sourceView = self.sourceImagesContainerView.subviews[self.currentImageIndex];
//    UIView *parentView = [self getParsentView:sourceView];
//    CGRect targetTemp = [sourceView.superview convertRect:sourceView.frame toView:parentView];
//    
//    // 减去偏移量
//    if ([parentView isKindOfClass:[UITableView class]]) {
//        UITableView *tableview = (UITableView *)parentView;
//        targetTemp.origin.y =  targetTemp.origin.y - tableview.contentOffset.y;
//    }
//    
//    CGFloat appWidth;
//    CGFloat appHeight;
//    if (kAPPWidth < kAppHeight) {
//        appWidth = kAPPWidth;
//        appHeight = kAppHeight;
//    } else {
//        appWidth = kAppHeight;
//        appHeight = kAPPWidth;
//    }
//    
//    UIImageView *tempImageView = [[UIImageView alloc] init];
//    tempImageView.image = currentImageView.image;
//    if (tempImageView.image) {
//        CGFloat tempImageSizeH = tempImageView.image.size.height;
//        CGFloat tempImageSizeW = tempImageView.image.size.width;
//        CGFloat tempImageViewH = (tempImageSizeH * appWidth)/tempImageSizeW;
//        if (tempImageViewH < appHeight) {
//            tempImageView.frame = CGRectMake(0, (appHeight - tempImageViewH)*0.5, appWidth, tempImageViewH);
//        } else {
//            tempImageView.frame = CGRectMake(0, 0, appWidth, tempImageViewH);
//        }
//    } else {
//        tempImageView.backgroundColor = [UIColor whiteColor];
//        tempImageView.frame = CGRectMake(0, (appHeight - appWidth)*0.5, appWidth, appWidth);
//    }
//    
//    [self.view.window addSubview:tempImageView];
//    
//    [self dismissViewControllerAnimated:NO completion:nil];
//    [UIView animateWithDuration:kPhotoBrowserHideDuration animations:^{
//        tempImageView.frame = targetTemp;
//        
//    } completion:^(BOOL finished) {
//        [tempImageView removeFromSuperview];
//    }];
}

#pragma mark 网络加载图片
- (void)setupImageOfImageViewForIndex:(NSInteger)index
{
    HZPhotoBrowserView *view = _scrollView.subviews[index];
    if (view.beginLoadingImage) return;
    if ([self highQualityImageURLForIndex:index]) {
        [view setImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
    } else {
        view.imageview.image = [self placeholderImageForIndex:index];
    }
    view.beginLoadingImage = YES;
}

#pragma mark 获取控制器的view
- (UIView *)getParsentView:(UIView *)view{
    if ([[view nextResponder] isKindOfClass:[UIViewController class]] || view == nil) {
        return view;
    }
    return [self getParsentView:view.superview];
}

#pragma mark 获取低分辨率（占位）图片
- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.delegate photoBrowser:self placeholderImageForIndex:index];
    }
    return nil;
}

#pragma mark 获取高分辨率图片url
- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageURLForIndex:index];
    }
    return nil;
}


#pragma mark - scrollview代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = (scrollView.contentOffset.x + _scrollView.bounds.size.width * 0.5) / _scrollView.bounds.size.width;
    
    _indexLabel.text = [NSString stringWithFormat:@"%d/%ld", index + 1, (long)self.imageCount];
    long left = index - 2;
    long right = index + 2;
    left = left>0?left : 0;
    right = right>self.imageCount?self.imageCount:right;
    
    //预加载三张图片
    for (long i = left; i < right; i++) {
        [self setupImageOfImageViewForIndex:i];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int autualIndex = scrollView.contentOffset.x  / _scrollView.bounds.size.width;
    //设置当前下标
    self.currentImageIndex = autualIndex;
    
    //将不是当前imageview的缩放全部还原 (这个方法有些冗余，后期可以改进)
    for (HZPhotoBrowserView *view in _scrollView.subviews) {
        if (view.imageview.tag != autualIndex) {
            view.scrollview.zoomScale = 1.0;
        }
    }
}

#pragma mark 横竖屏设置
- (BOOL)shouldAutorotate
{
    return shouldSupportLandscape;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (shouldSupportLandscape) {
        return UIInterfaceOrientationMaskAll;
    } else{
        return UIInterfaceOrientationMaskPortrait;
    }
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end
