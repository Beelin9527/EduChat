//
//  DWDIntNoticeReadConditionCell.m
//  EduChat
//
//  Created by Beelin on 17/1/12.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import "DWDIntNoticeReadConditionCell.h"

#import "DWDIntSegmentedButton.h"
#import "DWDHeaderImgSortControl.h"

#import "DWDIntNoticeDetailModel.h"


@interface DWDIntNoticeReadConditionCell ()<DWDIntSegmentedButtonDelegate, DWDHeaderImgSortControlDelegate>
@property (nonatomic, strong) DWDIntSegmentedButton *seg;
@property (nonatomic, strong) DWDHeaderImgSortControl *headerImgSortControl;
@property (nonatomic, copy) NSArray *dataList;
@property (nonatomic, copy) NSArray *unDataList;
@end

@implementation DWDIntNoticeReadConditionCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
         [self setupControls];
    }
    return self;
}

#pragma mark - Setup UI
- (void)setupControls{
    [self.contentView addSubview:self.seg];
    [self.contentView addSubview:self.headerImgSortControl];
    
}

#pragma mark - Setter
- (void)setDataSource:(NSArray *)dataSource{
    _dataSource = dataSource;
    
    self.headerImgSortControl.arrItems = _dataSource;
    self.model.cellHeaderHeight = self.headerImgSortControl.hight;
    [self.headerImgSortControl setH:self.model.cellHeaderHeight];
}

#pragma mark - Getter
- (DWDIntSegmentedButton *)seg{
    if (!_seg) {
        _seg = [DWDIntSegmentedButton segmentedControlWithFrame:CGRectMake(0, 0, DWDScreenW, 40) Titles:@[@"已读",@"未读"] index:0];
        _seg.delegate = self;
    }
    return _seg;
}

- (DWDHeaderImgSortControl *)headerImgSortControl{
    if (!_headerImgSortControl) {
        _headerImgSortControl = [[DWDHeaderImgSortControl alloc]init];
        _headerImgSortControl.delegate = self;
        _headerImgSortControl.layouType = DWDNotNeedType;
        _headerImgSortControl.frame = CGRectMake(0, 41, DWDScreenW, 0);
    }
    return _headerImgSortControl;
}

#pragma mark - DWDIntSegmentedButtonDelegate
- (void)segmentedControlIndexButtonView:(DWDIntSegmentedButton *)indexButtonView lickBtnAtTag:(NSInteger)tag{
    [self.headerImgSortControl.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (self.delegate && [self.delegate respondsToSelector:@selector(intNoticeReadConditionCell:didClickButtonWithTag:)]) {
        [self.delegate intNoticeReadConditionCell:self didClickButtonWithTag:tag];
    }
}

#pragma mark - DWDHeaderImgSortControlDelegate
- (void)headerImgSortControl:(DWDHeaderImgSortControl *)headerImgSortControl DidGroupMemberWithCust:(NSNumber *)custId{
    if (self.delegate && [self.delegate respondsToSelector:@selector(intNoticeReadConditionCell:didClickPhotoHeadWithCustId:)]) {
        [self.delegate intNoticeReadConditionCell:self didClickPhotoHeadWithCustId:custId];
    }
}
@end
