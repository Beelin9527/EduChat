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
#import "DWDClassDataHandler.h"
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

@property (nonatomic , strong) NSNumber *selectedSchoolCode;
@property (nonatomic , strong) DWDNearbySchoolModel *selectedSchoolModel;
@property (nonatomic , strong) DWDNearBySelectedSchoolClassModel *DWDNearSelectedClass;

@property (weak, nonatomic) IBOutlet UILabel *desLabel;
@property (weak, nonatomic) IBOutlet UIView *seperator;

@end

@implementation DWDSearchSchoolAndClassController

- (void)viewDidLoad{
    [super viewDidLoad];
    _seperator.backgroundColor = DWDColorBackgroud;
    _desLabel.text = @"";
    _schoolField.delegate = self;
    _classField.delegate = self;
    
    _schoolField.text = _selectSchoolName;
    _classField.text = _selectClassName;
    
    self.view.backgroundColor = DWDColorBackgroud;
    
    _schoolField.borderStyle = UITextBorderStyleNone;
    _classField.borderStyle = UITextBorderStyleNone;
    
//    if (_regionName.length > 0) {
//        NSString *schoolText = [NSString stringWithFormat:@"%@%@%@",_province,_cityName,_regionName];
//        _schoolField.text = schoolText;
//    }else{
//        NSString *schoolText = [NSString stringWithFormat:@"%@%@",_province,_cityName];
//        _schoolField.text = schoolText;
//    }
    
    _schoolField.tag = 0;
    _classField.tag = 1;
    self.title = @"学校/班级";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = DWDColorBackgroud;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarBtnClick)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

//- (void)myKeyBoardDismiss:(NSNotification *)note{
//    _classContainer.hidden = NO;
//    _schoolContainer.hidden = NO;
//    _classHeightCons.constant = 50;
//    _schoolHeightCons.constant = 50;
//}

