//
//  DWDClassNotificationCell.m
//  EduChat
//
//  Created by Superman on 15/11/30.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassNotificationCell.h"
#import <Masonry.h>

#import "DWDClassNotificatoinListEntity.h"
@interface DWDClassNotificationCell()
@property (nonatomic , weak) UIImageView *iconView;
@property (nonatomic , weak) UILabel *nameLabel;
@property (nonatomic , weak) UILabel *dateLabel;
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
        iconView.image = [UIImage imageNamed:@"AvatarOther"];
        _iconView = iconView;
        [self.contentView addSubview:iconView];
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = DWDFontBody;
        [nameLabel setTextColor:DWDColorSecondary];
        _nameLabel = nameLabel;
        [self.contentView addSubview:nameLabel];
        
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.textAlignment = NSTextAlignmentRight;
        dateLabel.font = DWDFontMin;
        [dateLabel setTextColor:DWDColorSecondary];
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
    
    _nameLabel.text = entity.title;
    _dateLabel.text = entity.creatTime;
    
}
@end
