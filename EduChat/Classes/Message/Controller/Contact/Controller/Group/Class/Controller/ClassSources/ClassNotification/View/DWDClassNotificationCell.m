//
//  DWDClassNotificationCell.m
//  EduChat
//
//  Created by Superman on 15/11/30.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassNotificationCell.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>

#import "DWDClassNotificatoinListEntity.h"
@interface DWDClassNotificationCell()
@property (nonatomic , weak) UIImageView *iconView;
@property (nonatomic , weak) UILabel *nameLabel;
@property (nonatomic , weak) UILabel *dateLabel;
@property (nonatomic, strong) UIView *imageContainerView;
@end

@implementation DWDClassNotificationCell

- (void)awakeFromNib {
    // Initialization code
}

+ (instancetype)cellWithTableView:(UITableView *)tableview{
    static NSString *ID = @"cell";
    DWDClassNotificationCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[DWDClassNotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//        iconView.image = ;
        _iconView = iconView;
        [self.contentView addSubview:iconView];
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = DWDFontBody;
        _nameLabel = nameLabel;
        [self.contentView addSubview:nameLabel];
        
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.textAlignment = NSTextAlignmentRight;
        dateLabel.font = DWDFontMin;
        _dateLabel = dateLabel;
        [self.contentView addSubview:dateLabel];
        
        [iconView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.superview.left).offset(pxToW(20));
            make.top.equalTo(iconView.superview.top).offset(pxToH(20));
            make.width.equalTo(@(pxToW(100)));
            make.height.equalTo(@(pxToH(100)));
        }];
        
        [nameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.right).offset(pxToW(20));
            make.centerY.equalTo(iconView.centerY);
            make.width.equalTo(@(pxToW(280)));
            make.height.equalTo(@(pxToH(50)));

        }];
        
        [dateLabel makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(dateLabel.superview.right).offset(-pxToW(20));
            make.centerY.equalTo(iconView.centerY);
        }];
    }
    return self;
}

- (void)setEntity:(DWDClassNotificatoinListEntity *)entity
{
    _entity = entity;
    
    NSString *photoKey = [[entity.firstPhoto imgKey] stringByAppendingString:@"100w_100h_1e_80Q"];
    
    [_iconView sd_setImageWithURL:[NSURL URLWithString:photoKey] placeholderImage:[UIImage imageNamed:@"ic_notice_normal"]];
    _nameLabel.text = entity.title;
    _dateLabel.text = entity.creatTime;
    
    // 0未阅
    // 1已阅
    BOOL readed = false;
    if ([entity.readed isEqual:@0]) {
        readed = NO;
    }
    if ([entity.readed isEqual:@1]) {
        readed = YES;
    }
    DWDMarkLog(@"self.entity.readed:%@\nreaded:%@", entity.readed, readed ? @"YES" : @"NO");
    [_nameLabel setTextColor:readed?DWDColorSecondary:DWDColorBody];
    [_dateLabel setTextColor:readed?DWDColorSecondary:DWDColorBody];
    
}
@end
