//
//  DWDAddNewClassCityViewController.m
//  EduChat
//
//  Created by Superman on 15/12/11.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDAddNewClassCityViewController.h"
#import "DWDAddNewClassViewController.h"
#import "DWDTownModel.h"
#import "DWDCityModel.h"
#import "DWDCustInfoClient.h"
#import "DWDCitySectionButton.h"
#import "DWDClassDataHandler.h"
#import <MBProgressHUD.h>
#import <YYModel.h>

@interface DWDAddNewClassCityViewController ()

@property (nonatomic, assign) NSUInteger           selectSection;
@property (nonatomic, strong) NSMutableArray       *townArray;
@property (nonatomic, strong) NSMutableArray       *sectionBtnArray;

@property (nonatomic, strong) DWDCitySectionButton *lastBtn;
@property (nonatomic, assign) BOOL                 isIconDown;
@property (nonatomic, strong) NSIndexPath          *indexpath;

@end

@implementation DWDAddNewClassCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"城市";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _selectSection = -1;
    _isIconDown = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarBtnClick)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (NSMutableArray *)sectionBtnArray{
    if (!_sectionBtnArray) {
        NSMutableArray *tempArr = [NSMutableArray array];
        for (int i = 0; i < _cityArray.count; i ++) {
            _sectionBtnArray = [NSMutableArray array];
            DWDCitySectionButton *btn = [DWDCitySectionButton buttonWithType:UIButtonTypeCustom];
            [btn addTarget:self action:@selector(sectionClick:) forControlEvents:UIControlEventTouchUpInside];
            
            btn.isIconDown = YES;
            btn.tag = i;
            [btn setTitleColor:DWDColorBody forState:UIControlStateNormal];
            btn.titleLabel.font = DWDFontContent;
            [btn.titleLabel setTextColor:DWDColorSecondary];
            [btn.titleLabel sizeToFit];
            [tempArr addObject:btn];
        }
        _sectionBtnArray = tempArr;
    }
    return _sectionBtnArray;
}

- (NSMutableArray *)townArray{
    if (!_townArray) {
        _townArray = [NSMutableArray array];
        
    }
    return _townArray;
}

