//
//  DWDWebViewController.m
//  EduChat
//
//  Created by Catskiy on 2016/10/25.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDWebViewController.h"

@interface DWDWebViewController ()<UIWebViewDelegate>
{
    UILabel *_titleLabel;
    
    UIActivityIndicatorView *_activityView;
}
@end

@implementation DWDWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setNav];
    [self initViews];
}

-(void)setNav{
    
}

-(void)initViews{
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, DWDScreenH - DWDTopHight)];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]];
    [self.webView loadRequest:request];
    
    
    _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(DWDScreenW/2-15, (DWDScreenH - DWDTopHight)/2-15, 30, 30)];
    _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    _activityView.hidesWhenStopped = YES;
    [self.view addSubview:_activityView];
    [self.view bringSubviewToFront:_activityView];
}


#pragma mark - UIWebViewDelegate
-(void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"开始加载webview");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"加载webview完成");
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    _titleLabel.text = theTitle;
    [_activityView stopAnimating];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"加载webview失败");
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    [_activityView startAnimating];
    return YES;
}



@end
