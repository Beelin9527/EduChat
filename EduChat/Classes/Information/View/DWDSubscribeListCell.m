//
//  DWDSubscribeListCell.m
//  EduChat
//
//  Created by ; on 16/11/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDSubscribeListCell.h"

#import <Masonry/Masonry.h>

#import "NSDate+dwd_dateCategory.h"
#import "NSNumber+Extension.h"

@interface DWDSubscribeListCell ()
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIImageView *avatar_imv;
@property (nonatomic, strong) UILabel *nickname_lab;
@property (nonatomic, strong) UIButton *notRead_btn;

@property (nonatomic, strong) UILabel *title_lab;
@property (nonatomic, strong) UILabel *content_lab;
@property (nonatomic, strong) UIImageView *comeIn_imv;
@property (nonatomic, strong) UILabel *time_lab;

@property (nonatomic, strong) UIButton *comeInExpertBtn; //透明按钮，点击进入专家详情
@end


@implementation DWDSubscribeListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 8;
        self.layer.borderColor = DWDColorSeparator.CGColor;
        self.layer.borderWidth = 0.7;
        
        [self createControls];
        [self layoutControls];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    CGRect F = frame;
    F.origin.x += 10;
    F.origin.y += 5;
    F.size.width = DWDScreenW - 20;
    F.size.height -= 10;
    frame = F;
    [super setFrame:frame];
}
//赋值公共控件值
- (void)assigninCommonControlWithModel:(DWDArticleModel *)articleModel
{
    [self.avatar_imv sd_setImageWithURL:[NSURL URLWithString:articleModel.auth.photoKey] placeholderImage:DWDDefault_MeBoyImage];
    self.nickname_lab.text = articleModel.auth.nickname;
    
    self.title_lab.text = articleModel.title;
    self.content_lab.text = articleModel.summary;
    
    
    NSString *timeStr = [NSString stringWithTimelineDate:[NSDate dateWithString:articleModel.time format:@"YYYYMMddHHmmss"]]; //YYYY-MM-dd HH:mm:ss]
    self.time_lab.text = [NSString stringWithFormat:@"%@更新",timeStr];
    
    if ([articleModel.unreadCnt isEqualToNumber:@0]) {
        self.notRead_btn.hidden = YES;
    }else {
        [self.notRead_btn setTitle:[NSString stringWithFormat:@"未读%@",articleModel.unreadCnt] forState:UIControlStateNormal];
        NSString *title = [NSString stringWithFormat:@"未读%@",articleModel.unreadCnt];
        CGSize size = [title boundingRectWithfont:DWDScreenW > 320.0f ? DWDFontMin : [UIFont systemFontOfSize:11]];
        [self.notRead_btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(size.width + 30, size.height + 4));
        }];
        self.notRead_btn.hidden = NO;
    }
}

- (void)createControls{
    [self.contentView addSubview:({
        self.line = ({
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = DWDColorMain;
            line.layer.masksToBounds = YES;
            line.layer.cornerRadius = 1.5;
            line;
        });
    })];
    [self.contentView addSubview:({
        self.avatar_imv = ({
            UIImageView *imv = [[UIImageView alloc] init];
            imv.layer.masksToBounds = YES;
            imv.layer.cornerRadius = 10;
            imv.layer.borderColor = UIColorFromRGB(0xeeeeee).CGColor;
            imv.layer.borderWidth = 0.5;
            imv;
        });
    })];
    [self.contentView addSubview:({
        self.nickname_lab = ({
            UILabel *lab = [[UILabel alloc] init];
            lab.textColor = DWDColorSecondary;
            lab.font = DWDScreenW > 320.0f ? DWDFontMin : [UIFont systemFontOfSize:11];
            lab;
        });
    })];
    
    [self.contentView addSubview:({
        self.notRead_btn = ({
            UIButton *btn = [[UIButton alloc] init];
            btn.backgroundColor = DWDRGBColor(251, 173, 41);
            btn.titleLabel.font = DWDScreenW > 320.0f ? DWDFontMin : [UIFont systemFontOfSize:11];
            [btn setImage:[UIImage imageNamed:@"ic_unread_information"] forState:UIControlStateNormal];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -3, 0, 0)];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 10;
            btn;
        });
    })];
    
    //内容部分
    [self.contentView addSubview:({
        self.title_lab = ({
            UILabel *lab = [[UILabel alloc] init];
            lab.numberOfLines = 0;
            lab.font = DWDScreenW > 320.0f ? [UIFont systemFontOfSize:18] : [UIFont systemFontOfSize:17];
            lab;
        });
    })];
    [self.contentView addSubview:({
        self.content_lab = ({
            UILabel *lab = [[UILabel alloc] init];
            lab.textColor = DWDColorSecondary;
            lab.font = DWDScreenW > 320.0f ? [UIFont systemFontOfSize:14] : [UIFont systemFontOfSize:13];
            lab;
        });
    })];
    [self.contentView addSubview:({
        self.comeIn_imv = ({
            UIImageView *imv = [[UIImageView alloc] init];
            imv.image = [UIImage imageNamed:@"ic_read_more_information"];
            imv;
        });
    })];
    [self.contentView addSubview:({
        self.time_lab = ({
            UILabel *lab = [[UILabel alloc] init];
            lab.textAlignment = NSTextAlignmentRight;
            lab.textColor = DWDColorSecondary;
            lab.font = DWDScreenW > 320.0f ? [UIFont systemFontOfSize:11] : [UIFont systemFontOfSize:10];
            lab;
        });
    })];
    
    //透明按钮
    [self.contentView addSubview:({
        self.comeInExpertBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn addTarget:self action:@selector(comeInExpertInfo) forControlEvents:UIControlEventTouchUpInside];
            btn;
        });
    })];
}
/** 头像、姓名、未读 固定 */
- (void)layoutControls{
    [self.line makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).mas_offset(10);
        make.top.equalTo(self.contentView).mas_offset(12);
        make.size.mas_equalTo(CGSizeMake(3, 20));
    }];
    [self.avatar_imv makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.line.right).mas_offset(6);
        make.centerY.equalTo(self.line);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [self.nickname_lab makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatar_imv.right).mas_offset(6);
        make.centerY.equalTo(self.line);
    }];
    [self.notRead_btn makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).mas_offset(-10);
        make.centerY.equalTo(self.line);
