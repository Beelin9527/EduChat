//
//  DWDTeacherGoSchoolViewController.m
//  EduChat
//
//  Created by KKK on 16/3/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

/*
 上学页面使用的是同一个tableView 使用一个状态作为监听是展示哪个
 放学页面使用的是4个talbeView 每一个都有自己的数据源方法,要在父页面监听
 */

/*
 
 由于特殊需求 上学页面的展示全部由网络请求获得
 放学页面家长段以及时间轴全部有本地数据库数据生成
 
 */



#define kInfoCellId @"infoViewCell"
#define kpicSucceedCellId @"picViewSucceedCell"
#define kpicCellFailedId  @"picViewFailedCell"

#import "DWDTeacherGoSchoolViewController.h"
#import "DWDSegmentedControl.h"

#import "DWDPickUpCenterHelper.h"

#import "DWDGoSchoolInfoView.h"
#import "DWDTeacherGoSchoolSucceedCell.h"
#import "DWDTeacherGoSchoolFailedCell.h"

#import "DWDPickUpCenterBackgroundContainerView.h"
#import "DWDPUCLoadingView.h"

#import "DWDPickUpCenterDatabaseTool.h"

#import "DWDTeacherGoSchoolStudentDetailModel.h"
#import "DWDTeacherGoSchoolInfoModel.h"
#import "DWDPickUpCenterDataBaseModel.h"
#import "DWDPickUpCenterTotalStudentsModel.h"

#import "NSString+extend.h"

#import <YYModel.h>

@interface DWDTeacherGoSchoolViewController () <DWDSegmentedControlDelegate, DWDPUCLoadingViewDelegate>

//view
@property (nonatomic, strong) DWDSegmentedControl *segmentControl;
//Yes 已到校
//No 未到校
@property (nonatomic, assign) BOOL segmentSelectedState;
@property (nonatomic, weak) DWDGoSchoolInfoView *infoView;

@property (nonatomic, weak) DWDPickUpCenterBackgroundContainerView *bgBlankImageView;
@property (nonatomic, weak) DWDPUCLoadingView *loadingView;
@property (nonatomic, copy) NSString *blankViewText;
@property (nonatomic, assign) NSInteger lastSegmentIndex;

//succeed data
@property (nonatomic, strong) NSArray *succeedStudentsDataArray;
//failed data
@property (nonatomic, strong) NSArray *failedStudentsDataArray;
//info
@property (nonatomic, strong) DWDTeacherGoSchoolInfoModel *studentsInfoModel;
//vacate
@property (nonatomic, assign) NSInteger vacateCount;




@end

@implementation DWDTeacherGoSchoolViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    _requestFailed = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.estimatedRowHeight = 200;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    
    // Do any add    self.view.backgroundColor = [UIColor grayColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kInfoCellId];
    [self.tableView registerClass:[DWDTeacherGoSchoolSucceedCell class] forCellReuseIdentifier:kpicSucceedCellId];
    [self.tableView registerClass:[DWDTeacherGoSchoolFailedCell class] forCellReuseIdentifier:kpicCellFailedId];
    
    self.tableView.backgroundColor = UIColorFromRGB(0xf5f5f5);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    [self segmentedControlIndexButtonView:self.segmentControl index:_lastSegmentIndex];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadNotificationReceived:)
                                                 name:DWDPickUpCenterDidUpdateTeacherGoSchool
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DWDPickUpCenterDidUpdateTeacherGoSchool
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.succeedStudentsDataArray.count + 1;
//    if (self.succeedStudentsDataArray.count && self.failedStudentsDataArray.count) {
//        [self.bgBlankImageView removeFromSuperview];
//        return 0;
//    }
//        [self.bgBlankImageView setNeedsDisplay];
    NSInteger count;
    if (self.segmentSelectedState == YES) {
        count = self.succeedStudentsDataArray.count / 2;
        if (!(self.succeedStudentsDataArray.count % 2 == 0)) {
            count += 1;
        }
        
        if (self.succeedStudentsDataArray.count == 0) {
            if (_isFirstRequest == NO && _requestFailed == NO) {
                self.bgBlankImageView.infoLabel.text = _blankViewText;
            }
            return 0;
        } else {
            [_bgBlankImageView removeFromSuperview];
            return count + 1;
        }
    }
    else {
        count = self.failedStudentsDataArray.count / 4;
        if (!(self.failedStudentsDataArray.count % 4 == 0)) {
            count += 1;
        }
        
        if (self.failedStudentsDataArray.count == 0) {
            if (_isFirstRequest == NO && _requestFailed == NO) {
                self.bgBlankImageView.infoLabel.text = _blankViewText;
            }
            return 0;
        }
        else {
            [_bgBlankImageView removeFromSuperview];
            return count + 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kInfoCellId];
        if (_infoView == nil) {
            DWDGoSchoolInfoView *infoView = [[DWDGoSchoolInfoView alloc] initWithFrame:CGRectMake(0, pxToW(20), DWDScreenW, pxToH(136))];
            [cell.contentView addSubview:infoView];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.backgroundColor = [UIColor clearColor];
            _infoView = infoView;
            [cell setH:pxToH(136)];
        }
        _infoView.infoModel = [self calculateInfoViewLabels];
        cell.userInteractionEnabled = NO;
        return cell;
    } else {
        
        if (self.segmentSelectedState == YES) {
            //已到校
            DWDTeacherGoSchoolSucceedCell *cell = [tableView dequeueReusableCellWithIdentifier:kpicSucceedCellId];
            //传递数组
            NSRange range = NSMakeRange((indexPath.row - 1) * 2, 2);
            if ((indexPath.row * 2) > self.succeedStudentsDataArray.count) {
                range.length = 1;
            }
            cell.dataArray = [self.succeedStudentsDataArray subarrayWithRange:range];
            cell.userInteractionEnabled = NO;
            return cell;
            
        } else {
            //未到校
            DWDTeacherGoSchoolFailedCell *cell = [tableView dequeueReusableCellWithIdentifier:kpicCellFailedId];
            
            NSRange range = NSMakeRange((indexPath.row - 1) * 4, 4);
            NSInteger value = indexPath.row * 4 - self.failedStudentsDataArray.count;
            switch (value) {
                case 3:
                    range.length = 1;
                    break;
                case 2:
                    range.length = 2;
                    break;
                case 1:
                    range.length = 3;
                    break;
                    
                default:
                    range.length = 4;
                    break;
            }
            cell.dataArray = [self.failedStudentsDataArray subarrayWithRange:range];
            
            cell.userInteractionEnabled = NO;
            return cell;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.segmentControl;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return pxToH(136) + pxToW(40);
    } else
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == 0) {
//        return pxToH(136);
//    } else
//        return pxToH(350);
//}

#pragma mark - private method
//监听到新消息

/*
 */
- (void)reloadNotificationReceived:(NSNotification *)note {
    if (note == nil) {
        [self requestOrCache];
    } else {
        NSNumber *classId = note.userInfo[@"classId"];
        if ([_classId isEqualToNumber:classId]) {
            [self requestOrCache];
        }
    }
}

- (void)requestOrCache {
    //首先请求数据
    [self.tableView reloadData];
    
    if ([DWDPickUpCenterHelper isNecessaryToNewRequestWithClassId:_classId]) {
        [self needRequest];
    } else {
        NSString *key = [DWDPickUpCenteruserDefaultPickUpCenterTodayStudentsKey stringByAppendingString:[NSString stringWithFormat:@"_%@_%@", _classId, [DWDCustInfo shared].custId]];
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        DWDPickUpCenterTotalStudentsModel *totalModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.index = totalModel.index;
        [self setSucceedAndFailedArrayWithTotalArrayModel:totalModel];
    }
}

- (void)needRequest {
    /*
     发送请求
     根据请求下来的数据
     分成 成功数组 和 失败数组
     在请求里面调用一个方法进行处理
     **/
    DWDPUCLoadingView *loadingView;
    if (_isFirstRequest && _loadingView == nil) {
        //310 * 271
        loadingView = [[DWDPUCLoadingView alloc] initWithFrame:(CGRect){(DWDScreenW - 310 * 0.5) * 0.5, (DWDScreenH - 271 + 20 +46 * 0.5) * 0.5, 310 * 0.5, 271 + 20 + 46 * 0.5}];
        loadingView.delegate = self;
//        loadingView.center = self.tableView.center;
        [self.tableView insertSubview:loadingView aboveSubview:self.tableView];
        loadingView.layer.zPosition = MAXFLOAT;
        _loadingView = loadingView;
    }
    
    NSDictionary *params = @{@"classId": self.classId};
    
//    [[HttpClient sharedClient] cancelTaskWithApi:@"punch/getPickupchild"];
    //获取当天状态
    WEAKSELF;

    [[HttpClient sharedClient] getPickUpCenterStudentsStatusWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.requestFailed = NO;
            weakSelf.isFirstRequest = NO;
            [weakSelf.tableView reloadData];
            [weakSelf.loadingView removeFromSuperview];
        });
        
        /*
         responseObject结构
         type:  //nsnumber
         index: //nsnumber
         students:  //数组
         deadline://请求缓存有效期
         **/
        DWDMarkLog(@"punch go student Success");
        DWDPickUpCenterTotalStudentsModel *model = [DWDPickUpCenterTotalStudentsModel yy_modelWithDictionary:responseObject[@"data"]];
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.locale = [NSLocale currentLocale];
        formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
        model.deadline = [formatter dateFromString:responseObject[@"data"][@"deadline"]];
        model.dateTime = [NSDate date];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
        NSString *key = [DWDPickUpCenteruserDefaultPickUpCenterTodayStudentsKey stringByAppendingString:[NSString stringWithFormat:@"_%@_%@", weakSelf.classId, [DWDCustInfo shared].custId]];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
        
//        if (![model.type isEqualToNumber:@1]) return;
//        ar = [NSArray yy_modelArrayWithClass:[DWDTeacherGoSchoolStudentDetailModel class] json:responseObject[@"data"][@"students"]];
        weakSelf.index = model.index;
        [weakSelf setSucceedAndFailedArrayWithTotalArrayModel:model];
//        NSMutableArray *successArray = [NSMutableArray new];
//        NSMutableArray *failedArray = [NSMutableArray new];
//        for (DWDTeacherGoSchoolStudentDetailModel *model in ar) {
//            weakSelf.index = model.index;
//            
//            if ([model.contextual isEqualToString:@"Reachschool"]) {
//                //成功
//                [successArray addObject:model];
//            }
////            } else if([model.contextual isEqualToString:@""]) {
//            else {
//                //失败
//                [failedArray addObject:model];
//            }
//        }
//        weakSelf.succeedStudentsDataArray = successArray;
//        weakSelf.failedStudentsDataArray = failedArray;
//        weakSelf.totalStudentsArray = ar;

        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDMarkLog(@"punch go student Failed");
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.requestFailed = YES;
            weakSelf.isFirstRequest = NO;
//            [loadingView removeFromSuperview];
            if ([weakSelf.loadingView respondsToSelector:@selector(changeToFailedView)]) {
                [weakSelf.loadingView changeToFailedView];
            }
            if (weakSelf.segmentSelectedState == YES) {
                weakSelf.blankViewText = @"暂无已到校的学生";
            } else {
                weakSelf.blankViewText = @"暂无未到校的学生";
            }
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)setSucceedAndFailedArrayWithTotalArrayModel:(DWDPickUpCenterTotalStudentsModel *)TotalModel {
//    if (![TotalModel.type isEqualToNumber:@1]) {
//        return;
//    }
    //    NSMutableArray *succeedArray = [NSMutableArray array];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *messageArray = [[[DWDPickUpCenterDatabaseTool sharedManager] selectWhichDate:[NSString getTodayDateStr] type:@1 index:TotalModel.index teacherDataBaseWithClassId:_classId] copy];
        NSMutableArray *succeedArray = [NSMutableArray array];
        NSMutableArray *failedArray = [NSMutableArray array];
        /*
         所有数据过一遍
         先判断是不是上学
         再根据contextual判断应该add到哪个
         
         显示需要数据
         - 照片
         - 实时照片
         - 名字
         - 请假状态
         **/
        //    for (DWDTeacherGoSchoolStudentDetailModel *model in totalArray) {
        //        if (model.leave != 0) {
        //            [failedArray addObject:model];
        //            break;
        //        } else {
        //            DWDPickUpCenterDataBaseModel *dbModel = [DWDPickUpCenterDataBaseModel new];
        //            dbModel.photokey = model.photohead.photoKey;
        //            dbModel.photo = model.punchPhoto.photoKey;
        //            dbModel.name = model.name;
        //            [succeedArray addObject:dbModel];
        //        }
        //    }
        /**
         如何判断拿到的请求和消息分辨
         现有情况
         成功人数 消息中的 (最新)
         成功人数 请求中的 (只有一次请求)
         失败人数 请求中的 (一次就获得)
         
         把消息中的数据跟请求中的匹配,根据消息的custId索引 改变请求中的数据
         
         循环请求模型数组 循环中
         每次与消息数据遍历 如果模型id和消息id匹配
         那么 拿到的状态就是新的状态 更改状态直接起一个数组 添加新的模型
         得到新数组就是成功数组 失败数组放置在failArray中
         
         
         问题1:如何拿到根据custId索引到的模型 (嵌套遍历)
         */
        //    for (DWDTeacherGoSchoolStudentDetailModel *model in totalArray) {
        //        if (![succeedCustIdArray containsObject:model.custId]) {
        //            [failedArray addObject:model];
        //            continue;
        //        }
        //        if ([model.contextual isEqualToString:@"Reachschool"]) {
        //            //成功
        //            [succeedArray addObject:model];
        //            continue;
        //        }
        //        if (model.leave != 0) {
        //            [failedArray addObject:model];
        //            continue;
        //        }
        //    }
        NSInteger vacate = 0;
        for (DWDTeacherGoSchoolStudentDetailModel *model in TotalModel.students) {
            if (model.leave == 1 || model.leave == 2) {
                vacate += 1;
            }
            if (model.leave != 0) {
                [failedArray addObject:model];
                continue;
            }
            if ([model.contextual isEqualToString:@"Reachschool"]) {
                [succeedArray addObject:model];
                continue;
            }
            BOOL success = NO;
            for (DWDPickUpCenterDataBaseModel *dbModel in messageArray) {
                if ([dbModel.custId isEqualToNumber:model.custId]) {
                    //说明获得了新消息 这时候model应该在total里面 并且状态不是reachSchool 把他的状态修改成reachSchrool 并且把其他需要的值赋过去
                    //能在这个if的代码块里,肯定不会是请假和未到校的!
                    //                @property (nonatomic, copy) NSNumber *custId;
                    //                @property (nonatomic, copy) NSString *educhatAccount;
                    //                @property (nonatomic, copy) NSString *name;
                    //                @property (nonatomic, copy) NSString *nickname;
                    //                @property (nonatomic, strong) NSNumber *index;
                    //                @property (nonatomic, strong) DWDPhotoMetaModel *photohead;
                    //                @property (nonatomic, strong) DWDPhotoMetaModel *punchPhoto;
                    //                //0-未请假 1 事假；2 病假；3 其他
                    //                @property (nonatomic, assign) int leave;
                    //                @property (nonatomic, copy) NSString *contextual;
                    //            dbModel.photokey = model.photohead.photoKey;
                    //            dbModel.photo = model.punchPhoto.photoKey;
                    //            dbModel.name = model.name;
                    DWDTeacherGoSchoolStudentDetailModel *newModel = [model copy];
                    newModel.photohead.photoKey = dbModel.photokey;
                    newModel.punchPhoto.photoKey = dbModel.photo;
                    newModel.name = model.name;
                    [succeedArray addObject:newModel];
                    success = YES;
                    break;
                }
            }
            if (success == NO) {
                [failedArray addObject:model];
            }
        }
    //不是上学
        self.vacateCount = vacate;
        self.succeedStudentsDataArray = succeedArray;
        self.failedStudentsDataArray = failedArray;
        self.totalStudentsArray = TotalModel.students;
    self.infoView.infoModel = [self calculateInfoViewLabels];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
//    });
}

