//
//  ADWebViewController.h
//  QFCreater
//
//  Created by douglas on 2018/10/11.
//  Copyright © 2018 douglas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ADWebViewController : UIViewController
@property (nonatomic, copy) NSString *loadURL;
@property (nonatomic, strong) WKWebView *webView;
@end

NS_ASSUME_NONNULL_END