//        make.size.mas_equalTo(CGSizeMake(60, 18));
    }];
    
    [self.comeInExpertBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.contentView);
        make.height.mas_equalTo(40);
    }];
}

- (void)comeInExpertInfo{
    !self.comeInExpertInfoBlock ?: self.comeInExpertInfoBlock(self.articleModel);
}
@end


@implementation DWDSubscribeListArticleCell
+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *cellIdentifire = @"DWDSubscribeListArticleCell";
    DWDSubscribeListArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifire];
    if (!cell) {
        cell = [[DWDSubscribeListArticleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifire];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self layoutOtherControls];
       
    }
    return self;
}

- (void)layoutOtherControls{
    [self.title_lab makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatar_imv.mas_bottom).mas_offset(12);
        make.left.equalTo(self.contentView).mas_offset(19);
        make.right.equalTo(self.contentView).mas_offset(-19);
    }];
    [self.content_lab makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.title_lab.mas_bottom).mas_offset(12);
        make.left.equalTo(self.contentView).mas_offset(19);
        make.right.equalTo(self.contentView).mas_offset(-40);
    }];
    [self.comeIn_imv makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.content_lab);
        make.right.equalTo(self.contentView).mas_offset(-10);
    }];
    [self.time_lab makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.comeIn_imv.mas_bottom).mas_offset(10);
        make.right.equalTo(self.contentView).mas_offset(-10);
    }];
}

#pragma mark - Setter
- (void)setArticleModel:(DWDArticleModel *)articleModel{
    [super setArticleModel:articleModel];
    [super assigninCommonControlWithModel:articleModel];
    
    //([articleModel.visitStat.readSta intValue] == 1) ? DWDColorSecondary : DWDColorBody 需求改为一直都黑色 2016.11.22 beelin
    self.title_lab.textColor =  DWDColorBody;
    
    if (!self.content_lab.text|| [self.content_lab.text isEqualToString:@""]) {
        self.comeIn_imv.hidden = YES;
        //重新masonry 时间
        [self.time_lab updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.title_lab.mas_bottom).offset(10);
            make.right.equalTo(self.contentView).mas_offset(-10);
        }];
    }
    

    [self layoutIfNeeded];
    self.articleModel.height = CGRectGetMaxY(self.time_lab.frame) + 25;
 
}


@end


@interface DWDSubscribeListPhotoCell ()
@property (nonatomic, strong) UIImageView *photo_imv;
@end
@implementation DWDSubscribeListPhotoCell
+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *cellIdentifire = @"DWDSubscribeListPhotoCell";
    DWDSubscribeListPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifire];
    if (!cell) {
        cell = [[DWDSubscribeListPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifire];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
         [self createOtherControls];
        [self layoutOtherControls];
    }
    return self;
}

