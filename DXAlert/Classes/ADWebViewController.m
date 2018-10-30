//
//  ADWebViewController.m
//  QFCreater
//
//  Created by douglas on 2018/10/11.
//  Copyright © 2018 douglas. All rights reserved.
//

#import "ADWebViewController.h"
#import "Masonry.h"
//#import "DXHelper.h"
#define ToolBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height + 44 - 20 + 6)
@interface ADWebViewController ()<WKNavigationDelegate,WKUIDelegate>
@property (nonatomic,strong) UIProgressView  * progressView;
@property (nonatomic, strong) UIView *toolBar;
@property (nonatomic, strong) NSMutableArray *WebViewArray;

@property (nonatomic, strong) UIButton *homeBtn;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *goBtn;
@property (nonatomic, strong) UIButton *refreashBtn;


@end

@implementation ADWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    // Do any additional setup after loading the view from its nib.
}
- (void)createUI {
    self.title = @"网页";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    self.view.autoresizesSubviews = NO;
    if ([self.webView isLoading]) {
        [self.webView stopLoading];
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[_loadURL componentsSeparatedByString:@" "] componentsJoinedByString:@""]]]];

    [self.view addSubview:self.progressView];
    [self.view addSubview:self.toolBar];
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(rectStatus.size.height));
        make.left.right.equalTo(self.view);
    }];
    [_toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(ToolBarHeight));
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(@(0));
        
    }];
    
}
// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
    
}
#pragma maek - UIWebViewDelegate
#pragma mark - wkWebView代理
-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

// 如果不添加这个，那么wkwebview跳转不了AppStore
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    
    
    NSString* reqUrl = navigationAction.request.URL.absoluteString;
    NSLog(@"load url : %@",reqUrl);
    if ([reqUrl.lowercaseString hasPrefix:@"itms"] || [reqUrl.lowercaseString rangeOfString:@"itunes.apple.com"].length > 0 ||[reqUrl hasPrefix:@"alipays://"] || [reqUrl hasPrefix:@"alipay://"] || [reqUrl hasPrefix:@"mqqapi://"] || [reqUrl hasPrefix:@"mqqapis://"] || [reqUrl hasPrefix:@"weixin://"] || [reqUrl hasPrefix:@"weixins://"] || [reqUrl hasPrefix:@"mqq://"] || [reqUrl hasPrefix:@"wechat://"]||[reqUrl hasPrefix:@"mqqwpa://"])  {
        
        BOOL bSucc = [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        
        if (!bSucc) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                           message:@"未检测到客户端，请安装后重试。"
                                                          delegate:self
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil];
            [alert show];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
    }else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }

}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
    
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                   message:@"加载失败,请稍后重试"
                                                  delegate:self
                                         cancelButtonTitle:@"确定"
                                         otherButtonTitles:nil];
    [alert show];

}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
   // [MBProgressHUD hideHUDForView:self.wWebView];
  //  NSLog(@"load finished : %@",self.loadUrl);
    [self refreshButtonsState];
}

-(void)btnClicked:(UIButton*)btn
{
    switch (btn.tag) {
        case 0:
            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[_loadURL componentsSeparatedByString:@" "] componentsJoinedByString:@""]]]];
            break;
        case 1:
            if (_webView.canGoBack) {
                [_webView goBack];
            }
            
            break;
        case 2:
            if (_webView.canGoForward) {
                [_webView goForward];
            }
            break;
        case 3:
            
            [_webView reload];
            break;
        default:
            break;
    }
}

-(void)refreshButtonsState
{
    _backBtn.enabled = _webView.canGoForward;
    _homeBtn.enabled = _webView.canGoBack;
    
    
}

#pragma mark - 懒加载
- (WKWebView *)webView {
    @synchronized(self){
        if (!_webView) {
            _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - ToolBarHeight)];
            _webView.navigationDelegate = self;
            _webView.UIDelegate = self;
            if (@available(iOS 9.0, *)) {
                [[_webView configuration] setWebsiteDataStore: [WKWebsiteDataStore defaultDataStore]];
            } else {
                // Fallback on earlier versions
            }

            [self.view addSubview:_webView];
             CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
            _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
            [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@(rectStatus.size.height));
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(@(-ToolBarHeight));
            
            }];
            
        }
        return _webView;
    }
}
- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
        _progressView.tintColor       = [UIColor blueColor];
        _progressView.trackTintColor  = [UIColor whiteColor];
        
    }
    return _progressView;
}
- (UIView *)toolBar {
    if (!_toolBar) {
        _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - ToolBarHeight, self.view.frame.size.width, ToolBarHeight)];

        _toolBar.backgroundColor = [UIColor clearColor];
        
        
        NSArray * arr =@[@"首页-2",@"返回-2",@"更多-2",@"刷新-2"];
        NSArray * selearr= @[@"首页",@"返回",@"更多",@"刷新"];
        UIButton *lastBtn = nil;
        for (int i =0 ;  i <4 ;i ++){
            UIButton * btn =[UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame =CGRectMake(self.view.frame.size.width/4 * i, 0 ,  self.view.frame.size.width/4,ToolBarHeight);
            btn.tag =i;
            [btn setImage:[UIImage imageNamed:selearr [i]] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:arr [i]] forState:UIControlStateDisabled];
           // btn.imageEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
            [_toolBar addSubview:btn];
            
            [self.WebViewArray addObject:btn];
            
            
            if (btn.tag ==1){
                _homeBtn =btn;
            }
            if ( btn.tag ==2) {
                _backBtn =btn;
            }
            
            btn.backgroundColor =[UIColor clearColor];
            
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@(0));
                make.width.equalTo(self->_toolBar).multipliedBy(0.25);
                if (lastBtn) {
                    make.left.equalTo(lastBtn.mas_right);
                }else {
                  make.left.equalTo(@(0));
                }
                
                make.bottom.equalTo(@(0));
                //make.left.equalTo(self->_toolBar.mas_width).multipliedBy(0.25 );
            }];
            lastBtn = btn;
        }
        [self refreshButtonsState];

    }
    return _toolBar;
}
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"拦截到提示");
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:@"确定"
                                         otherButtonTitles:nil];
    [alert show];

    completionHandler();
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return  UIStatusBarStyleDefault;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
