//
//  DWDClassSourceLeavePaperViewController.m
//  EduChat
//
//  Created by Superman on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassSourceLeavePaperViewController.h"
#import "DWDLeavePaperLookViewController.h"
#import "DWDLeavePaperApproveViewController.h"
#import "DWDAddNoteViewController.h"

#import "DWDAddLeaverPaperController.h"
#import "DWDLeavePaperDetailController.h"
#import "DWDTeacherCheckLeavePaperController.h"

#import "DWDLeavePaperCell.h"
#import "DWDSegmentedControl.h"

#import "DWDRequestServerLeavePaper.h"
#import "DWDAuthorEntity.h"
#import "DWDNoteEntity.h"

#import "DWDIntelligentOfficeDataHandler.h"

#import "DWDClassModel.h"
#import <Masonry/Masonry.h>
typedef enum {
    NotApproveType,approveType
}ApproveType;

@interface DWDClassSourceLeavePaperViewController()<DWDSegmentedControlDelegate>
@property (weak, nonatomic) UIView *indexLine;
@property (weak, nonatomic) UIButton *selectBtn;//标记按钮
@property (assign, nonatomic) ApproveType type;

@property (strong, nonatomic) UIView *noDataView;  //无数据默认页

@property (strong, nonatomic) DWDSegmentedControl *sc;

@property (strong, nonatomic) NSDictionary *arrDataSource;
@property (strong, nonatomic) NSDictionary *arrType_1;
@property (strong, nonatomic) NSDictionary*arrType_2;

@end
static NSString *ID = @"Cell";
@implementation DWDClassSourceLeavePaperViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"假条";
    DWDSegmentedControl *sc = [[DWDSegmentedControl alloc]init];
    self.sc = sc;
    sc.frame = CGRectMake(0, 0, DWDScreenW,DWDPadding *4);
    sc.arrayTitles = @[@"待审批",@"已审批"];
    sc.delegate = self;
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    [self registerCell];
    
    if (![DWDCustInfo shared].isTeacher) {
        [self addNote];
    }
    
    //检测此菜单功能是否点击过,key为menuCode
    NSString *key = [NSString stringWithFormat:@"%@-%@", [DWDCustInfo shared].custId, kDWDIntMenuCodeClassManagementLeave];
    NSString *obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!obj) {
        [self requestGetAlertWithMenuCode:kDWDIntMenuCodeClassManagementLeave];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //remove array allobject , pop reload data
    self.arrType_1 = nil;
    self.arrType_2 = nil;
    
//    NSNumber *type = self.selectBtn.tag == 0 ? @2 : @1;
    //request  获取范围 1-已审批  2-待审批
    [self requestDataType:@2];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //if selectBtn
//    NSNumber *type = self.selectBtn.tag == 0 ? @2 : @1;
//    //request  获取范围 1-已审批  2-待审批
//    [self requestDataType:type];
}


#pragma mark - Setup View
/** 申请假条 家长操作 */
- (void)addNote
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BtnPopAdd"] style:UIBarButtonItemStylePlain target:self action:@selector(showAddNoteVC)];
}
//注册Cell
-(void)registerCell
{
    [self.tableView registerNib:[UINib nibWithNibName:@"DWDLeavePaperCell" bundle:nil]forCellReuseIdentifier:ID];
}


#pragma mark - Getter
- (UIView *)noDataView
{
    if (!_noDataView) {
        _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, DWDScreenH/2-80, DWDScreenW, 200)];
        
        //imageView
        UIImageView *imv = [UIImageView new];
        imv.image = [UIImage imageNamed:@"msg_leave_no_data"];
        [_noDataView addSubview:imv];
        
        [imv makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(imv.superview.centerX);
            make.centerY.equalTo(imv.superview.centerY).offset(-64);
            
        }];
        
    }
    
    return _noDataView;
}

#pragma mark - Button Action
- (void)showAddNoteVC
{
//    DWDAddNoteViewController *addVC = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDAddNoteViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDAddNoteViewController class])];
//    addVC.classId = self.classId;
//    [self.navigationController pushViewController:addVC animated:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([DWDAddLeaverPaperController class]) bundle:nil];
    DWDAddLeaverPaperController *addVc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([DWDAddLeaverPaperController class])];
    addVc.classId = self.classId;
    [self.navigationController pushViewController:addVc animated:YES];
}


