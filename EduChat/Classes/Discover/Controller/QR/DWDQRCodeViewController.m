//
//  DWDQRCodeViewController.m
//  EduChat
//
//  Created by apple  on 15/11/9.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDQRCodeViewController.h"
#import "DWDPersonDataViewController.h"
#import "DWDChatController.h"
#import "DWDCanYouJoinViewController.h"
#import "DWDSearchClassInfoViewController.h"

#import "DWDQRClient.h"
#import "DWDContactsDatabaseTool.h"
#import "DWDGroupClient.h"
#import "DWDClassModel.h"

#import "DWDClassDataBaseTool.h"

#import <AVFoundation/AVFoundation.h>
#import <YYModel/YYModel.h>


@interface DWDQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layer;
@property (weak, nonatomic) UIImageView *animationLine;
@property (strong, nonatomic) CAKeyframeAnimation *keyFrameAnimatio;
@end

@implementation DWDQRCodeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫一扫";
    
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_return_normal"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    
    [self setUpQRCodeInterface];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(albumButtonDidClick)];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.session startRunning];
     [self.animationLine.layer addAnimation:self.keyFrameAnimatio forKey:@"lineAnimation"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupQRUI
{
    // 设置扫描二维码界面
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, DWDScreenH)];
    imageView.image = [UIImage imageNamed:@"sweep"];
    
    UIImageView *animationLine = [[UIImageView alloc] initWithFrame:CGRectMake(pxToW(95), pxToH(180), pxToW(560), pxToH(14))];
    _animationLine = animationLine;
    animationLine.image = [UIImage imageNamed:@"scanning_line"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(pxToW(288), pxToH(840), 0, 0)];
    label.text = @"扫描二维码";
    label.textColor = DWDRGBColor(255, 255, 255);
    label.font = DWDFontBody;
    [label sizeToFit];
    
    [self.view addSubview:animationLine];
    [self.view addSubview:imageView];
    [self.view addSubview:label];
    
    
    CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animation];
    self.keyFrameAnimatio = keyFrameAnimation;
    keyFrameAnimation.keyPath = @"position";
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(animationLine.cenX, pxToH(200))];
    [path addLineToPoint:CGPointMake(animationLine.cenX, pxToH(800))];
    [path addLineToPoint:CGPointMake(animationLine.cenX, pxToH(200))];
    keyFrameAnimation.path = path.CGPath;
    
    keyFrameAnimation.removedOnCompletion = NO;
    keyFrameAnimation.fillMode = kCAFillModeForwards;
    keyFrameAnimation.duration = 6.0;
    keyFrameAnimation.repeatCount = MAXFLOAT;
    [animationLine.layer addAnimation:keyFrameAnimation forKey:@"lineAnimation"];
}


- (void)setUpQRCodeInterface{

    // 获取 AVCaptureDevice 实例
    NSError * error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 初始化输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:error.localizedFailureReason delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
     
        return;
      
    }
    // 创建会话
     _session = [[AVCaptureSession alloc] init];
    // 添加输入流
    [_session addInput:input];
    // 初始化输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [captureMetadataOutput setRectOfInterest:CGRectMake(pxToH(200) / DWDScreenH, pxToW(95) / DWDScreenW, pxToH(800) / DWDScreenH, pxToW(560) / DWDScreenW)];

    // 添加输出流
    [_session addOutput:captureMetadataOutput];
    
    // 创建dispatch queue.
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 设置元数据类型 AVMetadataObjectTypeQRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // 创建输出对象
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    layer.frame = self.view.bounds;
     [self.view.layer addSublayer:layer];
    // 开始会话
    [_session startRunning];
    //设置QR UI
    [self setupQRUI];

}

#pragma mark - 实现output的回调方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
        DWDLog(@"%@", object.stringValue);
        
        [self.session stopRunning];
        [self.animationLine.layer removeAnimationForKey:@"lineAnimation"];
        
        //请求
        [DWDQRClient requestAnalysisWithQRInfo:object.stringValue controller:self];
    } else {
        [DWDProgressHUD showText:@"未扫描到数据"];
    }
}

