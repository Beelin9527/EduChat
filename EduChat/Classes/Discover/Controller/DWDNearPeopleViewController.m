//
//  DWDNearPeopleViewController.m
//  EduChat
//
//  Created by apple  on 15/11/9.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "DWDNearPeopleViewController.h"
#import "DWDPersonDataViewController.h"
#import "DWDChatController.h"

#import "DWDNearPeopleCell.h"
#import "DWDNewFriendsListCell.h"
#import "DWDFriendApplyEntity.h"

#import "DWDNearPeopleModel.h"

#import "DWDFriendApplyDataBaseTool.h"
#import "DWDFriendVerifyClient.h"
#import <MBProgressHUD.h>
#import <YYModel.h>

typedef NS_ENUM(NSUInteger , DWDNearPeopleViewControllerNearPeopleType){
    DWDNearPeopleViewControllerNearPeopleTypeAll = 1,
    DWDNearPeopleViewControllerNearPeopleTypeMySchool,
    DWDNearPeopleViewControllerNearPeopleTypeMyClass,
    DWDNearPeopleViewControllerNearPeopleTypeHelloToMe
};

@interface DWDNearPeopleViewController () <CLLocationManagerDelegate , DWDNewFriendsListCellDelegate>
@property (nonatomic , strong) MBProgressHUD *hud;

@property (nonatomic , strong) CLLocationManager *mgr;
@property (nonatomic , copy) NSString *lastLoc;

@property (nonatomic , strong) NSMutableArray *nearPeoples;
@property (nonatomic , assign) BOOL isLocated;              //标记是否已经定位,避免短时间内多次更新位置导致重复请求

@end

@implementation DWDNearPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _lastLoc = @"nothing";
    
    self.title = NSLocalizedString(@"NearingPeople", nil);
    self.tableView.rowHeight = pxToH(140);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 0)];
    [self.mgr startUpdatingLocation];
    [self setUpRightBarBtnItem];
}

- (NSMutableArray *)nearPeoples{
    if (!_nearPeoples) {
        _nearPeoples = [NSMutableArray array];
    }
    return _nearPeoples;
}

- (CLLocationManager *)mgr{
    if (!_mgr) {
        _mgr = [[CLLocationManager alloc] init];
        _mgr.delegate = self;
        _mgr.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _mgr.distanceFilter = 5.0;
    }
    return _mgr;
}


- (void)seeNearPeopleWithType:(DWDNearPeopleViewControllerNearPeopleType)nearpeopleType{
    [self.nearPeoples removeAllObjects];
    
    if (nearpeopleType == DWDNearPeopleViewControllerNearPeopleTypeHelloToMe) {
        NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                                 @"source" : @5};
        [[HttpClient sharedClient] getApi:@"FriendVerifyRestService/getList2" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
            DWDLog(@".-.-.-.-.-.-.-.-.-.-.-.-.查看向我打招呼的人 : %@" , responseObject[@"data"]);
            
            NSArray *peoples = [NSArray yy_modelArrayWithClass:[DWDFriendApplyEntity class] json:responseObject[@"data"]];
            
            [self.nearPeoples addObjectsFromArray:peoples];
            
            [self.tableView reloadData];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }else{
        NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                                 @"loc" : _lastLoc,
                                 @"viewType" : @(nearpeopleType)};
        [[HttpClient sharedClient] getApi:@"LocationRestService/getNearing" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
            DWDLog(@".-.-.-.-.-.-.-.-.-.-.-.-.%@" , responseObject[@"data"]);
            
            NSArray *datas = responseObject[@"data"];
            for (int i = 0; i < datas.count; i++) {
                DWDNearPeopleModel *nearPeople = [DWDNearPeopleModel yy_modelWithJSON:datas[i]];
                
                if ([nearPeople.userId isEqual:[DWDCustInfo shared].custId]) {
                    continue;
                }
                
                [self.nearPeoples addObject:nearPeople];
            }
            [_hud show:YES];
            _hud.mode = MBProgressHUDModeText;
            _hud.labelText = @"获取附近的人成功";
            [_hud hide:YES afterDelay:1.0];
            [self.tableView reloadData];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DWDLog(@"error:%@",error);
            _hud.mode = MBProgressHUDModeText;
            _hud.labelText = @"网络错误,请重试";
            [_hud hide:YES afterDelay:1.0];
            [self.tableView reloadData];
        }];
    }
    
}

#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [self.mgr stopUpdatingLocation];
    CLLocation *lastLocatin = [locations lastObject];
    CLLocationCoordinate2D coordinate = lastLocatin.coordinate;
    NSString *latitude = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",coordinate.longitude];
    NSString *loc = [NSString stringWithFormat:@"%@,%@",longitude,latitude];  // 拼接经纬度字符串
    
    _lastLoc = loc;
    
    // 第一次更新位置
    if (!_isLocated) {
        
        [self seeNearPeopleWithType:DWDNearPeopleViewControllerNearPeopleTypeAll];
        _isLocated = YES;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _hud.mode = MBProgressHUDModeText;
        _hud.labelText = @"定位成功!";
        [_hud hide:YES afterDelay:1.0];
    });
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusNotDetermined) {
        [self.mgr requestWhenInUseAuthorization];
    } else if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[DWDPrivacyManager shareManger] showAlertViewWithType:DWDPrivacyTypeLocation viewController:self];
        });
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.labelText = @"正在定位当前位置,请稍候...";
        _hud.animationType = MBProgressHUDAnimationZoomOut;
        [_hud show:YES];
        [self.mgr startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _hud.mode = MBProgressHUDModeText;
        _hud.labelText = @"定位错误,请重试";
        [_hud hide:YES];
    });
    
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.nearPeoples.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([[self.nearPeoples firstObject] isKindOfClass:[DWDFriendApplyEntity class]]) {
        static NSString *ID = @"helloMeCell";
        DWDNewFriendsListCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"DWDNewFriendsListCell" owner:nil options:nil].lastObject;
        }
        DWDFriendApplyEntity *entity = self.nearPeoples[indexPath.row];
        cell.entity = entity;
        cell.delegate = self;
        return cell;
    }else{
        DWDNearPeopleModel *nearPeople = self.nearPeoples[indexPath.row];
        
        DWDNearPeopleCell *cell = [DWDNearPeopleCell cellWithTableView:tableView];
        cell.nearPeople = nearPeople;
        return cell;
    }
    
}