- (void)createOtherControls{
    //设置title_lab 为白色
    self.title_lab.textColor = [UIColor whiteColor];
    
    self.photo_imv = ({
        UIImageView *imv = [[UIImageView alloc] init];
        
        CAGradientLayer *gradientLayerTop = [CAGradientLayer layer];  // 设置渐变效果
        gradientLayerTop.borderWidth = 0;
        gradientLayerTop.frame = (CGRect){0, 180 * DWDScreenW/375.0 - 70, DWDScreenW - 40, 70};
        gradientLayerTop.colors = [NSArray arrayWithObjects:
                                   (id)[UIColor colorWithWhite:0 alpha:0].CGColor,
                                   (id)[UIColor colorWithWhite:0 alpha:0.8].CGColor, nil];
        gradientLayerTop.startPoint = CGPointMake(0.5, 0.0);
        gradientLayerTop.endPoint = CGPointMake(0.5, 1.0);
        [imv.layer addSublayer:gradientLayerTop];
        
        imv;
    });
    
    [self.contentView insertSubview:self.photo_imv belowSubview:self.title_lab];
}
- (void)layoutOtherControls{
    [self.photo_imv makeConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(self.contentView).mas_offset(44);
         make.left.equalTo(self.contentView).mas_offset(10);
        make.right.equalTo(self.contentView).mas_offset(-10);
        make.height.mas_equalTo(180 * DWDScreenW/375.0);
    }];
    [self.title_lab makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.photo_imv.mas_bottom).mas_offset(-10);
        make.left.equalTo(self.contentView).mas_offset(19);
        make.right.equalTo(self.contentView).mas_offset(-19);
    }];
    [self.comeIn_imv makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.photo_imv.mas_bottom).mas_offset(12);
        make.right.equalTo(self.contentView).mas_offset(-10);
    }];
    [self.time_lab makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.comeIn_imv.mas_bottom).mas_offset(10);
        make.right.equalTo(self.contentView).mas_offset(-10);
    }];
}

#pragma mark - Setter
- (void)setArticleModel:(DWDArticleModel *)articleModel{
    [super setArticleModel:articleModel];
    [super assigninCommonControlWithModel:articleModel];
    
    [self.photo_imv sd_setImageWithURL:[NSURL URLWithString:articleModel.photoUrl] placeholderImage:DWDDefault_infoPhotoImage];
    
    if (!self.content_lab.text|| [self.content_lab.text isEqualToString:@""]) {
        self.comeIn_imv.hidden = YES;
        //重新masonry 时间
        [self.time_lab updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.photo_imv.mas_bottom).offset(10);
            make.right.equalTo(self.contentView).mas_offset(-10);
        }];
    }
    
    [self layoutIfNeeded];
    self.articleModel.height = CGRectGetMaxY(self.time_lab.frame) + 25;
    
}
@end


@interface DWDSubscribeListVideoCell ()
@property (nonatomic, strong) UIImageView *playImv;
//@property (nonatomic, strong) UILabel *palyTimeLab;
@end
@implementation DWDSubscribeListVideoCell
+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *cellIdentifire = @"DWDSubscribeListVideoCell";
    DWDSubscribeListVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifire];
    if (!cell) {
        cell = [[DWDSubscribeListVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifire];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createOtherControls];
        [self layoutOtherControls];
    }
    return self;
}
- (void)createOtherControls{
    [super createOtherControls];
    
    //设置title_lab 为白色
    self.title_lab.textColor = [UIColor whiteColor];
    
    //添加视频播放与播放时长控件
    [self.contentView addSubview:({
        _playImv = ({
            UIImageView *imv = [[UIImageView alloc] init];
            imv.image = [UIImage imageNamed:@"ic_play_video"];
            imv;
        });
    })];
//    [self.contentView addSubview:({
//        _palyTimeLab = ({
//            UILabel *lab = [[UILabel alloc] init];
//            lab.textColor = [UIColor whiteColor];
//            lab.textAlignment = NSTextAlignmentCenter;
//            lab.font = DWDFontMin;
//            lab;
//        });
//    })];
}
- (void)layoutOtherControls{
    [super layoutOtherControls];
    
    [self.playImv makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.photo_imv).mas_offset(50);
        make.centerX.equalTo(self.contentView);
    }];
//    [self.palyTimeLab makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.playImv.mas_bottom).mas_offset(10);
//        make.centerX.equalTo(self.contentView);
//    }];
}

#pragma mark - Setter
- (void)setArticleModel:(DWDArticleModel *)articleModel{
    [super setArticleModel:articleModel];
    [super assigninCommonControlWithModel:articleModel];
    
//    self.palyTimeLab.text = [articleModel.video.duration calculateduartion];
    
    if (!self.content_lab.text|| [self.content_lab.text isEqualToString:@""]) {
        self.comeIn_imv.hidden = YES;
        //重新masonry 时间
        [self.time_lab updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.photo_imv.mas_bottom).offset(10);
            make.right.equalTo(self.contentView).mas_offset(-10);
        }];
    }
    
    [self layoutIfNeeded];
    self.articleModel.height = CGRectGetMaxY(self.time_lab.frame) + 25;
    
}
@end


