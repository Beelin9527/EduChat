//
//  DWDHomeworksDetailViewController.m
//  EduChat
//
//  Created by apple on 16/4/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDHomeworksDetailViewController.h"
#import "DWDHomeWorkDetailsCell.h"
#import "DWDHomeWorkReadCell.h"
#import "DWDHomeWorkClient.h"
#import "DWDHomeWorkDetailModel.h"
#import "DWDImagesScrollView.h"
#import "DWDPersonDataViewController.h"
#import "DWDClassModel.h"

#define DWDNeedUpateHomeWorkList @"need_update_home_work_list"

@interface DWDHomeworksDetailViewController () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, DWDHomeWorkDetailsCellDelegate>

@property (nonatomic, strong) UITableView            *tableView;
@property (nonatomic, strong) UIView                 *readSegView;
@property (nonatomic, strong) UIButton               *hasReadBtn;
@property (nonatomic, strong) UIButton               *notReadBtn;

@property (nonatomic, strong) DWDHomeWorkClient      *homeWorkClient;
@property (nonatomic, strong) DWDHomeWorkDetailModel *homeWorkModel;
@property (nonatomic, strong) NSDictionary           *homeWorkDatas;
@property (nonatomic, strong) NSMutableArray         *finishArray;
@property (nonatomic, strong) NSMutableArray         *unFinishArray;
@property (nonatomic, strong) NSArray                *readers;
@property (nonatomic, assign) CGFloat                readCellHeight;
@property (nonatomic, assign) CGFloat                detailCellHeight;

@end

@implementation DWDHomeworksDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"作业";
    [self setSubviews];
    [self getData];
}

- (void)setSubviews
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, DWDScreenH - 64.0f) style:UITableViewStylePlain];
    _tableView.tableFooterView              = [[UIView alloc] init];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle               = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource                   = self;
    _tableView.delegate                     = self;
    [self.view addSubview:_tableView];
}

- (void)getData
{
    _homeWorkClient = [[DWDHomeWorkClient alloc] init];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"Loading", nil);
    [self.homeWorkClient fetchHomeWorkBy:[DWDCustInfo shared].custId
                                 classId:self.classId
                              homeWorkId:self.homeWorkId
                                 success:^(NSDictionary *homeWork) {
                                     
                                     self.homeWorkDatas          = homeWork;

                                     NSDictionary *homeWorkInfo  = self.homeWorkDatas[@"homework"];
                                     NSDictionary *author        = self.homeWorkDatas[@"author"];

                                     self.homeWorkModel          = [[DWDHomeWorkDetailModel alloc] init];
                                     self.homeWorkModel.title    = homeWorkInfo[@"title"];
                                     self.homeWorkModel.content  = homeWorkInfo[@"content"];
                                     self.homeWorkModel.deadLine = homeWorkInfo[@"collectTime"];
                                     self.homeWorkModel.subject  = self.subject;
                                     self.homeWorkModel.name     = author[@"name"];
                                     self.homeWorkModel.addTime  = author[@"addTime"];

                                     NSArray *attachmentPaths    = homeWork[@"attachments"];
                                     NSMutableArray *picsArray   = [NSMutableArray array];
                                     
                                     for (NSDictionary *photoDict in attachmentPaths) {
                                         DWDPhotoMetaModel *photoModel = [[DWDPhotoMetaModel alloc] init];
                                         photoModel.width              = [photoDict[@"fileInfo"][@"width"] floatValue];
                                         photoModel.height             = [photoDict[@"fileInfo"][@"height"] floatValue];
                                         photoModel.size               = [photoDict[@"fileInfo"][@"size"] floatValue];
                                         photoModel.photoKey           = photoDict[@"fileInfo"][@"photoKey"];
                                         [picsArray addObject:photoModel];
                                     }
                                     self.homeWorkModel.picsArray = picsArray;

                                     self.finishArray             = [NSMutableArray arrayWithArray:self.homeWorkDatas[@"finished"]];
                                     self.unFinishArray           = [NSMutableArray arrayWithArray:self.homeWorkDatas[@"unfinish"]];
                                     
                                     for (NSDictionary *finisher in self.finishArray) {
                                         if ([finisher[@"custId"] isEqual:[DWDCustInfo shared].custId]) {
                                             self.homeWorkModel.isFinished = YES;
                                             break;
                                         }
                                     }
                                     
                                     self.readers = self.finishArray;
                                     
                                     if ([[DWDCustInfo shared].custId isEqual:author[@"authorId"]] || [self.classModel.isMian isEqual:@"1"]) {
                                         self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_normal"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarBtnClick)];
                                     }
                                     [_hasReadBtn setTitle:[NSString stringWithFormat:@"已完成(%lu)",[self.finishArray count]] forState:UIControlStateNormal];
                                     [_notReadBtn setTitle:[NSString stringWithFormat:@"未完成(%lu)",[self.unFinishArray count]] forState:UIControlStateNormal];
                                     
                                     [hud hide:YES];
                                     
                                     [self.tableView reloadData];
                                     
                                 } failure:^(NSError *error) {
                                     
                                     hud.mode      = MBProgressHUDModeText;
                                     hud.labelText = @"该作业已被删除";
                                     [hud hide:YES afterDelay:1];
                                     if ([error.userInfo[@"NSLocalizedFailureReason"] isEqualToString:@"输入数据无效"]) {
                                         [self.navigationController popViewControllerAnimated:YES];
                                         self.popBlock ? self.popBlock() : nil;
                                     }
                                     
                                 }];

}

