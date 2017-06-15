//
//  DWDSearchSchoolAndClassController.m
//  EduChat
//
//  Created by Superman on 15/12/17.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDSearchSchoolAndClassController.h"
#import "DWDNearbySchoolCell.h"
#import "DWDNearbySchoolClassCell.h"

#import "DWDNearbySchoolModel.h"
#import "DWDNearBySelectedSchoolClassModel.h"
#import <MBProgressHUD.h>
#import <YYModel.h>
@interface DWDSearchSchoolAndClassController () <UITextFieldDelegate , UITableViewDataSource , UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *schoolField;
@property (weak, nonatomic) IBOutlet UITextField *classField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *schoolContainer;
@property (weak, nonatomic) IBOutlet UIView *classContainer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *schoolHeightCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *classHeightCons;

@property (nonatomic , strong) NSMutableArray *nearbySchools;
@property (nonatomic , strong) NSMutableArray *nearbySelectedSchoolClasses;
@property (nonatomic , strong) NSMutableArray *schoolsCachs;
@property (nonatomic , strong) NSMutableArray *nearClassCachs;

@property (nonatomic , copy) NSString *selectedSchoolCode;
@property (nonatomic , strong) DWDNearbySchoolModel *selectedSchoolModel;
@property (nonatomic , strong) DWDNearBySelectedSchoolClassModel *DWDNearSelectedClass;

@property (nonatomic , assign) NSUInteger schoolId;

@end

@implementation DWDSearchSchoolAndClassController

- (void)viewDidLoad{
    [super viewDidLoad];
    _schoolField.delegate = self;
    _classField.delegate = self;
    _schoolField.tag = 0;
    _classField.tag = 1;
    self.title = @"学校/班级";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarBtnClick)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}