#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (!self.arrDataSource){
        [self.tableView addSubview:self.noDataView];
        return 0;
    }else{
        if (self.noDataView) {
            [self.noDataView removeFromSuperview];
        }
        NSArray *temp = self.arrDataSource[@"author"];
        return temp.count;

    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DWDLeavePaperCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];

    cell.type = (DWDLeavePaperCellType) self.type;
    
    cell.authorEntity = self.arrDataSource[@"author"][indexPath.row];//get author entity
    cell.noteEntity = self.arrDataSource[@"note"][indexPath.row];//get note entity
    return cell;
}
#pragma mark - <UITableViewDelegate>
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DWDPadding *6;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 40;
    }
    return 0;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return self.sc;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if (self.type == NotApproveType) {
    
//        DWDLeavePaperApproveViewController *vc = [[DWDLeavePaperApproveViewController alloc]init];
//        
//        vc.authorEntity = self.arrDataSource[@"author"][indexPath.row];
//        vc.noteEntity = self.arrDataSource[@"note"][indexPath.row];
//        vc.classId = self.classId;
//        [self.navigationController pushViewController:vc animated:YES];
        
    DWDNoteEntity *entity = self.arrDataSource[@"note"][indexPath.row];
        if ([DWDCustInfo shared].isTeacher) {
            DWDTeacherCheckLeavePaperController *vc = [DWDTeacherCheckLeavePaperController new];
            vc.classId = self.classId;
            vc.leavePaperId = entity.noteId;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            DWDLeavePaperDetailController *vc = [[DWDLeavePaperDetailController alloc] init];
            vc.classId = self.classId;
            vc.leavePaperId = entity.noteId;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
//    }else{
//        DWDLeavePaperLookViewController *vc = [[DWDLeavePaperLookViewController alloc]init];
//        
//        vc.authorEntity = self.arrDataSource[@"author"][indexPath.row];
//        vc.noteEntity = self.arrDataSource[@"note"][indexPath.row];
//         vc.classId = self.classId;
//        [self.navigationController pushViewController:vc animated:YES];
//        
//    }
    
}

#pragma mark - DWDSegmentedControlDelegate
-(void)segmentedControlIndexButtonView:(DWDSegmentedControl *)indexButtonView lickBtn:(UIButton *)sender
{
    self.selectBtn = sender;
    
    if (sender.tag == 0) {//待审批
        
        self.type = NotApproveType;
        DWDLog(@"%@",self.arrType_1);
        self.arrDataSource = self.arrType_1;
        
         [self.tableView reloadData];
        
        
        //request  获取范围 1-已审批  2-待审批
        if (self.arrType_1) return;
        [self requestDataType:@2];

    }else{
        
        self.type = approveType;
        self.arrDataSource = self.arrType_2;

         [self.tableView reloadData];
        
        //request  获取范围 1-已审批  2-待审批
        if (self.arrType_2) return;
        [self requestDataType:@1];
    
    }
    
    
    
}

#pragma mark - request
- (void)requestDataType:(NSNumber *)type
{
    __weak DWDClassSourceLeavePaperViewController *weakSele = self;
    
    [[DWDRequestServerLeavePaper sharedDWDRequestServerLeavePaper] requestGetListCustId:[DWDCustInfo shared].custId classId:self.classId type:type pageIndex:@1 pageCount:@25 success:^(id responseObject) {
        
        if ([type isEqualToNumber:@2]) {
            
            self.arrType_1 = responseObject;
            
            
        }else if([type isEqualToNumber:@1]) {
            
            self.arrType_2 = responseObject;
        }
        
        weakSele.arrDataSource = responseObject;
        [weakSele.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        DWDProgressHUD *hud = [DWDProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = error.localizedFailureReason;
        hud.labelColor = [UIColor whiteColor];
        [hud hide:YES afterDelay:1.0];
    }];
}

- (void)requestGetAlertWithMenuCode:(NSString *)code{
    [DWDIntelligentOfficeDataHandler requestGetAlertWithCid:[DWDCustInfo shared].custId sid:self.classModel.schoolId mncd:code sta:nil targetController:self success:^{
        
    } failure:^(NSError *error) {
        
    }];
}

@end