- (void)rightBarBtnClick{
    if (!self.selectedSchoolModel.custId || [self.selectedSchoolModel.custId isEqualToNumber:@0]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请选择正确的学校名称" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:sureAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSDictionary *dict;
    if (_DWDNearSelectedClass) {
        dict = @{@"fullName" : _schoolField.text,
                 @"className" : _DWDNearSelectedClass};
    }else{
        DWDNearBySelectedSchoolClassModel *selectedClass = [[DWDNearBySelectedSchoolClassModel alloc] init];
        selectedClass.name = _classField.text;
        selectedClass.used = NO;
        selectedClass.standardId = nil;
        
        dict = @{@"fullName" : _schoolField.text,
                 @"className" : selectedClass};
    }
    
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.nearbySchools.count == 0 && self.nearbySelectedSchoolClasses.count == 0) {
        _desLabel.text = nil;
    }else{
        if (self.nearbySelectedSchoolClasses.count > 0 ) {
            _desLabel.text = @"您要找的是";
        }else if(self.nearbySchools.count > 0 && _schoolField.text.length == 0){
            _desLabel.text = @"附近学校";
        }
    }
    
    if (self.nearbySelectedSchoolClasses.count > 0) {
        return self.nearbySelectedSchoolClasses.count;
    }else{
        return self.nearbySchools.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *schoolID = @"schoolCell";
    static NSString *nearClassID = @"classCell";
    if (self.nearbySelectedSchoolClasses.count > 0) {  // 班级的
        DWDNearbySchoolClassCell *classesCell = [tableView dequeueReusableCellWithIdentifier:nearClassID];
        if (!classesCell) {
            classesCell = [[DWDNearbySchoolClassCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nearClassID];
        }
        classesCell.nearBySchoolClass = self.nearbySelectedSchoolClasses[indexPath.row];
        return classesCell;
    }else{   // 学校的
        
        DWDNearbySchoolCell *cell = [tableView dequeueReusableCellWithIdentifier:schoolID];
        if (!cell) {
            cell = [[DWDNearbySchoolCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:schoolID];
        }
        cell.schoolModel = self.nearbySchools[indexPath.row];
        return cell;
    }
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.nearbySelectedSchoolClasses.count > 0) {
        return pxToH(66);
    }else{
        return pxToH(115);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    if (self.nearbySelectedSchoolClasses.count > 0) {
        DWDNearBySelectedSchoolClassModel *nearClassModel = self.nearbySelectedSchoolClasses[indexPath.row];
        if (nearClassModel.used) {
            [DWDProgressHUD showText:@"该班级已创建,请联系老师加入班级吧"];
            return;
        }
        _DWDNearSelectedClass = nearClassModel;
        
        _classField.text = nearClassModel.name;
    }else{
        
        DWDNearbySchoolModel *schoolModel = self.nearbySchools[indexPath.row];
        _selectedSchoolCode = schoolModel.regionCode;
        _selectedSchoolModel = schoolModel;
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"searchControllerDidSelectedSchoolId" object:self userInfo:@{@"schoolId" : schoolModel.custId}];
        
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

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - <UITextFieldDelegate>

- (void)textFiledEditChanged:(NSNotification *)noti
{
    UITextField *textField = noti.object;
    //获取高亮部分
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if (position) {
        return;
    }
    if (textField == _schoolField) {

        _desLabel.text = @"您要找的是";
        [DWDClassDataHandler getAroundSchoolWithDistrictCode:_detailRegionCode type:@6 fuzzyName:textField.text success:^(NSMutableArray *data) {
            
            [self.nearbySchools removeAllObjects];
            [self.nearClassCachs removeAllObjects];
            [self.nearbySchools addObjectsFromArray:data];
            self.schoolsCachs = self.nearbySchools;
            [self.tableView reloadData];
            
        } failure:^(NSError *error) {
            [self.nearbySchools removeAllObjects];
            [self.nearClassCachs removeAllObjects];
            [self.tableView reloadData];
        }];
    }else {
        
        if (_schoolField.text.length > 0) {
            if (!self.selectedSchoolModel.custId || [self.selectedSchoolModel.custId isEqualToNumber:@0]) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请选择正确的学校名称" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:sureAction];
                [self presentViewController:alert animated:YES completion:nil];
                
            }else{
                [DWDClassDataHandler getClassListWithSchoolId:self.selectedSchoolModel.custId fuzzyName:textField.text success:^(NSMutableArray *data) {
                    
                    [self.nearbySelectedSchoolClasses removeAllObjects];
                    [self.nearbySelectedSchoolClasses addObjectsFromArray:data];
                    self.nearClassCachs = self.nearbySelectedSchoolClasses;
                    [self.tableView reloadData];
                    
                } failure:^(NSError *error) {
                    [self.nearbySelectedSchoolClasses removeAllObjects];
                    [self.tableView reloadData];
                }];
            }
            
            if (_selectedSchoolModel) {
//                [DWDClassDataHandler getClassListWithSchoolId:_selectedSchoolModel.custId fuzzyName:textField.text success:^(NSMutableArray *data) {
//                    
//                    [self.nearbySelectedSchoolClasses removeAllObjects];
//                    [self.nearbySelectedSchoolClasses addObjectsFromArray:data];
//                    self.nearClassCachs = self.nearbySelectedSchoolClasses;
//                    [self.tableView reloadData];
//                    
//                } failure:^(NSError *error) {
//                    [self.nearbySelectedSchoolClasses removeAllObjects];
//                    [self.tableView reloadData];
//                }];
            }else { // 证明是手输写入的学校,获取手输的内容来创建学校
                
//                [DWDClassDataHandler createSchoolWithFullName:_schoolField.text type:@5 districtCode:_detailRegionCode success:^(NSNumber *schoolId) {
//                    
////                    _schoolId = schoolId;
//                } failure:^(NSError *error) {
//                    
//                }];
            }
        }else {
            [DWDProgressHUD showText: @"请先选择您所在的学校,再选择班级" afterDelay:1.0];
            [textField resignFirstResponder];
            _classHeightCons.constant = 50;
            _schoolHeightCons.constant = 50;
            _classContainer.hidden = NO;
            _schoolContainer.hidden = NO;
        }
    }
    if (_schoolField.text.length > 0 && _classField.text.length > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

// 完成开始编辑
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if (textField.tag == 0 && textField.text.length == 0) {
        _desLabel.text = @"附近学校";
    }else{
        _desLabel.text = @"您要找的是";
    }
    
    if (textField.tag == 0 && self.nearbySchools.count == 0) {
        
        self.nearbySchools = _schoolsCachs;
        [self.tableView reloadData];
    }
    else if (textField.tag == 1 && self.nearbySelectedSchoolClasses.count == 0){
        self.nearbySelectedSchoolClasses = _nearClassCachs;
        [self.tableView reloadData];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
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

// 是否允许开始编辑
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{  // 刚点击学校field  直接获取所有的附近学校
    DWDLogFunc;
    if (textField.tag == 0) {
        if (textField.text.length > 0){
            return YES;
        }
        _classHeightCons.constant = 0;
        _schoolHeightCons.constant = 50;
        _classContainer.hidden = YES;
        _schoolContainer.hidden = NO;
        [self.view layoutIfNeeded];
        
        [self.nearbySelectedSchoolClasses removeAllObjects];
        [self.nearbySchools removeAllObjects];
        
        if (self.schoolsCachs.count == 0) {
            
            [DWDProgressHUD showText:@"正在获取附近的学校信息,请稍候..."];
            
            NSString *code = _detailRegionCode!=nil? _detailRegionCode : @"000000";
            
            [DWDClassDataHandler getAroundSchoolWithDistrictCode:code type:@6 fuzzyName:_schoolField.text success:^(NSMutableArray *data) {
                
                [self.nearbySchools addObjectsFromArray:data];
                self.schoolsCachs = self.nearbySchools;
                [self.tableView reloadData];
                [DWDProgressHUD hideHUDForView:self.view animated:YES];
                
            } failure:^(NSError *error) {
                [DWDProgressHUD showText:@"获取失败!" afterDelay:1.0];
                [self.nearbySchools removeAllObjects];
                [self.tableView reloadData];
            }];
        }
    }else{
        
        _classContainer.hidden = NO;
        _schoolContainer.hidden = NO;
        [self.view layoutIfNeeded];
        if (_schoolField.text.length > 0) {
            // 发送请求 获取班级
            if (self.nearClassCachs.count == 0) {
                if (_selectedSchoolModel) { // 如果是通过点击cell选择的学校,那么才有值,那么就获取这个学校拥有的班级
                    
                    [DWDClassDataHandler getClassListWithSchoolId:_selectedSchoolModel.custId fuzzyName:textField.text success:^(NSMutableArray *data) {
                        
                        [self.nearbySelectedSchoolClasses removeAllObjects];
                        [self.nearbySelectedSchoolClasses addObjectsFromArray:data];
                        self.nearClassCachs = self.nearbySelectedSchoolClasses;
                        [self.tableView reloadData];
                        
                    } failure:^(NSError *error) {
                        [self.nearbySelectedSchoolClasses removeAllObjects];
                        [self.tableView reloadData];
                    }];

                }else{ // 证明是手输写入的学校,获取手输的内容来创建学校//  应该放到创建班级那里做
                    
//                    [DWDClassDataHandler createSchoolWithFullName:_schoolField.text type:@5 districtCode:_detailRegionCode success:^(NSNumber *schoolId) {
//                        
////                        _schoolId = schoolId;
//                    } failure:^(NSError *error) {
//                        
//                    }];
                }
            }
        }else{
            [DWDProgressHUD showText: @"请先选择您所在的学校,再选择班级" afterDelay:1.0];
            [textField resignFirstResponder];
            _classHeightCons.constant = 50;
            _schoolHeightCons.constant = 50;
            _classContainer.hidden = NO;
            _schoolContainer.hidden = NO;
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
    _desLabel.text = nil;
    return YES;
}


@end