/*
 收到消息和第一次进去 的时候 需要计算infoview的label显示数值
 */
- (DWDTeacherGoSchoolInfoModel *)calculateInfoViewLabels {
//    @property (nonatomic, assign) NSInteger totalStudent;
//    @property (nonatomic, assign) NSInteger succeedCount;
//    @property (nonatomic, assign) NSInteger vacateCount;
//    @property (nonatomic, assign) double attendanceRate;
    DWDTeacherGoSchoolInfoModel *infoModel = [[DWDTeacherGoSchoolInfoModel alloc] init];
    infoModel.totalStudent = self.totalStudentsArray.count;
    infoModel.succeedCount = self.succeedStudentsDataArray.count;
    infoModel.vacateCount = self.vacateCount;
    CGFloat rate = self.succeedStudentsDataArray.count / 1.0 / infoModel.totalStudent;
    infoModel.attendanceRate = rate;
    return infoModel;
}


- (void)setGoSchoolSucceedData {
    //重新获取数据
    self.segmentSelectedState = YES;
    
}

- (void)setGoSchoolFailedData {
    self.segmentSelectedState = NO;
//    [self reloadNotificationReceived];
}

//返回一个处理好的数组
//删除从网络获取的未到达列表中已经成功的人
- (NSArray *)removeSameCustIdObject:(NSArray *)ar {
    //返回一个custid不相同的列表
    NSMutableArray *mAr = [NSMutableArray new];
    
    for (int i = 0; i < ar.count; i ++) {
        DWDTeacherGoSchoolStudentDetailModel *detailModel = ar[i];
        BOOL flag = NO;
        for (DWDPickUpCenterDataBaseModel *model in self.succeedStudentsDataArray) {
            if ([model.custId isEqualToNumber:detailModel.custId]) {
                flag = YES;
                break;
            }
        }
        if (flag == NO) {
            [mAr addObject:ar[i]];
        }
    }
    return mAr;
}

