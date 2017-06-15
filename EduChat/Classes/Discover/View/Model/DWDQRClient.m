//
//  DWDQRClient.m
//  EduChat
//
//  Created by Gatlin on 16/2/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDQRClient.h"
#import "DWDPersonDataViewController.h"
#import "DWDCanYouJoinViewController.h"
#import "DWDChatController.h"
#import "DWDSearchClassInfoViewController.h"

#import "DWDClassDataBaseTool.h"
#import "DWDGroupDataBaseTool.h"

#import <YYModel.h>
@implementation DWDQRClient

DWDSingletonM(QRClient)

- (void)requestAcctRestServiceGetQRInfoWithCustId:(NSNumber *)custId friendCustId:(NSString *)friendCustId success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    [[HttpClient sharedClient] getApi:@"AcctRestService/getQRInfo" params:@{DWDCustId:custId,@"friendCustId":friendCustId} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hide:YES];
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
       [hud hide:YES];
       failure(error); 
    }];

}

+ (void)requestAnalysisWithQRInfo:(NSString *)QRInfo controller:(UIViewController *)controller{
    //判断扫描是否为网址
    //正则匹配网址
    NSString *urlString = QRInfo;
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlPredic = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    BOOL isValidURL = [urlPredic evaluateWithObject:urlString];
    //判断是否为网址
    if(isValidURL){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:QRInfo]];
    }else{
        //调用服务接口
        DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:controller.view];
        [[HttpClient sharedClient] getApi:@"AcctRestService/getQRInfo" params:@{DWDCustId:[DWDCustInfo shared].custId,@"friendCustId":QRInfo} success:^(NSURLSessionDataTask *task, id responseObject) {
            [hud hideHud];
            
            NSDictionary *dict = responseObject[DWDApiDataKey];
            //判断返回类型 1:联系人 2:群组 3:班级
            if ([dict[@"friendType"] isEqualToNumber:@1]){//联系人
                DWDPersonDataViewController *vc = [[DWDPersonDataViewController alloc] init];
                if ([[DWDCustInfo shared].custId isEqualToNumber:dict[@"friendCustId"]]) {
                    vc.personType = DWDPersonTypeMySelf;
                    vc.custId = dict[@"friendCustId"];
                }else{
                    vc.custId = dict[@"friendCustId"];
                    vc.sourceType = DWDSourceTypeQR;
                }
                [controller.navigationController pushViewController:vc animated:NO                                                                                                                                                                                                                                                                                                                                                                                                                                                        ];
            }
            else if([dict[@"friendType"] isEqualToNumber:@2]){//群组
                DWDCanYouJoinViewController *vc = [[DWDCanYouJoinViewController alloc] initWithNibName:@"DWDCanYouJoinViewController" bundle:nil];
    
                if ([dict[@"isFriend"] isEqualToNumber:@0]) {//非群成员
                    vc.type = DWDSacnResultTypeApply;
                    vc.dictDataSource = dict;
                }else{
                    vc.type = DWDSacnResultTypeJionChat;
                    DWDGroupEntity *model = [[DWDGroupDataBaseTool sharedGroupDataBase] getGroupInfoWithMyCustId:[DWDCustInfo shared].custId groupId:dict[@"groupId"]];
                    vc.dictDataSource = [model yy_modelToJSONObject];
                }
                
                
                [controller.navigationController pushViewController:vc animated:NO];

            }
            
            else if ([dict[@"friendType"] isEqualToNumber:@3]){
                DWDSearchClassInfoViewController *searchInfoVc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDSearchClassInfoViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDSearchClassInfoViewController class])];
               
                
                if([dict[@"isFriend"] isEqualToNumber:@0]){//非班级成员
                    searchInfoVc.type = DWDSacnClassResultTypeApply;
                     searchInfoVc.classModel = [DWDClassModel yy_modelWithDictionary:dict];
                }else{
                     searchInfoVc.type = DWDSacnClassResultTypeJionChat;
                    searchInfoVc.classModel = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:dict[@"classId"] myCustId:[DWDCustInfo shared].custId];
                }
                [controller.navigationController pushViewController:searchInfoVc animated:NO];
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [hud hideHud];
            
            UIViewController *vc = [[UIViewController alloc] init];
            vc.title = @"扫描结果";
            UILabel *lab = [[UILabel alloc] init];
            lab.frame = CGRectMake(0, vc.view.cenY, vc.view.size.width, 21);
            lab.textAlignment = NSTextAlignmentCenter;
            lab.text = @"未扫描到数据";
            [vc.view addSubview:lab];
            [controller.navigationController pushViewController:vc animated:NO];
            
        }];

    }

    
}
@end
