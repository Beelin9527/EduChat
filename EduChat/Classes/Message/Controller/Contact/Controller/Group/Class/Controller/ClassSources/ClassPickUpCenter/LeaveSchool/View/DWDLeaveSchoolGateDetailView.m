//
//  DWDLeaveSchoolGateDetailView.m
//  EduChat
//
//  Created by KKK on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDLeaveSchoolGateDetailView.h"
#import "DWDPickUpCenterDataBaseModel.h"

#import "DWDPickUpCenterDatabaseTool.h"
#import "NSString+extend.h"

#import "DWDChatMsgDataClient.h"

#import <Masonry.h>
#import <YYModel.h>
#import <UIImageView+WebCache.h>

@interface DWDLeaveSchoolGateDetailView ()

@property (nonatomic, weak) UIImageView *studentImageView;
@property (nonatomic, weak) UIImageView *parentImageView;
@property (nonatomic, weak) UILabel *studentLabel;
@property (nonatomic, weak) UILabel *parentLabel;
@property (nonatomic, weak) UIButton *detailButton;

@end

@implementation DWDLeaveSchoolGateDetailView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.14f;
    self.layer.shadowRadius = 1.5;
    self.layer.shadowOffset = CGSizeMake(-pxToW(3), pxToW(3));
    self.clipsToBounds = NO;

    
    UIImageView *studentImageView = [UIImageView new];
    [self addSubview:studentImageView];
    self.studentImageView = studentImageView;
    
    CGFloat picWidth = (DWDScreenW - pxToW(62)) / 4.0;
    CGFloat picHeight = picWidth;
    [studentImageView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self);
        make.width.mas_equalTo(picWidth);
        make.height.mas_equalTo(picHeight);
    }];
    
    
    UIImageView *parentImageView = [UIImageView new];
    [self addSubview:parentImageView];
    self.parentImageView = parentImageView;
    [parentImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(studentImageView.right);
        make.right.equalTo(self);
        make.width.equalTo(studentImageView.width);
        make.height.mas_equalTo(picHeight);
    }];
    
    UILabel *studentLabel = [UILabel new];
    studentLabel.font = DWDFontContent;
    studentLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:studentLabel];
    self.studentLabel = studentLabel;
    [studentLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(studentImageView.bottom).offset(pxToH(12));
        make.left.equalTo(self);
        make.width.mas_equalTo(picWidth);
    }];
    
    UILabel *parentlabel = [UILabel new];
    studentLabel.font = DWDFontContent;
    parentlabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:parentlabel];
    self.parentLabel = parentlabel;
    [parentlabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(parentImageView.bottom).offset(pxToH(12));
        make.right.equalTo(self);
        make.width.mas_equalTo(picWidth);
    }];
    
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [detailButton addTarget:self
                      action:@selector(detailButtonClick:)
            forControlEvents:UIControlEventTouchUpInside];
    [detailButton setTitle:@"请确认" forState:UIControlStateNormal];
    [detailButton setTitleColor:DWDRGBColor(0, 187, 157) forState:UIControlStateNormal];
    UIImage *buttonImage = [UIImage imageNamed:@"MSG_TF_Btn_confirm"];
    buttonImage = [buttonImage resizableImageWithCapInsets:UIEdgeInsetsMake(buttonImage.size.height * 0.5, buttonImage.size.width * 0.5, buttonImage.size.height * 0.5, buttonImage.size.width * 0.5) resizingMode:UIImageResizingModeStretch];
    [detailButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    [self addSubview:detailButton];
    self.detailButton = detailButton;
    [detailButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(studentLabel.bottom).offset(pxToH(12));
        make.left.equalTo(self).offset(pxToH(12));
        make.right.equalTo(self).offset(-pxToH(12));
        make.bottom.equalTo(self);
    }];
    [super updateConstraints];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.bounds.size.width + pxToW(6), self.bounds.size.height)].CGPath;
}

#pragma mark - Private Method
- (void)detailButtonClick:(UIButton *)button {
    DWDMarkLog(@"Surprise - Gate");
    
    NSDictionary *params = @{
                             @"teacherId" : [DWDCustInfo shared].custId,
                             @"classId": self.dataModel.classId,
                             @"studentId" : self.dataModel.custId,
                             @"parentId" : self.dataModel.parent.custId,
                             @"type" : @1,
                             };
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    //发请求
    [[HttpClient sharedClient] postPickUpCenterStatusUpdateWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [hud hide:YES];
        /*
         
         */
        DWDPickUpCenterDataBaseModel *model = [self.dataModel copy];
        model.contextual = @"Getoutschool";
        model.type = @2;
//        @property (nonatomic, copy) NSString *date;
//        @property (nonatomic, copy) NSString *time;
        static NSDateFormatter *dateFormatter;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatter = [NSDateFormatter new];
        });
        dateFormatter.dateFormat = @"YYYY-MM-dd";
        model.date = [dateFormatter stringFromDate:[NSDate date]];
        dateFormatter.dateFormat = @"HH:mm:ss";
        model.time = [dateFormatter stringFromDate:[NSDate date]];
        
        NSDictionary *postInfo = @{@"code": @"sysmsgContextual",
                                   @"entity": model
                                   };
        NSString *json = [postInfo yy_modelToJSONString];
        NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        /**
         模拟socket通讯 发送消息
         
         消息由包头(0x4040) + 协议头(系统消息0x9101) + 长度(2个字节) + 消息体 + 校验码(1个字节) + 包尾(0x2424)
         */
        
        NSMutableData *resultData = [NSMutableData data];
        Byte head[] = {0x40, 0x40, 0x91, 0x01};
        [resultData appendBytes:head length:4];
        //消息长度
        long len = NSSwapHostLongToLittle(jsonData.length);
        
        char *charLen = (char *)&len;
        
        Byte b[] = {0,0};
        memcpy(&b[0], &charLen[1], 1);
        memcpy(&b[1], &charLen[0], 1);
        [resultData appendBytes:b length:2];
        //消息体
        unsigned char body[jsonData.length];
        [jsonData getBytes:body range:NSMakeRange(0, jsonData.length)];
        
        [resultData appendBytes:body length:jsonData.length];
        //校验码
        //        [[DWDChatMsgDataClient sharedChatMsgDataClient] getCheckMark:body len:jsonData.length];
        Byte checksum = body[1];
        for (int i = 0; i < jsonData.length; i++) {
            checksum = checksum ^ body[i];
        }
        //    Byte check[] = {checksum};
        unsigned char check[] = {checksum};
        [resultData appendBytes:check length:1];
        //尾
        Byte end[] = {0x24, 0x24};
        [resultData appendBytes:end length:2];
        
        [[DWDChatMsgDataClient sharedChatMsgDataClient] parseChatMsgFromDataAndPostSomeNotification:resultData];
        [DWDProgressHUD showText:@"确认成功"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [hud hide:YES];
        [DWDProgressHUD showText:@"确认失败!"];
    }];
}

#pragma mark - Setter / Getter
- (void)setDataModel:(DWDPickUpCenterDataBaseModel *)dataModel {
    _dataModel = dataModel;
    
    [_studentImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.photokey]
                         placeholderImage:[UIImage imageNamed:@"ME_User_HP_Boy"]];
    [_parentImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.photo]
                        placeholderImage:[UIImage imageNamed:@"ME_User_HP_Boy"]];
    _studentLabel.text = dataModel.name;
    _parentLabel.text = [NSString parentRelationStringWithRelation:dataModel.relation];
}

@end