#pragma mark - DWDSegmentedControlDelegate
//- (void)segmentedControlIndexButtonView:(DWDSegmentedControl *)indexButtonView lickBtn:(UIButton *)sender {
- (void)segmentedControlIndexButtonView:(DWDSegmentedControl *)indexButtonView index:(NSInteger)index {
    _lastSegmentIndex = index;
    switch (index) {
        case 0:
            _blankViewText = @"暂无已到校的学生";
            [self setGoSchoolSucceedData];
            break;
        case 1:
            _blankViewText = @"暂无未到校的学生";
            [self setGoSchoolFailedData];
            break;
        default:
            break;
    }
    [self reloadNotificationReceived:nil];
    [self calculateInfoViewLabels];
}

#pragma mark - DWDPUCLoadingViewDelegate
- (void)loadingViewDidClickReloadButton:(DWDPUCLoadingView *)view {
    _isFirstRequest = YES;
    _requestFailed = NO;
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
    [self needRequest];
}

#pragma mark - setter / getter
- (NSArray *)succeedStudentsDataArray {
    if (!_succeedStudentsDataArray) {
        NSArray *ar = [NSArray new];
//        ar = [[DWDPickUpCenterDatabaseTool sharedManager] selectWhichDate:[NSString getTodayDateStr] type:@1 index:self.index teacherDataBaseWithClassId:self.classId];
        _succeedStudentsDataArray = ar;
    }
    return _succeedStudentsDataArray;
}

