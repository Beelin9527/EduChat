//
//  DWDGrowUpRecordCell.m
//  EduChat
//
//  Created by apple on 3/3/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDGrowUpRecordCell.h"
#import "DWDGrowUpCellContentView.h"
#import "DWDGrowUpPicsView.h"
#import "DWDMenuButton.h"
#import "DWDGrowUpPraiseView.h"
#import "DWDGrowUpCellCommentView.h"


#import "DWDGrowUpRecordModel.h"

#import <UIImageView+WebCache.h>
#import <Masonry.h>
#import <YYLabel.h>

@interface DWDGrowUpRecordCell ()<DWDMenuButtonDelegate, DWDGrowUpCellCommentViewDelegate>

@property (nonatomic, weak) UIImageView *facePicImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *dateLabel;

//@property (nonatomic, weak) DWDGrowUpCellContentView *growUpContentView;

@property (nonatomic, weak) UIImageView *contentStartImageView;
@property (nonatomic, weak) YYLabel *contentLabel;


@property (nonatomic, weak) DWDGrowUpPicsView *picsView;
@property (nonatomic, weak) DWDMenuButton *menuButton;
@property (nonatomic, weak) DWDGrowUpPraiseView *praiseView;
@property (nonatomic, weak) DWDGrowUpCellCommentView *commentView;

@end

@implementation DWDGrowUpRecordCell

#pragma mark -publick method
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    [self setSubViewConstraints];
    
    return self;
}

#pragma mark - private method
- (void)setSubViewConstraints {
    //设置界面
    UIImageView *facePicImageView = [UIImageView new];
    [self.contentView addSubview:facePicImageView];
    
    UILabel *nameLabel = [UILabel new];
    [self.contentView addSubview:nameLabel];
    
    UILabel *dateLabel = [UILabel new];
    dateLabel.textColor = DWDRGBColor(153, 153, 153);
    [self.contentView addSubview:dateLabel];
    
//    DWDGrowUpCellContentView *growUpContentView = [DWDGrowUpCellContentView new];
//    [self.contentView addSubview:growUpContentView];
    UIImageView *contentStartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_description_recording_normal"]];
    [self.contentView addSubview:contentStartImageView];
//    
    YYLabel *contentLabel = [YYLabel new];
    
    contentLabel.font = DWDFontContent;
    contentLabel.preferredMaxLayoutWidth = DWDScreenW - pxToW(20) - pxToW(57);
    [self.contentView addSubview:contentLabel];
    
    
    
    DWDGrowUpPicsView *picsView = [DWDGrowUpPicsView new];
    [self.contentView addSubview:picsView];
    
    //设置menu button
    DWDMenuButton *menuButton = [DWDMenuButton buttonWithType:UIButtonTypeCustom];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"ic_comment_album_details_normal"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    menuButton.delegate = self;
    [self.contentView addSubview:menuButton];

    
    DWDGrowUpPraiseView *praiseView = [DWDGrowUpPraiseView new];

    [self.contentView addSubview:praiseView];
    
    DWDGrowUpCellCommentView *commentView = [DWDGrowUpCellCommentView new];
    commentView.delegate = self;
    [self.contentView addSubview:commentView];
    
    
    self.facePicImageView = facePicImageView;
    self.nameLabel = nameLabel;
    self.dateLabel = dateLabel;
    
//    self.growUpContentView = growUpContentView;
    
    self.contentStartImageView = contentStartImageView;
    self.contentLabel = contentLabel;
    
    self.picsView = picsView;
    self.menuButton = menuButton;
    self.praiseView = praiseView;
    self.commentView = commentView;
    
    [facePicImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.top).offset(pxToW(20));
        make.left.equalTo(self.contentView.left).offset(pxToW(20));
        make.width.mas_equalTo(pxToW(60));
        make.height.mas_equalTo(pxToW(60));
    }];
    
    
    [nameLabel makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.contentView.top).offset(pxToW(36));
        make.centerY.equalTo(self.contentView.top).offset(pxToW(50));
        make.left.equalTo(facePicImageView.right).offset(pxToW(20));
    }];
    
    [dateLabel makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.right).offset(-pxToW(20));
        make.top.equalTo(self.contentView.top).offset(pxToW(36));
    }];
    
