//
//  DWDClassNotificationDetailController.m
//  EduChat
//
//  Created by KKK on 16/5/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

/**
 
 0.cell分为2部分
 0.0 直接分为2个cell
 0.1 固定显示 发通知人的讯息
     浮动显示 通知主题
 0.2 浮动显示 应答人群
 
 1.发送请求
 
 2.显示
 */

#import "DWDClassNotificationDetailController.h"
#import "DWDPersonDataViewController.h"
#import "DWDImagesScrollView.h"
#import "DWDClassNotificationDetailCell.h"

#import "DWDClassModel.h"

#import "DWDClassNotificationDetailModel.h"
#import "DWDClassNotificationDetailLayout.h"

#import <YYModel.h>

@interface DWDClassNotificationDetailController () <DWDClassNotificationDetailCellDelegate, DWDClassNotificationReplyCellDelegate, DWDClassNotificationSegmentControlDelegate>
@property (nonatomic, strong) DWDClassNotificationDetailLayout *layout;

@property (nonatomic, strong) UIBarButtonItem *buttonItem;

@property (nonatomic, weak) DWDClassNotificationSegmentControl *segmentControl;

@end

@implementation DWDClassNotificationDetailController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"通知";
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerClass:[DWDClassNotificationDetailCell class] forCellReuseIdentifier:@"DWDClassNotificationDetailCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView registerClass:[DWDClassNotificationReplyCell class] forCellReuseIdentifier:@"DWDClassNotificationReplyCell"];
    [self requestDetail];
}

#pragma mark - Private Method
- (void)requestDetail {
    NSDictionary *params = @{
                             @"custId" : [DWDCustInfo shared].custId,
                             @"classId" : self.myClass.classId,
                             @"noticeId" : self.noticeId,
                             };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在加载";
    [hud show:YES];
    WEAKSELF;
    [[HttpClient sharedClient] getClassNotificationDetail:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DWDClassNotificationDetailModel *model = [DWDClassNotificationDetailModel yy_modelWithJSON:responseObject[@"data"]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //测试
            /**
            NSMutableArray *ar = [NSMutableArray array];
            for (int i = 0; i < 50; i ++) {
                for (DWDClassNotificationReplyMember *member in model.replys.joins) {
                    [ar addObject:member];
                }
            }
             model.replys.joins = ar;
             */
            weakSelf.layout = [[DWDClassNotificationDetailLayout alloc] initWithModel:model];
            [weakSelf.layout setCompleteSelected:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([model.author.authorId isEqualToNumber:[DWDCustInfo shared].custId] || [weakSelf.myClass.isMian isEqualToNumber:@1]) {
                    weakSelf.navigationItem.rightBarButtonItem = weakSelf.buttonItem;
                } else {
                    weakSelf.navigationItem.rightBarButtonItem = nil;
                }
                
                [weakSelf.tableView reloadData];
                [weakSelf setSegmentTitle];
                [hud hide:YES];
            });
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.labelText = @"加载失败";
//            [hud hide:YES];
            [hud hide:YES afterDelay:1.5f];
        });
    }];
}

- (void)setSegmentTitle {
    NSString *completeTitle;
    NSString *unCompleteTitle;
    if ([_layout.model.notice.type integerValue] == 1) {
        
        completeTitle = [NSString stringWithFormat:@"已读(%zd)", _layout.model.replys.readeds.count];
        unCompleteTitle = [NSString stringWithFormat:@"未读(%zd)", _layout.model.replys.unreads.count];
    } else {
        completeTitle = [NSString stringWithFormat:@"YES(%zd)", _layout.model.replys.joins.count];
        unCompleteTitle = [NSString stringWithFormat:@"NO(%zd)", _layout.model.replys.unjoins.count];
    }
    [self.segmentControl setButtonTitleWithComplete:completeTitle unComplete:unCompleteTitle];
}

