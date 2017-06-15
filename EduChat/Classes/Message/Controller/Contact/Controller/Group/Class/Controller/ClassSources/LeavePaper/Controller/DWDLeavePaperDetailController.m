//
//  DWDLeavePaperDetailController.m
//  EduChat
//
//  Created by KKK on 16/5/12.
//  Copyright © 2016年 dwd. All rights reserved.
//

#define kStateAgree @1
#define kStateRefuse @2
#define kStateNotSure @0

#import "DWDLeavePaperDetailController.h"

#import "DWDLeavePaperCellGroup.h"
#import "DWDLeavePaperDetailModel.h"

#import <YYModel.h>

@interface DWDLeavePaperDetailController ()
@property (nonatomic, strong) DWDLeavePaperDetailModel *model;

@end

@implementation DWDLeavePaperDetailController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"假条详情";
    self.tableView.backgroundColor = DWDColorBackgroud;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Do any additional setup after loading the view from its nib.
//    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DWDLeavePaperCellGroup" owner:nil options:nil];
//    [self.tableView registerNib:[UINib nibWithData:array[0] bundle:nil] forCellReuseIdentifier:@"checkCell"];
//    [self.tableView registerNib:[UINib nibWithData:array[1] bundle:nil] forCellReuseIdentifier:@"vacateCell"];
//    [self.tableView registerNib:[UINib nibWithData:array[2] bundle:nil] forCellReuseIdentifier:@"headCell"];
//    [self.tableView registerNib:[UINib nibWithData:array[3] bundle:nil] forCellReuseIdentifier:@"refuseCell"];
//    [self.tableView registerNib:[UINib nibWithData:array[4] bundle:nil] forCellReuseIdentifier:@"notCheckCell"];
    
//    [self.tableView registerClass:[DWDLeavePaperCheckCell class] forCellReuseIdentifier:@"checkCell"];
//    [self.tableView registerClass:[DWDLeavePaperVacateCell class]
//           forCellReuseIdentifier:@"vacateCell"];
//    [self.tableView registerClass:[DWDLeavePaperHeadCell class]
//           forCellReuseIdentifier:@"headCell"];
//    [self.tableView registerClass:[DWDLeavePaperRefuseCell class]
//           forCellReuseIdentifier:@"refuseCell"];
//    [self.tableView registerClass:[DWDLeavePaperNotCheckCell class]
//           forCellReuseIdentifier:@"notCheckCell"];
    [self requestLeavePaperDetail];
}
#pragma mark - Private Method
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
            [weakSelf.tableView reloadData];
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}

/**
 *  计算文字高度
 */
- (CGFloat)labelHeightWithString:(NSString *)str fontSize:(CGFloat)font {
    
    CGSize size = CGSizeZero;
    if (str) {
        //iOS 7
        CGRect frame = [str boundingRectWithSize:CGSizeMake(DWDScreenW - 20, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:font]}
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
//            return [super tableView:tableView heightForRowAtIndexPath:indexPath];
            height = 44 + 30 + [self labelHeightWithString:@"申请理由" fontSize:14] + [self labelHeightWithString:_model.excuse fontSize:16] + 13;
            break;
        case 2:
            if ([self.model.state isEqualToNumber:kStateNotSure]) {
                height = 44;
            } else {
                height = 132;
            }
            break;
        case 3:
//            return [super tableView:tableView heightForRowAtIndexPath:indexPath];
            //不同意理由
            height = 30 + [self labelHeightWithString:@"不同意理由:" fontSize:14] + [self labelHeightWithString:_model.opinion fontSize:16] + 13;
            break;
        default:
            return [super tableView:tableView heightForRowAtIndexPath:indexPath];
            break;
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.model.state isEqualToNumber:kStateAgree] || [self.model.state isEqualToNumber:kStateNotSure]) {
        //同意
        return 3;
    }else if ([self.model.state isEqualToNumber: kStateRefuse]){
        return 4;
    }
    return 0;

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
    } else if (indexPath.section == 2){
        if ([self.model.state isEqualToNumber:kStateNotSure]) {
            //未审核cell
            DWDLeavePaperNotCheckCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notCheckCell"];
        if (!cell) {
            cell = array[[self indexOfClass:[DWDLeavePaperNotCheckCell class]]];
        }
            cell.model = self.model;
            return cell;
        } else {
            DWDLeavePaperCheckCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkCell"];
        if (!cell) {
            cell = array[[self indexOfClass:[DWDLeavePaperCheckCell class]]];
        }
            cell.model = self.model;
            return cell;
        }
    } else {
            //不同意cell
            DWDLeavePaperRefuseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"refuseCell"];
        if (!cell) {
            cell = array[[self indexOfClass:[DWDLeavePaperRefuseCell class]]];
        }
        cell.model = self.model;
            return cell;
    }
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
