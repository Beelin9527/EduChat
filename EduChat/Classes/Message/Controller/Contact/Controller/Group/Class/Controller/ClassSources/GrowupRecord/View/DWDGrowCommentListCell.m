//
//  DWDGrowCommentListCell.m
//  EduChat
//
//  Created by Superman on 16/1/6.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDGrowCommentListCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface DWDGrowCommentListCell()
@property (nonatomic , weak) UIImageView *iconView;
@property (nonatomic , weak) UIImageView *pictureView;
@property (nonatomic , weak) UILabel *nameLabel;
@property (nonatomic , weak) UILabel *bodyLabel;
@property (nonatomic , weak) UILabel *dateLabel;


@end

@implementation DWDGrowCommentListCell

+ (instancetype)cellWithTableView:(UITableView *)tableview{
    static NSString *ID = @"cell";
    DWDGrowCommentListCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DWDGrowCommentListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIImageView *iconview = [[UIImageView alloc] init];
        _iconView = iconview;
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = DWDFontBody;
        _nameLabel = nameLabel;
        UIImageView *pictureView = [[UIImageView alloc] init];
        _pictureView = pictureView;
        UILabel *bodyLabel = [[UILabel alloc] init];
        bodyLabel.font = DWDFontContent;
        bodyLabel.numberOfLines = 0;
        _bodyLabel = bodyLabel;
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.font = DWDFontMin;
        _dateLabel = dateLabel;
        [self.contentView addSubview:iconview];
        [self.contentView addSubview:nameLabel];
        [self.contentView addSubview:pictureView];
        [self.contentView addSubview:bodyLabel];
        [self.contentView addSubview:dateLabel];
    }
    return self;
}

- (void)setCommentList:(DWDGrowUpRecordCommentList *)commentList{
    _commentList = commentList;
    
    _iconView.frame = commentList.iconViewF;
    _iconView.image = [UIImage imageNamed:@"AvatarMe"];
    
    NSString *name;
    if (commentList.forNickname.length > 0) {
        name = [NSString stringWithFormat:@"%@回复%@",commentList.nickname,commentList.forNickname];
    }else{
        name = commentList.nickname;
    }
    
    _nameLabel.frame = commentList.nameLabelF;
    _nameLabel.text = name;
    
    _pictureView.frame = commentList.pictureF;
    [_pictureView sd_setImageWithURL:[NSURL URLWithString:commentList.photokey] placeholderImage:[UIImage imageNamed:@"AvatarOther"]];
    
    _bodyLabel.frame = commentList.bodyLabelF;
    _bodyLabel.text = commentList.commentTxt;
    
    _dateLabel.frame = commentList.dateLabelF;
    _dateLabel.text = commentList.addtime;
}
@end
