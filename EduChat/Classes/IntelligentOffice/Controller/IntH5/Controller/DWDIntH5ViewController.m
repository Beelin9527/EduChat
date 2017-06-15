//
//  DWDIntH5ViewController.m
//  EduChat
//
//  Created by Catskiy on 2016/12/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntH5ViewController.h"
#import "DWDPUCLoadingView.h"
#import "DWDIntH5Model.h"

#import "DWDIntFunctionItemCell.h"
#import "DWDOfficeHeaderInfoTableViewCell.h"

#import "DWDIntelligenceMenuModel.h"
#import "DWDSchoolModel.h"

#import "DWDIntelligentOfficeDataHandler.h"

#import <Masonry.h>

#import "DWDKeyChainTool.h"
#import "DWDIntelligenceMenuDatabaseTool.h"

#import "DWDClassModel.h"

#import "DWDRSAHandler.h"
#import "DWDKeyChainTool.h"

#import "DWDPrivacyManager.h"
#import <CoreLocation/CoreLocation.h>
#import <WebKit/WebKit.h>
#import <SDVersion.h>

static NSString *const kSuccessStatusCode = @"1";
static NSString *const kFailureStatusCode = @"-1";

@interface DWDIntH5ViewController ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, CLLocationManagerDelegate>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) CLLocationManager *mgr;

@property (nonatomic, strong) NSTimer *timeOutTimer;
@property (nonatomic, assign) BOOL timeOut;

@property (nonatomic, assign) BOOL originNavigationBarHidden;

@property (nonatomic, strong) MBProgressHUD *loadingHud;

@property (nonatomic, strong) NSMutableURLRequest *mutableRequest;

@end

@implementation DWDIntH5ViewController

static NSString *positionErrorPermissionDenied = @"{'code':1, 'PERMISSION_DENIED':1}";

static NSString *positionErrorUnavailable = @"{'code':2, 'POSITION_UNAVAILABLE':2}";

static NSString *positionErrorTimeOut = @"{'code':3, 'TIMEOUT':3}";




- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = DWDColorBackgroud;

    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initWebView];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _originNavigationBarHidden = self.navigationController.navigationBar.hidden;
    [[self.navigationController navigationBar] setHidden:YES];
    //    //清除缓存
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[self.navigationController navigationBar] setHidden:_originNavigationBarHidden];
}