- (void)rightBarBtnClick
{
    UIActionSheet *myActionSheet = [[UIActionSheet alloc]
                                    initWithTitle:nil
                                    delegate:self
                                    cancelButtonTitle:@"取消"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles: @"删除",nil];
    
    [myActionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    

    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        DWDLog(@"取消");
    }
    
    switch (buttonIndex)
    {
        case 0:
            [self deleteHomeWork];
        break;
    }
}

- (void)deleteHomeWork
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText      = @"正在删除...";
    
    [self.homeWorkClient deleteHomeWorkBy:[DWDCustInfo shared].custId classId:self.classId homeWorkIds:@[self.homeWorkId] success:^{
        
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"删除成功";
        [hud hide:YES afterDelay:0.5];
        [[NSNotificationCenter defaultCenter] postNotificationName:DWDNeedUpateHomeWorkList object:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
        
    } failure:^(NSError *error) {
        
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"删除失败";
        [hud hide:YES afterDelay:0.5];
        
    }];
}

#pragma mark - TableView Delegate && DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([[DWDCustInfo shared].custIdentity isEqual:@6]) {
        return 2;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *lastCell;
    
    if (indexPath.section == 0) {
        
        DWDHomeWorkDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDHomeWorkDetailsCell class])];
        if (!cell) {
            cell = [[DWDHomeWorkDetailsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([DWDHomeWorkDetailsCell class])];
        }
        [self fillCell:cell];
        [cell layoutIfNeeded];
        self.detailCellHeight = [cell getHeight];
        cell.delegate = self;
        [cell.finishBtn addTarget:self action:@selector(finishBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        lastCell = cell;
        
    }else if (indexPath.section == 1) {
    
        static NSString *ID = @"deadlineCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deadlineCell"];
        if (!cell) {
            cell                = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [[cell viewWithTag:998] removeFromSuperview];
        [[cell viewWithTag:999] removeFromSuperview];
        
        UILabel *deadLineTitleLbl  = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 44)];
        deadLineTitleLbl.font      = DWDFontBody;
        deadLineTitleLbl.textColor = DWDRGBColor(153, 153, 153);
        deadLineTitleLbl.text      = @"上交时间";
        deadLineTitleLbl.tag       = 998;

        UILabel *deadLineLbl       = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, DWDScreenW - 100, 44)];
        deadLineLbl.font           = DWDFontBody;
        deadLineLbl.textColor      = DWDRGBColor(51, 51, 51);
        deadLineLbl.textAlignment  = NSTextAlignmentRight;
        deadLineLbl.text           = self.homeWorkModel.deadLine;
        deadLineLbl.tag            = 999;
        
        [cell addSubview:deadLineTitleLbl];
        [cell addSubview:deadLineLbl];
        lastCell = cell;
    }
    
    
    else {
        static NSString *ID = @"finishCell";
        DWDHomeWorkReadCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[DWDHomeWorkReadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([DWDHomeWorkReadCell class])];
        }
        cell.peoples = self.readers;
        [cell setHomeWorkReadCellBlock:^(NSNumber *custId) {
            
            DWDPersonDataViewController *personVC = [[DWDPersonDataViewController alloc] init];
            personVC.custId = custId;
            [self.navigationController pushViewController:personVC animated:YES];
        }];
        [cell layoutIfNeeded];
        self.readCellHeight = [cell getHeight];
        lastCell = cell;
    }
    
    return lastCell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if (indexPath.section == 0) {
        
        DWDHomeWorkDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDHomeWorkDetailsCell class])];
        
        [self fillCell:cell];
        [cell layoutIfNeeded];
        height = self.detailCellHeight;
    }else if (indexPath.section == 1) {
    
        height = 44;
    }else {

        NSArray *finished = self.readers;
        if (finished.count == 0) {
            height = 80;
        } else {
            height = self.readCellHeight;
            
        }

    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        return 44.0;
    } else {
        return 0.000001;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        return 10.0;
    }else {
        return 0.000001;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        return self.readSegView;
    }else {
        return nil;
    }
}