/* 注释掉先
#pragma mark - Request
- (void)requestDataWithInfo:(NSString *)info
{
    WEAKSELF;
    [[DWDQRClient sharedQRClient] requestAcctRestServiceGetQRInfoWithCustId:[DWDCustInfo shared].custId friendCustId:info success:^(id responObject) {
        //判断返回类型 1:联系人 2:群组 3:班级
        if ([responObject[@"friendType"] isEqualToNumber:@1]){//联系人
            
            DWDPersonDataViewController *vc = [[DWDPersonDataViewController alloc] init];
            if ([[DWDCustInfo shared].custId isEqualToNumber:responObject[@"friendCustId"]]) {
                vc.personType = DWDPersonTypeMySelf;
                vc.custId = responObject[@"friendCustId"];
            }else{
                vc.custId = responObject[@"friendCustId"];
                vc.sourceType = DWDSourceTypeQR;
            }
            [weakSelf.navigationController pushViewController:vc animated:NO                                                                                                                                                                                                                                                                                                                                                                                                                                                        ];
        }
        
        else if([responObject[@"friendType"] isEqualToNumber:@2]){//群组
            
            //是否为群成员
            if ([responObject[@"isFriend"] isEqualToNumber:@0]) {//非群成员
                
                DWDCanYouJoinViewController *vc = [[DWDCanYouJoinViewController alloc] initWithNibName:@"DWDCanYouJoinViewController" bundle:nil];
                vc.dictDataSource = responObject;
                [weakSelf.navigationController pushViewController:vc animated:NO];
                
            }else{//已是群成员，直接进入聊天界面
                
                DWDChatController *chatController = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
                
                chatController.chatType = DWDChatTypeGroup;
                chatController.title = responObject[@"groupName"];
                chatController.toUserId = responObject[@"groupId"];
                
                [weakSelf.navigationController pushViewController:chatController animated:NO];
                
            }
        }
        
        else if ([responObject[@"friendType"] isEqualToNumber:@3]){
            
            //是否为班级成员
            if([responObject[@"isFriend"] isEqualToNumber:@0]){//非班级成员
                
                DWDSearchClassInfoViewController *searchInfoVc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDSearchClassInfoViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDSearchClassInfoViewController class])];
                searchInfoVc.classModel = [DWDClassModel yy_modelWithDictionary:responObject];
                
                [self.navigationController pushViewController:searchInfoVc animated:YES];

                
            }else{
                
                DWDChatController *chatController = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
                
                chatController.chatType = DWDChatTypeClass;
                chatController.toUserId = responObject[@"classId"];
                
                //根据ClassId 从本地库获取班级信息
                DWDClassModel *model = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:responObject[@"classId"] myCustId:[DWDCustInfo shared].custId];
                chatController.myClass = model;
                
                [weakSelf.navigationController pushViewController:chatController animated:NO];
            }
        }
    } failure:^(NSError *error) {
       
        UIViewController *vc = [[UIViewController alloc] init];
        vc.title = @"扫描结果";
        UILabel *lab = [[UILabel alloc] init];
        lab.frame = CGRectMake(0, vc.view.cenY, vc.view.size.width, 21);
        lab.textAlignment = NSTextAlignmentCenter;
        lab.text = @"未扫描到数据";
        [vc.view addSubview:lab];
        [self.navigationController pushViewController:vc animated:NO];
    }];
}
*/

#pragma mark - Event Response

- (void)albumButtonDidClick {
    [[DWDPrivacyManager shareManger] needPrivacy:DWDPrivacyTypePhotoLibrary withController:self authorized:^{
        UIImagePickerController *imagePiker = [[UIImagePickerController alloc] init];
//        imagePiker.allowsEditing = YES;
        imagePiker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePiker.delegate = self;
        [self presentViewController:imagePiker animated:YES completion:nil];
    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSString *msg = [NSString messageWithImage:image];
    if (msg != nil) {
        [DWDQRClient requestAnalysisWithQRInfo:msg controller:self];
    }
}

@end