//展示 已读(YES)/未读(NO) 之间切换
- (DWDClassNotificationDetailModel *)changeStateWithType:(NSInteger)type {
    DWDClassNotificationDetailModel *model = self.layout.model;
    
//        @property (nonatomic, strong) DWDPhotoMetaModel *photohead;
//        @property (nonatomic, strong) NSNumber *custId;
//        @property (nonatomic, copy) NSString *name;
    DWDClassNotificationReplyMember *member = [DWDClassNotificationReplyMember new];
    DWDPhotoMetaModel *photoHead = [DWDPhotoMetaModel new];
    photoHead.photoKey = [DWDCustInfo shared].custThumbPhotoKey;
    member.photohead = photoHead;
    member.custId = [DWDCustInfo shared].custId;
    member.name = [DWDCustInfo shared].custNickname;
    if (type == 2) {
        DWDClassNotificationReply *reply = model.replys;
        NSMutableArray *knowAr = [reply.readeds mutableCopy];
        NSMutableArray *unknowAr = [reply.unreads mutableCopy];
        
        [knowAr addObject:member];
        NSInteger index = -1;
        for (DWDClassNotificationReplyMember *enumMember in unknowAr) {
            if ([enumMember.custId isEqualToNumber:[DWDCustInfo shared].custId]) {
                index = [unknowAr indexOfObject:enumMember];
                break;
            }
        }
        if (index != -1) {
            [unknowAr removeObjectAtIndex:index];
        }
        reply.readeds = knowAr;
        reply.unreads = unknowAr;
        model.replys = reply;
        return model;
    } else {
            DWDClassNotificationReply *reply = model.replys;
            NSMutableArray *yesAr = [reply.joins mutableCopy];
            NSMutableArray *noAr = [reply.unjoins mutableCopy];
        
        if (type == 1) {
            
            [yesAr addObject:member];
            NSInteger index = -1;
            for (DWDClassNotificationReplyMember *enumMember in noAr) {
                if ([enumMember.custId isEqualToNumber:[DWDCustInfo shared].custId]) {
                    index = [noAr indexOfObject:enumMember];
                    break;
                }
            }
            if (index != -1) {
                [noAr removeObjectAtIndex:index];
            }
            reply.joins = yesAr;
            reply.unjoins = noAr;
            model.replys = reply;
            
        } else if (type == 0) {
            [noAr addObject:member];
            NSInteger index = -1;
            for (DWDClassNotificationReplyMember *enumMember in yesAr) {
                if ([enumMember.custId isEqualToNumber:[DWDCustInfo shared].custId]) {
                    index = [yesAr indexOfObject:enumMember];
                    break;
                }
            }
            if (index != -1) {
                [yesAr removeObjectAtIndex:index];
            }
            reply.joins = yesAr;
            reply.unjoins = noAr;
            model.replys = reply;
        }
    }
    
    
    
    return model;
}