- (void)rightBarBtnClick{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_indexpath];
    DWDCitySectionButton *header = (DWDCitySectionButton *)[self tableView:self.tableView viewForHeaderInSection:_indexpath.section];
    DWDTownModel *townModel = self.townArray[_indexpath.row];
    NSDictionary *dict = @{@"province" : _provinceName,
                           @"cityName" : header.titleLabel.text,
                           @"regionName" : cell.textLabel.text,
                           @"regionCode" : townModel.regionCode};
    
    //this is meDetail area --- Gatlin this is good boy *********** ation *********
    if (self.type == DWDSelfClassPropertyTypeSelectCityForChangeMeArea) {
        
        DWDTownModel *town = self.townArray[self.indexpath.row];
        
        //request commit area
        [[DWDCustInfoClient sharedCustInfoClient]
         requestUpdateWithRegionName:town.regionCode
         success:^(id responseObject)
         {
             UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:1];
             [self.navigationController popToViewController:vc animated:YES];
             
         }];
        return;
    }
    //this is meDetail area --- Gatlin this is good boy *********** end *********

    [[NSNotificationCenter defaultCenter] postNotificationName:DWDDWDCityNameDidSelectNotification object:nil userInfo:dict];
    
    if (_destinationVc) {
        [self.navigationController popToViewController:_destinationVc animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dealloc{
    [_cityArray removeAllObjects];
    [self.townArray removeAllObjects];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.cityArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_selectSection == section) {
        return self.townArray.count;
    }else{
        return 0; // 第一次进入  没有赋值过select
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        CALayer *seperator = [CALayer layer];
        seperator.backgroundColor = DWDColorSecondary.CGColor;
        seperator.frame = CGRectMake(18, cell.h - 1, DWDScreenW, 0.5);
        [cell.layer addSublayer:seperator];
    }
    
    DWDTownModel *town = self.townArray[indexPath.row];
    cell.textLabel.text = town.name;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    DWDCityModel *city = self.cityArray[section];
    
    DWDCitySectionButton *btn = self.sectionBtnArray[section];
    [btn setTitle:city.name forState:UIControlStateNormal];
    
    CGSize realSize = [city.name realSizeWithfont:DWDFontContent];
    if ([self.tableView numberOfRowsInSection:section] == 0) {
        [btn setImage:[UIImage imageNamed:@"ic_down"] forState:UIControlStateNormal];
    }else{
        [btn setImage:[UIImage imageNamed:@"ic_up"] forState:UIControlStateNormal];
    }
    
    btn.imageEdgeInsets = UIEdgeInsetsMake(pxToH(22), DWDScreenW - pxToW(54), pxToH(22), 0);
    btn.titleEdgeInsets = UIEdgeInsetsMake(pxToH(30), -30, pxToH(30), DWDScreenW - pxToW(20) - realSize.width - pxToW(44));
    return btn;
}

- (void)sectionClick:(DWDCitySectionButton *)btn{
    DWDLogFunc;
    if (_selectSection == btn.tag) {
        // 已展开  , 且点的是同一组,  收起  return
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self.townArray removeAllObjects];
        btn.isIconDown = YES;
        _selectSection = -1;
        [self.tableView reloadData];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:btn.tag] withRowAnimation:UITableViewRowAnimationBottom];
        return;
    }else if (_selectSection != btn.tag && _selectSection != -1){
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        // 已展开 , 点的不是同一组,  收起上一组, 展开新点的组
        // 收起上一组
        [self.townArray removeAllObjects];
        // 获取新一组
        DWDCityModel *city = self.cityArray[btn.tag];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        hud.labelText = @"正在获取行政区,请稍候...";
        [DWDClassDataHandler getDistrictWithDistrictCode:city.regionCode subdistrict:@1 success:^(NSMutableArray *data) {
            
            [self.townArray addObjectsFromArray:data];
            [_lastBtn setImage:[UIImage imageNamed:@"ic_ip"] forState:UIControlStateNormal];
            
            if (self.townArray.count > 0) {
                hud.labelText = @"获取成功!";
                // 获取成功才保存选中
                _selectSection = btn.tag;
                
                // 收起上一组,展开新的组
                _lastBtn.isIconDown = YES;
                btn.isIconDown = NO;
                // 刷新
                [self.tableView reloadData];
                // 新的被展开组有动画就可以了
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:btn.tag] withRowAnimation:UITableViewRowAnimationBottom];
                
                [hud hide:YES afterDelay:1.0];
                return ;
            }else{
                // 直接跳转传值
                NSDictionary *dict = @{@"province" : _provinceName,
                                       @"cityName" : btn.titleLabel.text};
                [[NSNotificationCenter defaultCenter] postNotificationName:DWDDWDCityNameDidSelectNotification object:nil userInfo:dict];
                
                if (_destinationVc) {
                    [self.navigationController popToViewController:_destinationVc animated:YES];
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
                [hud hide:YES];
            }
            
        } failure:^(NSError *error) {
            hud.labelText = [error localizedDescription];
            [hud hide:YES afterDelay:1.0];
            
            // 这里刷新为了收起上一组
            [self.tableView reloadData];
        }];
    }
    
    // 没有展开过
    
    DWDCityModel *city = self.cityArray[btn.tag];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = @"正在获取行政区,请稍候...";
    
    [DWDClassDataHandler getDistrictWithDistrictCode:city.regionCode subdistrict:@1 success:^(NSMutableArray *data) {
        
        [self.townArray addObjectsFromArray:data];
        
        if (self.townArray.count > 0) {
            hud.labelText = @"获取成功!";
            // 获取成功才保存选中
            _lastBtn = btn;
            _selectSection = btn.tag;
            btn.isIconDown = NO;
            // 刷新
            [self.tableView reloadData];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:btn.tag] withRowAnimation:UITableViewRowAnimationBottom];
            
            [hud hide:YES afterDelay:1.0];
        }else{
            
            //this is meDetail area --- Gatlin this is good boy *********** ation *********
            if (self.type == DWDSelfClassPropertyTypeSelectCityForChangeMeArea) {
                
                [hud hide:YES];
                DWDCityModel *town = self.cityArray[btn.tag];
                
                //request commit area
                [[DWDCustInfoClient sharedCustInfoClient]
                 requestUpdateWithRegionName:town.regionCode
                 success:^(id responseObject)
                 {
                     UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:1];
                     [self.navigationController popToViewController:vc animated:YES];
                     
                 }];
                return;
            }
            //this is meDetail area --- Gatlin this is good boy *********** end *********
            
            // 直接跳转传值
            NSDictionary *dict = @{@"province" : _provinceName,
                                   @"cityName" : btn.titleLabel.text};
            [[NSNotificationCenter defaultCenter] postNotificationName:DWDDWDCityNameDidSelectNotification object:nil userInfo:dict];
            
            if (_destinationVc) {
                [self.navigationController popToViewController:_destinationVc animated:YES];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
            [hud hide:YES];
        }
        
    } failure:^(NSError *error) {
        hud.labelText = [error localizedDescription];
        [hud hide:YES afterDelay:1.0];
    }];
}

#pragma mark -<UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return pxToH(88);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 跳转传值
    self.navigationItem.rightBarButtonItem.enabled = YES;
    _indexpath = indexPath;
}

@end