//    [growUpContentView makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.facePicImageView.bottom).offset(pxToW(15));
//        make.left.equalTo(self.contentView.left).offset(pxToW(6));
//        make.right.equalTo(self.contentView.right).offset(-pxToW(20));
//    }];
    [contentStartImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.facePicImageView.bottom).offset(pxToW(15));
        make.left.equalTo(self.contentView.left).offset(pxToW(15));
        make.height.width.mas_equalTo(pxToW(44));
    }];
    
    [contentLabel makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.facePicImageView.bottom).offset(pxToW(15));
        make.top.equalTo(contentStartImageView);
        make.left.equalTo(contentStartImageView.right).offset(pxToW(6));
        make.right.equalTo(self.contentView.right).offset(-pxToW(20));
    }];
    
    [picsView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLabel.bottom).offset(20);
        make.left.equalTo(self.contentView.left).offset(20);
        make.right.equalTo(self.contentView.right).offset(-14);
    }];
    
    [menuButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.picsView.bottom);
        make.right.equalTo(self.contentView.right).offset(-10);
        make.width.mas_equalTo(pxToW(44));
        make.height.mas_equalTo(pxToW(44));
    }];
    
    [praiseView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.menuButton.bottom).offset(pxToW(14));
        make.left.equalTo(self.contentView.left).offset(pxToW(14));
        make.right.equalTo(self.contentView.right).offset(-pxToW(20));
    }];
    
    [commentView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.praiseView.bottom);
        make.left.equalTo(self.contentView.left).offset(pxToW(14));
        make.right.equalTo(self.contentView.right).offset(-pxToW(20));
        make.bottom.equalTo(self.contentView.bottom).offset(-pxToW(20));
    }];
    [super updateConstraints];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}
#pragma mark - event response

- (void)menuButtonDidClick:(DWDMenuButton *)button {
    [self.menuButton menuButtonClick:button];
}

#pragma mark - DWDMenuButtonDelegate
- (void)menuButtonDidClickZanButton:(DWDMenuButton *)menuBtn {
       [[NSNotificationCenter defaultCenter] postNotificationName:@"DWDMenuButtonzanClickNotification" object:nil userInfo:[NSDictionary dictionaryWithObject:self.dataModel forKey:@"growupModel"]];
}

- (void)menuButtonDidclickCommitButton:(DWDMenuButton *)menuBtn {
      [[NSNotificationCenter defaultCenter] postNotificationName:@"DWDMenuButtoncommentClickNotification" object:nil userInfo:[NSDictionary dictionaryWithObject:self.dataModel forKey:@"growupModel"]];
}

#pragma mark - DWDGrowUpCellCommentViewDelegate
- (void)commentView:(DWDGrowUpCellCommentView *)commentView didClickCustId:(NSNumber *)custId {
    if ([self.delegate respondsToSelector:@selector(recordCell:didClickCommentViewWithCustId:)]) {
        [self.delegate recordCell:self didClickCommentViewWithCustId:custId];
    }
}

- (void)commentView:(DWDGrowUpCellCommentView *)commentView didClickLabelWithCustId:(NSNumber *)custId {
    if ([self.delegate respondsToSelector:@selector(recordCell:didClickCommentViewWithCustId:)]) {
        [self.delegate recordCell:self didClickCommentViewContentLabelWithCustId:custId];
    }
}


#pragma mark - setter / getter

- (void)setDataModel:(DWDGrowUpRecordModel *)dataModel {
    _dataModel = dataModel;
    
    //设置界面数据
    [_facePicImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.author.photokey] placeholderImage:nil];
    
    _nameLabel.text = dataModel.author.name;
    
    _dateLabel.text = dataModel.author.addtime;
    
    
    
//    _growUpContentView.record = dataModel.record;
    
    _contentLabel.text = dataModel.record.content;
    if (dataModel.record.content.length > 200) {
        _contentLabel.backgroundColor = DWDRGBColor(231, 231, 231);
        _contentLabel.numberOfLines = 2;
        WEAKSELF;
        _contentLabel.textTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
            
            if ([weakSelf.delegate respondsToSelector:@selector(recordCell:didClickContentLabelWithContent:)]) {
                [weakSelf.delegate recordCell:self didClickContentLabelWithContent:dataModel.record.content];
            }
            
        };
    } else {
        _contentLabel.backgroundColor = nil;
        _contentLabel.numberOfLines = 0;
        _contentLabel.textTapAction = nil;
    }
    
    
    _picsView.picsArray = dataModel.photos;
    
    if (dataModel.praises.count == 0 || dataModel.praises == nil) {
        _praiseView.hidden = YES;
        
        [_praiseView updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    } else {
        _praiseView.hidden = NO;
        [_praiseView remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.menuButton.bottom).offset(pxToW(14));
            make.left.equalTo(self.contentView.left).offset(pxToW(14));
            make.right.equalTo(self.contentView.right).offset(-pxToW(20));
        }];
        _praiseView.praiseArray = dataModel.praises;
    }
    _commentView.commentsArray = dataModel.comments;
    [super updateConstraints];
    
    //    

}
@end
