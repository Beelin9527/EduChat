//
//  DWDIntMessageCell.m
//  EduChat
//
//  Created by Beelin on 17/1/9.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import "DWDIntMessageCell.h"

#import "DWDIntMessageModel.h"

#import "NSDate+dwd_dateCategory.h"

#pragma mark - 基类Cell
static CGFloat const AVATAR_W = 41;
static CGFloat const AVATAR_H = AVATAR_W;
static CGFloat const AVATAR_L = 10;
static CGFloat const PADDING_T = 15;

static CGFloat const BACKGROUND_L = 2.5;

@interface DWDIntMessageCell ()
@property (nonatomic, assign) CGFloat BACKGROUND_W;    //背景图宽
@end

@implementation DWDIntMessageCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *cellId = @"DWDIntMessageCell";
    DWDIntMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell =  [[DWDIntMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _BACKGROUND_W = DWDScreenW - 35 - AVATAR_L - AVATAR_W - BACKGROUND_L;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupControls];
    }
    return self;
}

#pragma mark - setupControls
- (void)setupControls{
    [self.contentView addSubview:self.avatar];
    [self.contentView addSubview:self.backgroundImv];
    [self.contentView addSubview:self.typeLab];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.line];
    [self.contentView addSubview:self.dateLab];

}

#pragma mark - Setter
- (void)setIntMessageModel:(DWDIntMessageModel *)intMessageModel{
    _intMessageModel = intMessageModel;
    
    self.dateLab.hidden = self.isHiddenDate;
    
    if (self.isHiddenDate) {
        self.avatar.frame = CGRectMake(AVATAR_L, PADDING_T, AVATAR_W, AVATAR_H);
    }else{
        NSString *dateStr = [_intMessageModel.ctTime stringValue];
        self.dateLab.text = [NSString stringWithTimelineDate:[NSDate dateWithString:dateStr format:@"YYYYMMddHHmmss"]];
        CGFloat dateLabW = [self.dateLab.text boundingRectWithfont:self.dateLab.font].width + 40;
        self.dateLab.frame = CGRectMake(DWDScreenW / 2.0 - dateLabW / 2.0, PADDING_T, dateLabW, 18);
        
        self.avatar.frame = CGRectMake(AVATAR_L, self.dateLab.maxY + PADDING_T, AVATAR_W, AVATAR_H);
    }
    
    self.typeLab.text = _intMessageModel.mntitle;
    self.typeLab.frame = CGRectMake(self.avatar.maxX + 25, self.avatar.y + PADDING_T, self.BACKGROUND_W - 30, 17);
    
    self.titleLab.text = _intMessageModel.msgtitle;
    self.titleLab.frame = CGRectMake(self.avatar.maxX + 25, self.typeLab.maxY + 9, self.typeLab.w, 17);
    
    self.line.frame = CGRectMake(self.avatar.maxX + 25, self.titleLab.maxY + 10, self.BACKGROUND_W - 7 - 30, 0.7);
    
    //移除label
    for (UIView *subView in self.contentView.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            if (subView.tag == 9527) {
                [subView removeFromSuperview];
            }
        }
    }
    
    CGFloat backgrounImvMaxY = 0;
    for (int i = 0; i < intMessageModel.msgcontextList.count; i ++) {
        DWDIntMessageContextModel *contextModel = intMessageModel.msgcontextList[i];
        
        UILabel *lab = [self createContentLabel];
        if(i == intMessageModel.msgcontextList.count - 1){
            if ([intMessageModel.statype isEqualToNumber:@2]) {
                lab.text = [NSString stringWithFormat:@"%@    %@（已同意）",contextModel.name, contextModel.value];
                NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:lab.text];
                [att addAttribute:NSForegroundColorAttributeName value:DWDRGBColor(119, 188, 9) range:NSMakeRange(lab.text.length - 5, 5)];
                [att addAttribute:NSForegroundColorAttributeName value:DWDColorContent range:NSMakeRange(0, 4)];
                lab.attributedText = att;
            }else if ([intMessageModel.statype isEqualToNumber:@3]){
                 lab.text = [NSString stringWithFormat:@"%@    %@（不同意）",contextModel.name, contextModel.value];
                NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:lab.text];
                [att addAttribute:NSForegroundColorAttributeName value:DWDRGBColor(249, 98, 105) range:NSMakeRange(lab.text.length - 5, 5)];
                  [att addAttribute:NSForegroundColorAttributeName value:DWDColorContent range:NSMakeRange(0, 4)];
                lab.attributedText = att;
            }
        }else{
            lab.text = [NSString stringWithFormat:@"%@    %@",contextModel.name, contextModel.value];
            NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:lab.text];
            [att addAttribute:NSForegroundColorAttributeName value:DWDColorContent range:NSMakeRange(0, 4)];
            lab.attributedText = att;
        }
        lab.tag = 9527; //标识
        
        CGFloat labH = 14;
        CGFloat paddingT = 8;
        CGFloat labX = self.avatar.maxX + 25;
        CGFloat labY = self.line.maxY + 10 + (labH + paddingT) * i;
        lab.frame = CGRectMake(labX, labY, self.typeLab.w, labH);
        [self.contentView addSubview:lab];
        
        backgrounImvMaxY = lab.maxY + PADDING_T;
    }

    [self.backgroundImv setImage:[UIImage imageNamed:@"bg_approval_office_msg"]];
    self.backgroundImv.frame = CGRectMake(self.avatar.maxX + BACKGROUND_L, self.avatar.y, self.BACKGROUND_W, backgrounImvMaxY - self.avatar.y);
    
    //头像与背景图
    if ([_intMessageModel.mncd isEqualToString:kDWDIntMenuCodeSchoolManagementApply]) {
        self.avatar.image = [UIImage imageNamed:@"ic_approval_msg"];
        self.backgroundImv.image = [UIImage imageNamed:@"bg_approval_office_msg"];
    }else if ([_intMessageModel.mncd isEqualToString:kDWDIntMenuCodeSchoolManagementNotice]){
        self.avatar.image = [UIImage imageNamed:@"ic_notice_msg"];
        self.backgroundImv.image = [UIImage imageNamed:@"bg_noticel_office_msg"];
    }else if ([_intMessageModel.mncd isEqualToString:kDWDIntMenuCodeSchoolManagementMeeting]){
        self.avatar.image = [UIImage imageNamed:@"ic_meeting_msg"];
        self.backgroundImv.image = [UIImage imageNamed:@"bg_meeting_office_msg"];
    }
        //计算cell高度
    _intMessageModel.cellHeight = self.backgroundImv.maxY;
}


