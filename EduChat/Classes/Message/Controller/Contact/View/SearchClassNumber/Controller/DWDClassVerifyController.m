//
//  DWDClassVerifyController.m
//  EduChat
//
//  Created by Superman on 16/2/22.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassVerifyController.h"
#import "DWDPlaceholderTextView.h"
#import "DWDClassModel.h"

@interface DWDClassVerifyController () <UITextViewDelegate>
@property (nonatomic , weak) DWDPlaceholderTextView *placeholderView;

@end

@implementation DWDClassVerifyController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"班级验证";
    self.view.backgroundColor = DWDRGBColor(242, 242, 242);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, pxToH(70))];
    label.text = @"你需要发送验证申请,等待对方通过";
    label.font = DWDFontContent;
    label.textColor = DWDRGBColor(136, 136, 136);
    [self.view addSubview:label];
    
    DWDPlaceholderTextView *placeholderView  = [[DWDPlaceholderTextView alloc] initWithFrame:CGRectMake(0, pxToH(70), DWDScreenW, pxToH(176))];
    _placeholderView = placeholderView;
    placeholderView.delegate = self;
    placeholderView.placeholder = @"请输入验证申请";
    
    
    [self.view addSubview:placeholderView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarBtnClick)];

}

- (void)rightBarBtnClick{
    // request
    /*
     custId	√	long	用户id
     classId	√	long	班级Id
     verifyInfo	√	String	验证信息
     */
    
    NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                             @"classId" : self.classModel.classId,
                             @"verifyInfo" : _placeholderView.text};
    [[HttpClient sharedClient] postApi:@"ClassVerifyRestService/addEntity" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DWDLog(@"%@'';';'; " , responseObject[@"data"]);
        
        [DWDProgressHUD showText:@"申请成功!"];
        
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDLog(@"%@.." , error);
        [DWDProgressHUD showText:@"申请失败!" afterDelay:1.0];
    }];
}

#pragma mark - <UITextViewDelegate>

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    [textView setNeedsDisplay];
    return YES;
}

@end
