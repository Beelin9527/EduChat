//
//  DWDTeacherCheckLeavePaperController.m
//  EduChat
//
//  Created by KKK on 16/5/13.
//  Copyright © 2016年 dwd. All rights reserved.
//

#define kStateAgree @1
#define kStateRefuse @2
#define kStateNotSure @0

#import "DWDTeacherCheckLeavePaperController.h"
#import "DWDLeavePaperCellGroup.h"
#import "DWDLeavePaperDetailModel.h"

#import "NSString+extend.h"

#import <YYModel.h>

@interface DWDTeacherCheckLeavePaperController () <DWDLeavePaperAproveCellDelegate, DWDLeavePaperTeacherRefuseCellDelegate>

@property (nonatomic, strong) DWDLeavePaperDetailModel *model;
//-1 同意 -2 不同意
@property (nonatomic, assign) NSInteger buttonState;
//不同意理由
@property (nonatomic, copy) NSString *refuseReasonStr;

@end

@implementation DWDTeacherCheckLeavePaperController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"假条详情";
    self.tableView.backgroundColor = DWDColorBackgroud;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self requestLeavePaperDetail];
}
#pragma mark - Private Method
- (void)addRightBarButtonItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(commitButtonClick)];
    [item setTitleTextAttributes:@{
                                   NSFontAttributeName : [UIFont systemFontOfSize:16],
                                   NSForegroundColorAttributeName : [UIColor whiteColor],
                                   }
                        forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = item;
}
     
- (void)requestLeavePaperDetail {
    //                           参数	必填	类型	值域	说明
    //                           custId	√	long	(0,)	用户id
    //                           classId	√	long	(0,)	班级id
    //                           noteId	√	long	(0,)	假条id
    NSDictionary *dict = @{
                           @"custId" : [DWDCustInfo shared].custId,
                           @"classId" : self.classId,
                           @"noteId" : self.leavePaperId,
                           };
    WEAKSELF;
    [[HttpClient sharedClient] getLeavePaperDetailWithParams:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        DWDLeavePaperDetailModel *model = [DWDLeavePaperDetailModel yy_modelWithJSON:responseObject[@"data"]];
        weakSelf.model = model;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([model.state isEqualToNumber:kStateNotSure]) {
                [weakSelf addRightBarButtonItem];
            } else {
                weakSelf.navigationItem.rightBarButtonItem = nil;
            }
            [weakSelf.tableView reloadData];
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}

/**
 *  计算文字高度
 */
- (CGFloat)labelHeightWithString:(NSString *)str fontSize:(CGFloat)fontSize {
    
    CGSize size = CGSizeZero;
    if (str) {
        //iOS 7
        CGRect frame = [str boundingRectWithSize:CGSizeMake(DWDScreenW - 20, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]}
                                         context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height + 1);
    }
    
    return size.height;
}


- (NSInteger)indexOfClass:(Class)class {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DWDLeavePaperCellGroup" owner:nil options:nil];
    NSInteger index = 0;
    for (int i = 0; i < array.count; i ++) {
        UITableViewCell *cell = array[i];
        if ([cell isKindOfClass:class]) {
            index = i;
            break;
        }
    }
    return index;
}