- (UIView *)readSegView
{
    if (!_readSegView) {
        
        _readSegView = [[UIView alloc] init];
        _readSegView.frame = CGRectMake(0, 0, DWDScreenW, 44.0);
        _readSegView.backgroundColor = [UIColor whiteColor];
        
        UIButton *hasReadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        hasReadBtn.frame = CGRectMake(0, 0, DWDScreenW * 0.5, 44.0);
        [hasReadBtn setTitle:@"未完成" forState:UIControlStateNormal];
        [hasReadBtn setTitleColor:DWDRGBColor(102, 102, 102) forState:UIControlStateNormal];
        [hasReadBtn setTitleColor:DWDRGBColor(90, 136, 231) forState:UIControlStateSelected];
        hasReadBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [hasReadBtn addTarget:self action:@selector(readBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *notReadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        notReadBtn.frame = CGRectMake(DWDScreenW * 0.5, 0, DWDScreenW * 0.5, 44.0);
        [notReadBtn setTitle:@"已完成" forState:UIControlStateNormal];
        [notReadBtn setTitleColor:DWDRGBColor(102, 102, 102) forState:UIControlStateNormal];
        [notReadBtn setTitleColor:DWDRGBColor(90, 136, 231) forState:UIControlStateSelected];
        notReadBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [notReadBtn addTarget:self action:@selector(readBtnClick:) forControlEvents:UIControlEventTouchUpInside];

        UIView *midLine            = [[UIView alloc] init];
        midLine.frame              = CGRectMake(DWDScreenW * 0.5, 10, 1, 24.0);
        midLine.backgroundColor    = DWDColorSeparator;

        UIView *bottomLine         = [[UIView alloc] init];
        bottomLine.frame           = CGRectMake(0, 43.5, DWDScreenW, 0.5);
        bottomLine.backgroundColor = DWDColorSeparator;
        
        hasReadBtn.selected = YES;
        notReadBtn.selected = NO;
        
        _hasReadBtn = hasReadBtn;
        _notReadBtn = notReadBtn;
        
        [_readSegView addSubview:hasReadBtn];
        [_readSegView addSubview:notReadBtn];
        [_readSegView addSubview:midLine];
        [_readSegView addSubview:bottomLine];
    }
    return _readSegView;
}

- (void)readBtnClick:(UIButton *)sender
{
    if (sender.selected == YES)
        return;
    
    if (sender == _hasReadBtn) {
        
        _hasReadBtn.selected = YES;
        _notReadBtn.selected = NO;
        self.readers = self.finishArray;
        
    }else {
        
        _hasReadBtn.selected = NO;
        _notReadBtn.selected = YES;
        self.readers = self.unFinishArray;
    }
    [self.tableView reloadData];
}

- (void)fillCell:(DWDHomeWorkDetailsCell *) cell {

    cell.homeWorkModel = self.homeWorkModel;
}

- (void)finishBtnAction:(UIButton *)sender
{
    sender.backgroundColor = DWDColorSeparator;
    sender.enabled = NO;
    
    [[[DWDHomeWorkClient alloc] init] finishHomeworkBy:[DWDCustInfo shared].custId classId:self.classId homeworkId:@[self.homeWorkId] success:^{
        
//        for (int i = 0; i < [self.unFinishArray count]; i ++) {
//            if ([self.unFinishArray[i][@"custId"] isEqual:[DWDCustInfo shared].custId]) {
//                
//                NSDictionary *dict = [self.unFinishArray objectAtIndex:i];
//                [self.unFinishArray removeObjectAtIndex:i];
//                [self.finishArray addObject:dict];
////                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
////                [self.tableView reloadData];

//                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
//                [_hasReadBtn setTitle:[NSString stringWithFormat:@"已完成(%lu)",[self.finishArray count]] forState:UIControlStateNormal];
//                [_notReadBtn setTitle:[NSString stringWithFormat:@"未完成(%lu)",[self.unFinishArray count]] forState:UIControlStateNormal];
//                break;
//            }
//        }
        
    } failure:^(NSError *error) {

    }];
    
}

/**
 *  点击了图片
 */

- (void)growCell:(DWDHomeWorkDetailsCell *)cell didClickImageView:(UIImageView *)imgView withIndex:(NSInteger)index {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (indexPath == nil) return;
    
    DWDImagesScrollView *scrollView = [[DWDImagesScrollView alloc] initWithPhotoMetaArray:self.homeWorkModel.picsArray];
    
    [scrollView presentViewFromImageView:imgView atIndex:index toContainer:self.view];
}


@end