#pragma mark - Event Response
- (void)rightBarButtonItemDidClick {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    WEAKSELF;
    
//    custId	√	long	(0,)	用户id
//    classId	√	long	(0,)	班级id
//    noticeId	√	long[]		通知id列表

    
    NSDictionary *dict = @{
                           @"custId" : [DWDCustInfo shared].custId,
                           @"classId" : self.myClass.classId,
                           @"noticeId" : @[self.noticeId],
                           };
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//#error delete action
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"正在删除...";
        [hud show:YES];
        [[HttpClient sharedClient] postDeleteClassNotification:dict success:^(NSURLSessionDataTask *task, id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"删除成功";
                [hud show:YES];
                [hud hide:YES afterDelay:1.0f];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            });
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"删除失败";
                [hud show:YES];
                [hud hide:YES afterDelay:1.5f];
            });
        }];
    }];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:action];
    [alertController addAction:action1];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_layout == nil) {
        return 0;
    } else {
        if (![DWDCustInfo shared].isTeacher) {
            return 1;
        } else {
    return 3;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 0;
    if (indexPath.row == 0) {
        return _layout.contentHeight;
    } else if (indexPath.row == 1) {
        return kReplyCellSegmentHeight + kContentCellPadding;
    } else {
        if (_layout.isCompleteSelected) {
            return _layout.completeHeight;
        } else {
            return _layout.uncompleteHeight;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        //
        DWDClassNotificationDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDClassNotificationDetailCell"];
        cell.delegate = self;
        cell.readed = _readed;
        [cell setLayout:_layout];
        return cell;
    } else if (indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        cell.backgroundColor = DWDColorBackgroud;
        if (!_segmentControl) {
            DWDClassNotificationSegmentControl *view = [[DWDClassNotificationSegmentControl alloc] initWithFrame:CGRectMake(0, kContentCellPadding, DWDScreenW, kReplyCellSegmentHeight)];
            view.delegate = self;
            _segmentControl = view;
            [cell.contentView addSubview:view];
        }
        [self setSegmentTitle];
        return cell;
    } else {
        DWDClassNotificationReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDClassNotificationReplyCell"];
        cell.delegate = self;
        [cell setLayout:_layout];
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - DWDClassNotificationDetailCellDelegate

- (void)detailCell:(DWDClassNotificationDetailCell *)cell didCLickImgView:(UIImageView *)imgView atIndex:(NSInteger)index {
    if ([self.tableView isDecelerating]) return;
    
    NSMutableArray *picsArray = [NSMutableArray array];
    for (DWDClassNotificationPhotos *photo in _layout.model.notice.photos) {
        [picsArray addObject:photo.photo];
    }
    DWDImagesScrollView *scrollView = [[DWDImagesScrollView alloc] initWithPhotoMetaArray:picsArray];
    [scrollView presentViewFromImageView:imgView atIndex:index toContainer:self.view];
}

- (void)detailCell:(DWDClassNotificationDetailCell *)cell didClickButtonWithType:(NSInteger)type {
    NSDictionary *dict = @{
                           @"custId" : [DWDCustInfo shared].custId,
                           @"classId" : self.myClass.classId,
                           @"noticeId" : self.noticeId,
                           @"item" : [NSNumber numberWithInteger:type],
                           };
    WEAKSELF;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    hud.labelText = @"请稍候";
    [hud show:YES];
    [[HttpClient sharedClient] postUpdateClassNotificationReplyState:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        //根据type添加到正确位置
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            weakSelf.readed = @1;
            DWDClassNotificationDetailModel *model = [weakSelf changeStateWithType:type];
            weakSelf.layout = [[DWDClassNotificationDetailLayout alloc] initWithModel:model];
            weakSelf.layout.completeSelected = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                [weakSelf.tableView reloadData];
            });
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            [weakSelf.tableView reloadData];
        });
    }];
}

#pragma mark - DWDClassNotificationReplyCellDelegate

- (void)replyCell:(DWDClassNotificationReplyCell *)cell didClickMember:(NSNumber *)custId {
    DWDMarkLog(@"%s", __func__);
    if (custId) {
        DWDPersonDataViewController *vc = [[DWDPersonDataViewController alloc] init];
        vc.custId = custId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)segmentControlDidClickCompleteButton {
    DWDMarkLog(@"%s", __func__);
    if (self.layout.completeSelected) return;
    [self.layout setCompleteSelected:YES];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]]
                          withRowAnimation:self.layout.model.replys.joins.count || self.layout.model.replys.readeds.count ? UITableViewRowAnimationRight :UITableViewRowAnimationNone];
}

- (void)segmentControlDidClickUnCompleteButton {
    DWDMarkLog(@"%s", __func__);
    if (!self.layout.completeSelected) return;
    [self.layout setCompleteSelected:NO];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]]
                          withRowAnimation:self.layout.model.replys.unjoins.count || self.layout.model.replys.unreads.count ? UITableViewRowAnimationLeft :UITableViewRowAnimationNone];
}


#pragma mark - Setter / Getter

- (UIBarButtonItem *)buttonItem {
    if (nil == _buttonItem) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_normal"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(rightBarButtonItemDidClick)];
        
        _buttonItem = item;
    }
    
    return _buttonItem;
}




@end