#pragma mark - Event Response
- (void)commitButtonClick {
    //判断行不行
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    if (_buttonState != -1 && _buttonState != -2) {
        hud.labelText = @"请选择是否同意";
        [hud show:YES];
        [hud hide:YES afterDelay:1.5f];
        return;
    }
    if (_buttonState == -2 && ([_refuseReasonStr isEqualToString:@"请填写不同意理由"] || _refuseReasonStr.length == 0 || _refuseReasonStr == nil)) {
        hud.labelText = @"请填写不同意理由";
        [hud show:YES];
        [hud hide:YES afterDelay:1.5f];
        return;
    }
    hud.labelText = @"请稍候";
    hud.mode = MBProgressHUDModeIndeterminate;
    [hud show:YES];
    //发送请求
//    参数	必填	类型	值域	说明
//    custId	√	long	(0,)	用户id
//    classId	√	long	(0,)	班级id
//    noteId	√	long	(0,)	假条id
//    state		int	1:同意|2:不同意	审批状态
//    opinion		String		审批意见    不同意时必须填写
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DWDCustInfo shared].custId forKey:@"custId"];
    [dict setObject:self.classId forKey:@"classId"];
    [dict setObject:self.leavePaperId forKey:@"noteId"];
    [dict setObject:self.buttonState == -1 ? @1 : @2 forKey:@"state"];
    if (self.buttonState == -2) {
        [dict setObject:_refuseReasonStr forKey:@"opinion"];
    }
    
    WEAKSELF;
    [[HttpClient sharedClient] postApproveNoteWithParams:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        DWDMarkLog(@"postApproveNoteSuccess");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //设置当前结果
            if (weakSelf.buttonState == -1) {
                //同意
                weakSelf.model.state = kStateAgree;
            } else {
                //不同意
                weakSelf.model.state = kStateRefuse;
                //private java.lang.String	opinion
                //审批意见
                weakSelf.model.opinion = weakSelf.refuseReasonStr;
            }
            
            //private java.lang.String	aprdName
            //审批人姓名
            weakSelf.model.aprdName = [DWDCustInfo shared].custNickname;
            //private java.lang.String	aprdTime
            //审批时间
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [NSLocale currentLocale];
            formatter.dateFormat = @"MM-dd HH:mm";
            weakSelf.model.aprdTime = [formatter stringFromDate:[NSDate date]];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.navigationItem.rightBarButtonItem = nil;
                [hud hide:YES];
                [weakSelf.tableView reloadData];
            });
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDMarkLog(@"postApproveNoteFailed");
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"提交失败";
        [hud hide:YES afterDelay:1.5f];
    }];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    switch (indexPath.section) {
        case 0:
            height = 202;
            break;
        case 1:
            height = 44 + 30 + [self labelHeightWithString:@"申请理由" fontSize:14] + [self labelHeightWithString:_model.excuse fontSize:16] + 13;
            break;
        case 2:
            if ([self.model.state isEqualToNumber:kStateNotSure]) {
                height = 84;
            } else {
                height = 132;
            }
            break;
        case 3:
            if ([_model.state isEqualToNumber:kStateRefuse]) {
                //不同意理由
//                return [super tableView:tableView heightForRowAtIndexPath:indexPath];
                return [self labelHeightWithString:_model.opinion fontSize:16] + 43 + [self labelHeightWithString:@"不同意理由:" fontSize:14];
            } else {
                return 120;
            }
            break;
        default:
            return [super tableView:tableView heightForRowAtIndexPath:indexPath];
            break;
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.model.state isEqualToNumber:kStateNotSure]) {
        //未审核
        if (_buttonState == -1) {
            //同意
            return 3;
        } else if (_buttonState == -2) {
            //不同意
            return 4;
        } else {
            //没选
            return 3;
        }
    } else if ([self.model.state isEqualToNumber:kStateAgree] || [self.model.state isEqualToNumber:kStateRefuse]){
        //已审核
        if ([self.model.state isEqualToNumber:kStateAgree]) {
            //同意
            return 3;
        } else {
            //不同意
            return 4;
        }
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DWDLeavePaperCellGroup" owner:nil options:nil];
    if (indexPath.section == 0) {
        DWDLeavePaperHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"headCell"];
        if (!cell) {
            cell = array[[self indexOfClass:[DWDLeavePaperHeadCell class]]];
        }
        cell.model = self.model;
        return cell;
    } else if (indexPath.section == 1) {
        DWDLeavePaperVacateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"vacateCell"];
        if (!cell) {
            cell = array[[self indexOfClass:[DWDLeavePaperVacateCell class]]];
        }
        cell.model = self.model;
        return cell;
    } else if (indexPath.section == 2) {
        //第三栏
        if ([self.model.state isEqualToNumber:kStateNotSure]) {
            //按钮cell
            DWDLeavePaperAproveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aproveCell"];
            if (!cell) {
                cell = array[[self indexOfClass:[DWDLeavePaperAproveCell class]]];
            }
            cell.delegate = self;
            return cell;
        } else {
            //审批cell
            DWDLeavePaperCheckCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkCell"];
            if (!cell) {
                cell = array[[self indexOfClass:[DWDLeavePaperCheckCell class]]];
            }
            cell.model = self.model;
            return cell;
        }
    } else {
        //section == 3
        if ([self.model.state isEqualToNumber:kStateRefuse]) {
            //不同意
            //不同意理由cell
            DWDLeavePaperRefuseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"refuseCell"];
            if (!cell) {
                cell = array[[self indexOfClass:[DWDLeavePaperRefuseCell class]]];
            }
            cell.model = self.model;
            return cell;
        } else {
            //未审核+不同意
            //不同意textview
            DWDLeavePaperTeacherRefuseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"teacherRefuseCell"];
            if (!cell) {
                cell = array[[self indexOfClass:[DWDLeavePaperTeacherRefuseCell class]]];
            }
            cell.delegate = self;
            return cell;
        }
    }
}

#pragma mark - UITableViewDeleagte
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - DWDLeavePaperAproveCellDelegate
- (void)aproveCellDidClickAgreeButton:(DWDLeavePaperAproveCell *)cell {
    _buttonState = -1;
    [self.tableView reloadData];
}

- (void)aproveCellDidClickRefuseButton:(DWDLeavePaperAproveCell *)cell {
    _buttonState = -2;
    [self.tableView reloadData];
}

#pragma mark - DWDLeavePaperTeacherRefuseCellDelegate
- (void)teacherRefuseCell:(DWDLeavePaperTeacherRefuseCell *)cell didChangeText:(NSString *)text {
    _refuseReasonStr = [text trim];
}

@end
