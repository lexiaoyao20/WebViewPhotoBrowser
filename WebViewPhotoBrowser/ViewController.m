//
//  ViewController.m
//  WebViewPhotoBrowser
//
//  Created by Subo on 16/4/21.
//  Copyright © 2016年 Followme. All rights reserved.
//

#import "ViewController.h"
#import "FMWeiboDetailView.h"

@interface ViewController ()<FMWeiboDetailViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) FMWeiboDetailView *weiboDetailView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    
    [self loadData];
}

- (void)prepareUI {
    self.title = @"UIWebView上的图片浏览器";
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    
    self.weiboDetailView = [[FMWeiboDetailView alloc] initWithFrame:self.scrollView.bounds];
    self.weiboDetailView.delegate = self;
    [self.scrollView addSubview:self.weiboDetailView];
}

- (void)loadData {
    NSString *content = @"<p>测试长微博</p><p><br/></p><p>表情： <img src=\"http://www.followme.com/Scripts/User/face/不屑.gif\"/>\
    <img src=\"http://www.followme.com/Scripts/User/face/鬼脸.gif\"/><img src=\"http://www.followme.com/Scripts/User/face/心碎.gif\"/>\
    </p><p><br/></p><p>图片：</p><p><img alt=\"aaa.gif\"  style=\"max-width:99%\" \
    src=\"http://file.followme.com/download.aspx?id=e46ba7a3-2c11-4568-a73b-c0aad26b7f5b&w=800&h=0&centerCut=0\" \
    title=\"aaa.gif\"/></p><p><br/></p><p><img alt=\"ssss.jpeg\"  style=\"max-width:99%\" src=\"http://file.followme.com/download.aspx?id=92a733ff-7aa0-4ff6-9012-91c72fd0d3ff&w=800&h=0&centerCut=0\" title=\"ssss.jpeg\"/></p>";
    
    [self.weiboDetailView loadContent:content];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ......::::::: FMWeiboDetailViewDelegate :::::::......

- (void)weiboDetailViewDidLoadFinished:(FMWeiboDetailView *)weiboDetailView {
    self.scrollView.contentSize = weiboDetailView.frame.size;
}

@end