#pragma mark - Getter
- (UIImageView *)avatar{
    if (!_avatar) {
        _avatar = [[UIImageView alloc] init];
        _avatar.size = CGSizeMake(41, 41);
        _avatar.layer.masksToBounds = YES;
        _avatar.layer.cornerRadius = 41 / 2.0;
    }
    return _avatar;
}

- (UIImageView *)backgroundImv{
    if (!_backgroundImv) {
        _backgroundImv = [[UIImageView alloc] init];
        _backgroundImv.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_backgroundImv addGestureRecognizer:tap];
    }
    return _backgroundImv;
}

- (UILabel *)typeLab{
    if (!_typeLab) {
        _typeLab = [[UILabel alloc] init];
        _typeLab.textColor = DWDColorBody;
        _typeLab.font = [UIFont boldSystemFontOfSize:17];
    }
    return _typeLab;
}

- (UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = DWDColorBody;
        _titleLab.font = [UIFont systemFontOfSize:16];
    }
    return _titleLab;
}

- (UIView *)line{
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = DWDColorSeparator;
    }
    return _line;
}


- (UILabel *)dateLab{
    if (!_dateLab) {
        _dateLab = [[UILabel alloc] init];
        _dateLab.textColor = [UIColor whiteColor];
        _dateLab.textAlignment = NSTextAlignmentCenter;
        _dateLab.font = [UIFont systemFontOfSize:11];
        _dateLab.backgroundColor = DWDRGBColor(196, 197, 198);
        _dateLab.layer.masksToBounds = YES;
        _dateLab.layer.cornerRadius = 4;
    }
    return _dateLab;
}


#pragma mark - Event Response
- (void)tapAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(intMessageCell:didClickItemWithIntMessageModel:)]) {
        [self.delegate intMessageCell:self didClickItemWithIntMessageModel:self.intMessageModel];
    }
}
#pragma mark - Private Method
- (UILabel *)createContentLabel{
    UILabel *lab = [[UILabel alloc] init];
    lab.font = DWDFontContent;
    lab.textColor = DWDColorBody;
    return lab;
}


@end