- (void)rightBarBtnClick{
    [[NSNotificationCenter defaultCenter] postNotificationName:DWDSelectedNearbyClassesNotification object:self userInfo:@{@"name" : _classField.text}];
    
    NSDictionary *dict = @{@"fullName" : _schoolField.text,
                           @"schoolId" : @(_schoolId)};
    [[NSNotificationCenter defaultCenter] postNotificationName:DWDSearchSchoolAndClassControllerSelectSchoolNotification object:self userInfo:dict];
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - <lazy>
- (NSMutableArray *)nearbySchools{
    if (!_nearbySchools) {
        _nearbySchools = [NSMutableArray array];
    }
    return _nearbySchools;
}
- (NSMutableArray *)nearbySelectedSchoolClasses{
    if (!_nearbySelectedSchoolClasses) {
        _nearbySelectedSchoolClasses = [NSMutableArray array];
    }
    return _nearbySelectedSchoolClasses;
}

- (NSMutableArray *)schoolsCachs{
    if (!_schoolsCachs) {
        _schoolsCachs = [NSMutableArray array];
    }
    return _schoolsCachs;
}

- (NSMutableArray *)nearClassCachs{
    if (!_nearClassCachs) {
        _nearClassCachs = [NSMutableArray array];
    }
    return _nearClassCachs;
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.nearbySelectedSchoolClasses.count > 0) {
        return self.nearbySelectedSchoolClasses.count;
    }else{
        return self.nearbySchools.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *schoolID = @"schoolCell";
    static NSString *nearClassID = @"classCell";
    if (self.nearbySelectedSchoolClasses.count > 0) {
        DWDNearbySchoolClassCell *classesCell = [tableView dequeueReusableCellWithIdentifier:nearClassID];
        if (!classesCell) {
            classesCell = [[DWDNearbySchoolClassCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nearClassID];
        }
        classesCell.nearBySchoolClass = self.nearbySelectedSchoolClasses[indexPath.row];
        return classesCell;
    }else{
        
        DWDNearbySchoolCell *cell = [tableView dequeueReusableCellWithIdentifier:schoolID];
        if (!cell) {
            cell = [[DWDNearbySchoolCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:schoolID];
        }
        cell.schoolModel = self.nearbySchools[indexPath.row];
        return cell;
    }
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.nearbySelectedSchoolClasses.count > 0) {
        return 50;
    }else{
        return 80;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    
    if (self.nearbySelectedSchoolClasses.count > 0) {
        DWDNearBySelectedSchoolClassModel *nearClassModel = self.nearbySelectedSchoolClasses[indexPath.row];
        _DWDNearSelectedClass = nearClassModel;
        
        _classField.text = nearClassModel.name;
    }else{
        
        DWDNearbySchoolModel *schoolModel = self.nearbySchools[indexPath.row];
        _selectedSchoolCode = schoolModel.districtCode;
        _selectedSchoolModel = schoolModel;
        _schoolId = schoolModel.custId;
        
        _schoolField.text = schoolModel.fullName;
    }
    _classContainer.hidden = NO;
    _schoolContainer.hidden = NO;
    _classHeightCons.constant = 50;
    _schoolHeightCons.constant = 50;
    
    if (_schoolField.text.length > 0 && _classField.text.length > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [self.nearbySchools removeAllObjects];
    [self.nearbySelectedSchoolClasses removeAllObjects];
    [self.tableView reloadData];
}
#pragma mark - <UITextFieldDelegate>

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.tag == 0 && self.nearbySchools.count == 0) {
        self.nearbySchools = _schoolsCachs;
        [self.tableView reloadData];
    }else if (textField.tag == 1 && self.nearbySelectedSchoolClasses.count == 0){
        self.nearbySelectedSchoolClasses = _nearClassCachs;
        [self.tableView reloadData];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    DWDLogFunc;
    _classHeightCons.constant = 50;
    _schoolHeightCons.constant = 50;
    _classContainer.hidden = NO;
    _schoolContainer.hidden = NO;
    [textField resignFirstResponder];
    [self.nearbySchools removeAllObjects];
    [self.nearbySelectedSchoolClasses removeAllObjects];
    [self.tableView reloadData];
    if (_schoolField.text.length > 0 && _classField.text.length > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    return YES;
}


// 每次输入字符都会到这里  (做模糊搜索也是这个方法)
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (string.length == 0 && textField.text.length == 1) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }else if (string.length > 0 && textField.text.length == 0){
        if (textField.tag == 0 && _classField.text.length > 0) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }else if (textField.tag == 1 && _schoolField.text.length > 0){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }else{
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    DWDLogFunc;
    if (textField.tag == 0) {
        _classHeightCons.constant = 0;
        _schoolHeightCons.constant = 50;
        _classContainer.hidden = YES;
        _schoolContainer.hidden = NO;
        [self.view layoutIfNeeded];
        if (self.schoolsCachs.count == 0) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            hud.labelText = @"正在获取附近的学校信息,请稍候...";
            
            NSString *code = _detailRegionCode!=nil? _detailRegionCode : @"000000";
            NSDictionary *params = @{@"districtCode" : code,
                                     @"type" : @6};
            [[HttpClient sharedClient] getApi:@"EnterpriseRestService/getList" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
                NSArray *arr = responseObject[@"data"];
                for (int i = 0; i < arr.count; i++) {
                    DWDNearbySchoolModel *schoolModel = [DWDNearbySchoolModel yy_modelWithJSON:arr[i]];
                    [self.nearbySchools addObject:schoolModel];
                }
                self.schoolsCachs = self.nearbySchools;
                hud.labelText = @"获取成功!";
                [self.tableView reloadData];
                [hud hide:YES afterDelay:0.5];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                DWDLog(@"error:%@",error);
                hud.labelText = @"获取失败!";
                [hud hide:YES afterDelay:1.0];
            }];
        }
    }else{
        _classHeightCons.constant = 50;
        _schoolHeightCons.constant = 0;
        _classContainer.hidden = NO;
        _schoolContainer.hidden = YES;
        [self.view layoutIfNeeded];
        if (_schoolField.text.length > 0) {
            // 发送请求 获取班级
            if (self.nearClassCachs.count == 0) {
                if (_selectedSchoolModel) { // 如果是通过点击cell选择的学校,那么才有值,那么就获取这个学校拥有的班级
                    NSDictionary *params = @{@"schoolId" : @(_selectedSchoolModel.custId)};
                    [[HttpClient sharedClient] getApi:@"ClassRestService/getClassNameList" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
                        DWDLog(@"%@",responseObject[@"data"]);
                        NSArray *classes = responseObject[@"data"];
                        for (int i = 0; i < classes.count; i++) {
                            DWDNearBySelectedSchoolClassModel *selectedSchoolClassModel = [DWDNearBySelectedSchoolClassModel yy_modelWithJSON:classes[i]];
                            [self.nearbySelectedSchoolClasses addObject:selectedSchoolClassModel];
                        }
                        self.nearClassCachs = self.nearbySelectedSchoolClasses;
                        [self.tableView reloadData];
                        
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        DWDLog(@"%@",error);
                    }];
                }else{ // 证明是手输写入的学校,获取手输的内容来创建学校//  应该放到创建班级那里做
                    NSString *fullName = _schoolField.text;
                    NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                                             @"type" : @5,
                                             @"fullName" : fullName};
                    [[HttpClient sharedClient] postApi:@"EnterpriseRestService/addEntity" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
                        DWDLog(@"%@" , responseObject[@"data"]);
                        _schoolId = (NSUInteger)responseObject[@"data"][@"custId"];
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        DWDLog(@"error:%@",error);
                    }];
                }
            }
        }else{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            hud.labelText = @"请先选择您所在的学校,再选择班级";
            [textField resignFirstResponder];
            _classHeightCons.constant = 50;
            _schoolHeightCons.constant = 50;
            _classContainer.hidden = NO;
            _schoolContainer.hidden = NO;
            [hud show:YES];
            [hud hide:YES afterDelay:1.0];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    _classContainer.hidden = NO;
    _schoolContainer.hidden = NO;
    _classHeightCons.constant = 50;
    _schoolHeightCons.constant = 50;
    [self.nearbySchools removeAllObjects];
    [self.nearbySelectedSchoolClasses removeAllObjects];
    [self.tableView reloadData];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    return YES;
}

@end
