//
//  DWDPickUpCenterChildCell.m
//  EduChat
//
//  Created by Superman on 16/3/23.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterChildCell.h"
#import "DWDPickUpCenterDataBaseModel.h"
#import "NSString+extend.h"

#import <UIImageView+WebCache.h>
#import <Masonry.h>

#define bigPhotoHeight (DWDScreenW - 50) * 500 / 650.0
@interface DWDPickUpCenterChildCell()

@property (nonatomic , weak) UILabel *topTimeLabel;

@property (nonatomic , weak) UIView *bgView;

@property (nonatomic , weak) UIImageView *bigPictureView;
@property (nonatomic , weak) UIImageView *littlePictureView;
@property (nonatomic , weak) UILabel *desLabel;

@end

@implementation DWDPickUpCenterChildCell

+ (instancetype)cellWithTableView:(UITableView *)tableView ID:(NSString *)ID {
    
    DWDPickUpCenterChildCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[DWDPickUpCenterChildCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        // 初始化子控件
        UILabel *timeLabel = [UILabel new];
        timeLabel.font = DWDFontMin;
        [self.contentView addSubview:timeLabel];
        self.topTimeLabel = timeLabel;
        
        UIView *bgView = [UIView new];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bgView];
        self.bgView = bgView;
        
        UIImageView *bigPictureView = [UIImageView new];
        bigPictureView.backgroundColor = DWDRGBColor(242, 242, 242);
        [self.contentView addSubview:bigPictureView];
        self.bigPictureView = bigPictureView;
        
        UIImageView *littlePictureView = [UIImageView new];
        [self.contentView addSubview:littlePictureView];
        self.littlePictureView = littlePictureView;
        
        UILabel *desLabel = [UILabel new];
        desLabel.preferredMaxLayoutWidth = DWDScreenW - 60;
//        desLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        desLabel.numberOfLines = 0;
        desLabel.font = DWDFontContent;
        desLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:desLabel];
        self.desLabel = desLabel;
        
        
        [timeLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(pxToH(10));
            make.centerX.equalTo(self.contentView);
        }];
        
        [bgView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(timeLabel.bottom).offset(15);
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-15);
            make.bottom.equalTo(self.contentView).offset(-25);
        }];
        
        [bigPictureView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bgView).offset(10);
            make.left.equalTo(bgView).offset(10);
            make.right.equalTo(bgView).offset(-10);
            make.height.mas_equalTo(bigPhotoHeight);
//            make.width.mas_equalTo(bigPhotoHeight * 500.0 / 650.0);
        }];
        
        [littlePictureView makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(bgView);
            make.centerY.equalTo(bigPictureView.bottom);
            make.width.equalTo(@50);
            make.height.equalTo(@50);
        }];
        
        [desLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bigPictureView.bottom).offset(45);
            make.centerX.equalTo(bigPictureView);
            make.bottom.equalTo(bgView.bottom).offset(-25);
        }];
        [super updateConstraints];
    }
    return self;
}

#pragma mark - Setter / Getter

- (void)setDataBaseModel:(DWDPickUpCenterDataBaseModel *)dataBaseModel {
    _dataBaseModel = dataBaseModel;
    _topTimeLabel.text = [NSString stringWithFormat:@"%@ %@", dataBaseModel.date, dataBaseModel.time];
    
    NSString *state = dataBaseModel.contextual;
    
    NSString *parent = [NSString parentRelationStringWithRelation:dataBaseModel.relation];
    
    if ([state isEqualToString:@"OnGotoschoolBus"]) {
        //小明已上校车。
        _desLabel.text = [NSString stringWithFormat:@"%@已上校车。", dataBaseModel.name];
    } else if ([state isEqualToString:@"Reachschool"] || [state isEqualToString:@"OffGotoschoolBus"]) {
        //小明已安全到校。
        _desLabel.text = [NSString stringWithFormat:@"%@已安全到校。", dataBaseModel.name];
    } else if ([state isEqualToString:@"WaitparentOut"]) {
        //放学啦，小明爸爸已在校门等待接小明放学。
        _desLabel.text = [NSString stringWithFormat:@"放学啦，%@%@已在校门等待接%@放学。", dataBaseModel.name,parent, dataBaseModel.name];
    } else if ([state isEqualToString:@"OnAfterschoolBus"]) {
        //小明放学啦，坐校车回家。
        _desLabel.text = [NSString stringWithFormat:@"%@放学啦，坐校车回家。", dataBaseModel.name];
    }
    
    UIImage *phImage = [UIImage imageNamed:@"msg_tf_placeholder"];
//    phImage.size = CGSizeMake(300, 450);
    [_bigPictureView sd_setImageWithURL:[NSURL URLWithString:dataBaseModel.photo] placeholderImage:phImage];
    [_littlePictureView sd_setImageWithURL:[NSURL URLWithString:dataBaseModel.photokey]
                          placeholderImage:[[UIImage imageNamed:@"ME_User_HP_Boy"]
                                            clipCircleWithBorderWidth:pxToW(6)
                                            borderColor:[UIColor whiteColor]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                              if (image) {
                                  if (!error) {
                                      [_littlePictureView setImage:[image clipCircleWithBorderWidth:pxToW(6)
                                                                                        borderColor:[UIColor whiteColor]]];
                                  }
                              }
                          }];
    //{
    //    "code":"sysmsgContextual",
    //    "entity":{
    //        "custId":,			//孩子id
    //        "name":"",			//孩子姓名
    //        "photokey":"",		//孩子头像
    //        "schoolId":""		//学校id
    //        "schoolName":"",	//学校名字
    //        "classId":,			//班级id
    //        "className":"",		//班级名字
    //        "relation":0,		//孩子家长关系
    //        "contextual":"Reachschool",	//当前接送状态
    //        "photo":			//实时照片
    //        "date":"2016-3-15"	//接送日期
    //        "time":"09:42:30"	//接送时间
    //        "parent":					//接送家长信息，可以为空
    
    // 制作圆角图片 borderWidth = px 6 , 给大图小图文本赋值
//
//    NSArray *yyyymmddTodayDates = [today componentsSeparatedByString:@"-"];
//    
//    NSArray *yyyymmddModelDates = [dataBaseModel.date componentsSeparatedByString:@"-"];
//    
//    if ([yyyymmddTodayDates[0] isEqualToString:yyyymmddModelDates[0]]) { // 年份一样
//        if ([yyyymmddTodayDates[1] isEqualToString:yyyymmddModelDates[1]]) { // 月份一样
//            if([yyyymmddTodayDates[2] isEqualToString:yyyymmddModelDates[2]]){ // 天一样
//                // 今天
//            }
//        }
//    }else{
//        // 直接显示日期
//    }
}

@end