#pragma mark - <DWDNewFriendsListCellDelegate>
- (void)newfriendsListCell:(DWDNewFriendsListCell *)newfriendsListCell didSelectAcceptButtonOfFriendEntity:(DWDFriendApplyEntity *)entity{
    
    DWDRecentChatModel *recentChat = [[DWDRecentChatModel alloc] init];
    recentChat.myCustId = [DWDCustInfo shared].custId;
    recentChat.custId = entity.friendCustId;
    recentChat.photoKey = entity.photoKey;
    recentChat.lastContent = entity.verifyInfo;
    recentChat.nickname = entity.friendNickname;
    recentChat.lastCreatTime = entity.addTime;
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    
    __weak typeof(self) weakSelf = self;
    // 上传新加的好友到服务器
    [[DWDFriendVerifyClient sharedFriendVerifyClient] updateFirendVerifyState:[DWDCustInfo shared].custId friendId:entity.friendCustId state:@1 success:^(NSArray *info) {
        
        [hud hide:YES];
        
        //发通知，上传新添加的好友到服务器保存 , 再刷新本地数据库
         [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationContactUpdate object:nil];
        //刷新会话列表
//        NSDictionary *dict = @{@"recentChat" : recentChat};
        //发送通知、是否刷新 会话列表
        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@(YES)}];
        
        //进入聊天控制器
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil];
            DWDChatController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
            vc.chatType = DWDChatTypeFace;
            vc.toUserId = entity.friendCustId;
            vc.recentChatModel = recentChat;
            [weakSelf.navigationController pushViewController:vc animated:YES];
            
        });
        //刷新本地库好友状态
        [[DWDFriendApplyDataBaseTool sharedFriendApplyDataBase] updateWithStatus:@1 MyCustId:[DWDCustInfo shared].custId friendCustId:entity.friendCustId];
    } failure:^(NSError *error) {
        
        [hud showText:@"请求失败"];
        
    }];
}

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.nearPeoples[indexPath.row] isKindOfClass:[DWDFriendApplyEntity class]]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        
        DWDFriendApplyEntity *entity = self.nearPeoples[indexPath.row];
        
        DWDRecentChatModel *recentChat = [[DWDRecentChatModel alloc] init];
        recentChat.myCustId = [DWDCustInfo shared].custId;
        recentChat.custId = entity.friendCustId;
        recentChat.photoKey = entity.photoKey;
        recentChat.lastContent = entity.verifyInfo;
        recentChat.nickname = entity.friendNickname;
        recentChat.lastCreatTime = entity.addTime;
        
        
        DWDPersonDataViewController *vc = [[DWDPersonDataViewController alloc] init];
        if ([entity.status isEqualToNumber:@0]) {
            
            vc.personType = DWDPersonTypeIsStrangerApply;
            vc.custId = entity.friendCustId;
            vc.recentChatModel = recentChat;
            
        }else{
            
            vc.personType = DWDPersonTypeIsFriend;
            vc.custId = entity.friendCustId;
            
        }
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        DWDNearPeopleModel *nearPeople = self.nearPeoples[indexPath.row];
        
        DWDPersonDataViewController *userDetailVc = [[DWDPersonDataViewController alloc] init];
        userDetailVc.custId = nearPeople.userId;
        
        [self.navigationController pushViewController:userDetailVc animated:YES];
    }
    
}

- (void)setUpRightBarBtnItem{
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarItemClick)];
    self.navigationItem.rightBarButtonItem = barBtn;
}

- (void)rightBarItemClick{
//    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertController *alertVc = [[UIAlertController alloc] init];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"只看全部" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        DWDLog(@"点击了只看全部");
        [self seeNearPeopleWithType:DWDNearPeopleViewControllerNearPeopleTypeAll];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"只看本校" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        DWDLog(@"点击了只看本校");
        [self seeNearPeopleWithType:DWDNearPeopleViewControllerNearPeopleTypeMySchool];
    }];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"只看本班" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        DWDLog(@"点击了只看本班");
        [self seeNearPeopleWithType:DWDNearPeopleViewControllerNearPeopleTypeMyClass];
    }];
    UIAlertAction *action5 = [UIAlertAction actionWithTitle:@"向你打招呼的人" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        DWDLog(@"向你打招呼的人");
        [self seeNearPeopleWithType:DWDNearPeopleViewControllerNearPeopleTypeHelloToMe];
    }];
    UIAlertAction *action6 = [UIAlertAction actionWithTitle:@"清除位置并退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        DWDLog(@"清除位置并退出");
        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction *action7 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        DWDLog(@"取消");
    }];
    
    [alertVc addAction:action2];
    [alertVc addAction:action3];
    [alertVc addAction:action4];
    [alertVc addAction:action5];
    [alertVc addAction:action6];
    [alertVc addAction:action7];
    [self presentViewController:alertVc animated:YES completion:nil];
}


@end