#pragma mark - initWithWebView
- (void)initWebView {
    
    if (iOSVersionGreaterThanOrEqualTo(@"9.0")) {
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        //// Date from
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        //// Execute
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{}];
    } else {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSError *errors;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
        
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [storage cookies])
        {
            [storage deleteCookie:cookie];
        }
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSURL* libraryURL = [fileManager URLForDirectory:NSLibraryDirectory
                                                inDomain:NSUserDomainMask
                                       appropriateForURL:NULL
                                                  create:NO
                                                   error:NULL];
        NSURL* cookiesURL = [libraryURL URLByAppendingPathComponent:@"Cookies"
                                                        isDirectory:YES];
        [fileManager removeItemAtURL:cookiesURL error:nil];
        
        NSURL* webKitDataURL = [libraryURL URLByAppendingPathComponent:@"WebKit" isDirectory:YES];
        NSURL* websiteDataURL = [webKitDataURL URLByAppendingPathComponent:@"WebsiteData" isDirectory:YES];
        
        NSURL* localStorageURL = [websiteDataURL URLByAppendingPathComponent:@"LocalStorage" isDirectory:YES];
        NSURL* webSQLStorageURL = [websiteDataURL URLByAppendingPathComponent:@"WebSQL" isDirectory:YES];
        NSURL* indexedDBStorageURL = [websiteDataURL URLByAppendingPathComponent:@"IndexedDB" isDirectory:YES];
        NSURL* mediaKeyStorageURL = [websiteDataURL URLByAppendingPathComponent:@"MediaKeys" isDirectory:YES];
        
        [fileManager removeItemAtURL:localStorageURL error:nil];
        [fileManager removeItemAtURL:webSQLStorageURL error:nil];
        [fileManager removeItemAtURL:indexedDBStorageURL error:nil];
        [fileManager removeItemAtURL:mediaKeyStorageURL error:nil];
    }

    //初始化WKWebView
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    config.userContentController = [WKUserContentController new];
    [config.userContentController addScriptMessageHandler:self name:@"getLocationFromiOS"];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, DWDScreenH) configuration:config];
    webView.backgroundColor = [UIColor clearColor];
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    webView.scrollView.bounces = NO;
    webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    webView.scrollView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:webView];
    _webView = webView;

    
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"正在加载";
        _loadingHud = hud;
    });

    if(self.url){
        [self setupRequestHeaderWithUrl:self.url];
        [webView loadRequest:self.mutableRequest];
    }else{
        WEAKSELF;
        NSDictionary *dic = @{@"cid":[DWDCustInfo shared].custId,@"mncd":_mCode};
        [[DWDWebManager sharedManager] getClassMenuH5WithParams:dic success:^(NSURLSessionDataTask *task, id responseObject) {
            NSString *urlData = responseObject[@"data"][@"url"];
            
            //test
            // NSString *url = @"https://service.dwd-sj.com:8085/short/html/_location_demo.html";
            //         NSString *url = @"http://192.168.10.106:8080/short/html/token.html";
            //        NSString *url = @"http://192.168.10.106:8086/short/html/mobileoffice/apply/index.html";
            
            [self setupRequestHeaderWithUrl:urlData];
            [webView loadRequest:self.mutableRequest];
            
            //本地测试加载html
            //        NSString *path = [[NSBundle mainBundle] pathForResource:@"token" ofType:@"html"];
            //        NSURL *url1 = [NSURL fileURLWithPath:path];
            //        [webView loadFileURL:url1 allowingReadAccessToURL:url1];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.loadingHud hide:YES];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    DWDLog(@"%s", __func__);
    if ([[[[navigationAction request] URL] absoluteString] containsString:@"backToHomePage"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if([[[[navigationAction request] URL] absoluteString] containsString:@"getRefreshToken"])
    {
        decisionHandler(WKNavigationActionPolicyCancel);
        [self getRequestToken];
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    DWDLog(@"%s", __func__);
    decisionHandler(WKNavigationResponsePolicyAllow);
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [_loadingHud hide:YES];
    DWDLog(@"%s", __func__);
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [_loadingHud hide:YES];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)cancelLocationRequest {
    _timeOut = YES;
    [_mgr stopUpdatingLocation];
    [_webView evaluateJavaScript:[NSString stringWithFormat:@"dwd_geolocationErrorHandler(%@)", positionErrorTimeOut] completionHandler:nil];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([message.name isEqualToString:@"getLocationFromiOS"]) {
        
        NSDictionary *params = message.body;
        long long timeOut = [params[@"timeout"] longLongValue] / 1000.0f;
//        long long timeOut = 1.0f;
        BOOL highAccuracy = [params[@"enableHighAccuracy"] boolValue];
//        int maximumAge = [params[@"maximumAge"] intValue];
        CLLocationManager *manager = [[CLLocationManager alloc] init];
        manager.delegate = self;
        manager.desiredAccuracy = highAccuracy ? kCLLocationAccuracyBest : kCLLocationAccuracyHundredMeters;
        manager.distanceFilter = 5.0;
        _mgr = manager;
        _timeOut = NO;
        
//        [_timeOutTimer performSelector:@selector(cancelLocationRequest) withObject:nil afterDelay:timeOut];
        // start request location
            [self.mgr requestLocation];
        
        // time out start
        _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:timeOut target:self selector:@selector(cancelLocationRequest) userInfo:nil repeats:NO];
    }
    DWDLog(@"%s", __func__);
}

#pragma mark - Private Method
/** 
 设置请求头
 */
- (void)setupRequestHeaderWithUrl:(NSString *)url{
    //参数sid uid token
    NSString *string1 = [NSString stringWithFormat:@"%@", [[DWDKeyChainTool sharedManager] readKeyWithType:KeyChainTypeToken]];
    NSString *string2 = [NSString stringWithFormat:@"%@", [DWDCustInfo shared].custId];
    NSString *string3 = [NSString stringWithFormat:@"%@", self.schoolId];
    
    //把参数添加到'请求头'里面
    self.mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    //        [mutableRequest setHTTPShouldHandleCookies:NO];
    [self.mutableRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [self.mutableRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [self.mutableRequest addValue:string3 forHTTPHeaderField:@"sid"];
    [self.mutableRequest addValue:string2 forHTTPHeaderField:@"uid"];
    [self.mutableRequest addValue:string1 forHTTPHeaderField:@"token"];
}

#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [_timeOutTimer invalidate];
    if (_timeOut == NO) {
        [self.mgr stopUpdatingLocation];
        CLLocation *lastLocatin = [locations lastObject];
        CLLocationCoordinate2D coordinate = lastLocatin.coordinate;
        
        [_webView evaluateJavaScript:[NSString stringWithFormat:@"dwd_geolocationSuccessHandler({'coords':{'latitude':%f, 'longitude':%f}})", coordinate.latitude, coordinate.longitude] completionHandler:nil];
//                [_webView evaluateJavaScript:[NSString stringWithFormat:@"dwd_geolocationErrorHandler({'code' : %d})", 3] completionHandler:nil];
//            [_webView evaluateJavaScript:[NSString stringWithFormat:@"geolocationErrorHandler({'code' : %d})", 1] completionHandler:nil];
    } else {
        [_webView evaluateJavaScript:[NSString stringWithFormat:@"dwd_geolocationErrorHandler(%@)", positionErrorUnavailable] completionHandler:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusNotDetermined) {
        [self.mgr requestWhenInUseAuthorization];
    } else if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_webView evaluateJavaScript:[NSString stringWithFormat:@"dwd_geolocationErrorHandler(%@)", positionErrorPermissionDenied] completionHandler:nil];
            [[DWDPrivacyManager shareManger] showAlertViewWithType:DWDPrivacyTypeLocation viewController:self];
        });
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.mgr requestLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.mgr stopUpdatingLocation];
    [_timeOutTimer invalidate];
    [_webView evaluateJavaScript:[NSString stringWithFormat:@"dwd_geolocationErrorHandler(%@)", positionErrorUnavailable] completionHandler:nil];
}

//获取最新的Token
- (void)getRequestToken
{
    //从本地获取refreshToken
    NSString *refreshToken = [[DWDKeyChainTool sharedManager] readKeyWithType:KeyChainTypeRefreshToken];
    if (!refreshToken) return;
    
    [[HttpClient sharedClient] getApi:@"token/refreshToken" params:@{@"token": refreshToken} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DWDLog(@"responseObject = %@", responseObject);
        
        //判断是否result = 1,重新保存token与refreshToken
        if ( [kSuccessStatusCode isEqual:responseObject[@"result"]])
        {
            //1.获取accessToken与存储
            NSString *token = responseObject[DWDApiDataKey][@"accessToken"];
            [[DWDKeyChainTool sharedManager] writeKey:token
                                             WithType:KeyChainTypeToken];
            
            //2.获取refreshToken与存储
            NSString *refreshToken = responseObject[DWDApiDataKey][@"refreshToken"];
            [[DWDKeyChainTool sharedManager] writeKey:refreshToken
                                             WithType:KeyChainTypeRefreshToken];
            
            //3.token加密
            NSData *tokenData = [token dataUsingEncoding:NSUTF8StringEncoding];
            NSString *encryptToken = [[DWDRSAHandler sharedHandler] encryptPublicKeyWithInfoData:tokenData];
            
            //4.从本地获取缓存请求头信息
            NSMutableDictionary *requestHeaderInfo = [[[NSUserDefaults standardUserDefaults] objectForKey:kDWDRequestHeaderInfoCache] mutableCopy];
            [requestHeaderInfo setValue:encryptToken forKey:@"encryptToken"];
            
            [[NSUserDefaults standardUserDefaults] setObject:requestHeaderInfo forKey:kDWDRequestHeaderInfoCache];
            
            //5.把callbackTokenToH5()传给js
            [self.webView evaluateJavaScript:[NSString stringWithFormat:@"callbackTokenToH5({'result':1, 'token':'%@'})",token] completionHandler:nil];
            
            
        }else{
            //5.把callbackTokenToH5()传给js
            [self.webView evaluateJavaScript:[NSString stringWithFormat:@"callbackTokenToH5({'result':-1, 'token':''})"] completionHandler:nil];

        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //5.把callbackTokenToH5()传给js
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"callbackTokenToH5({'result':-1, 'token':''})"] completionHandler:nil];
    }];
}

@end