- (DWDTeacherGoSchoolInfoModel *)studentsInfoModel {
    if (!_studentsInfoModel) {
        DWDTeacherGoSchoolInfoModel *info = [[DWDTeacherGoSchoolInfoModel alloc] init];
        info.totalStudent = self.totalStudentsArray.count;
        info.succeedCount = self.succeedStudentsDataArray.count;
        info.vacateCount = self.vacateCount;
        info.attendanceRate = self.succeedStudentsDataArray.count / 1.0 / self.totalStudentsArray.count;
        _studentsInfoModel = info;
    }
    return _studentsInfoModel;
}

- (DWDSegmentedControl *)segmentControl {
    if (!_segmentControl) {
        DWDSegmentedControl *segmentControl = [[DWDSegmentedControl alloc] init];
        segmentControl.frame = CGRectMake(0, 0, DWDScreenW, 44);
        segmentControl.arrayTitles = @[@"已到校", @"未到校"];
        segmentControl.delegate = self;
        _segmentControl = segmentControl;
    }
    return _segmentControl;
}

- (NSArray *)failedStudentsDataArray {
    if (!_failedStudentsDataArray) {
        NSArray *failedArray = [NSArray new];
//        failedArray = [self removeSameCustIdObject:self.totalStudentsArray];
        _failedStudentsDataArray = failedArray;
    }
    return _failedStudentsDataArray;
}

//- (void)setTotalStudentsArray:(NSArray *)totalStudentsArray {
//    _totalStudentsArray = totalStudentsArray;
//
////    self.failedStudentsDataArray = [self removeSameCustIdObject:totalStudentsArray];
//}

- (DWDPickUpCenterBackgroundContainerView *)bgBlankImageView {
    if (!_bgBlankImageView) {
//        DWDPickUpCenterBackgroundContainerView *bgImgView = [[DWDPickUpCenterBackgroundContainerView alloc] initWithImage:[UIImage imageNamed:@"MSG_TF_NO_Data_Door"]];
        DWDPickUpCenterBackgroundContainerView *bgImgView = [DWDPickUpCenterBackgroundContainerView new];
        
        [bgImgView.backgroundImageView setImage:[UIImage imageNamed:@"MSG_TF_no_Student"]];
//        [bgImgView.infoLabel setText:@"暂无已到校的学生"];
        bgImgView.frame = CGRectMake(DWDScreenW * 0.5 - pxToW(316) * 0.5, pxToH(330) + 44, pxToW(316), pxToH(377));
        [self.view addSubview:bgImgView];
        _bgBlankImageView = bgImgView;
    }
    return _bgBlankImageView;
}

@end
