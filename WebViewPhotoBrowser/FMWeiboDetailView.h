//
//  FMWeiboDetailView.h
//  WebViewPhotoBrowser
//
//  Created by Subo on 16/4/21.
//  Copyright © 2016年 Followme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FMWeiboDetailViewDelegate;

//微博详情
@interface FMWeiboDetailView : UIView

@property (strong, nonatomic,readonly) UIWebView *webView;
@property (weak, nonatomic) id<FMWeiboDetailViewDelegate> delegate;

- (void)loadContent:(NSString *)content;

@end

@protocol FMWeiboDetailViewDelegate <NSObject>

- (void)weiboDetailViewDidLoadFinished:(FMWeiboDetailView *)weiboDetailView;

@end
