//
//  DWDClassGrowUpCell.m
//  EduChat
//
//  Created by Superman on 15/12/8.
//  Copyright © 2015年 dwd. All rights reserved.

#import "DWDClassGrowUpCell.h"
#import "DWDMenuButton.h"

#import "DWDGrowUpRecordFrame.h"
#import "DWDGrowUpRecordModel.h"
#import "DWDPhotoInfoModel.h"

#import "DWDMenuController.h"

#import "NSString+Extension.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry.h>
#import <YYText.h>


@interface DWDClassGrowUpCell()
@property (nonatomic , weak) UIImageView *iconView;
@property (nonatomic , weak) UILabel *nameLabel;
@property (nonatomic , weak) UILabel *dateLabel;
@property (nonatomic , weak) UIImageView *midLittleImageView;
@property (nonatomic , weak) UILabel *bodyLabel;
@property (nonatomic , weak) UILabel *allBodyBtnLabel;


@property (nonatomic , weak) UIButton *commentBtn;

@property (nonatomic , weak) UIView *commentView;
@property (nonatomic , weak) UIImageView *flowerView;
@property (nonatomic , weak) YYLabel *topFlowerLabel;
@property (nonatomic , weak) UIButton *extentdBtn;

@property (nonatomic , strong) NSMutableArray *pictures;
@property (nonatomic , strong) NSMutableArray *comments;

@property (nonatomic , strong) DWDMenuController *menuVc;

@end

@implementation DWDClassGrowUpCell

- (void)zanClick:(UIMenuController *)menuVc{
    DWDLog(@"仅用于解决警告");
}

- (void)commentClick:(UIMenuController *)menuVc{
    DWDLog(@"仅用于解决警告");
}

- (void)meneControllerAppear:(UIButton *)btn{
    
    DWDMenuController *menuVc = [[DWDMenuController alloc] init];
    _menuVc = menuVc;
    menuVc.growupModel = self.growUpRecordFrame.growupModel;
    menuVc.cell = self;
    [btn becomeFirstResponder];
    UIMenuItem *zan = [[UIMenuItem alloc] initWithTitle:@"点赞" action:@selector(zanClick:)];
    UIMenuItem *comment = [[UIMenuItem alloc] initWithTitle:@"评论" action:@selector(commentClick:)];
    
    [menuVc setMenuItems:[NSArray arrayWithObjects:zan,comment, nil]];
    
    CGRect rect = CGRectMake(0, btn.h * 0.5, btn.w, btn.h * 0.5);
    [menuVc setTargetRect:rect inView:btn];
    [menuVc setMenuVisible:YES animated:YES];
}

- (void)allBodyBtnFTap:(UITapGestureRecognizer *)tap{
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *imageview = [[UIImageView alloc] init];
        imageview.image = [UIImage imageNamed:@"AvatarOther"];
        _iconView = imageview;
        [self.contentView addSubview:_iconView];
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = DWDFontMin;
        _nameLabel = nameLabel;
        [self.contentView addSubview:nameLabel];
        
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.font = DWDFontMin;
        _dateLabel = dateLabel;
        [self.contentView addSubview:dateLabel];
        
        UIImageView *midLittleImageView = [[UIImageView alloc] init];
        midLittleImageView.image = [UIImage imageNamed:@"ic_description_recording_normal"];
        _midLittleImageView = midLittleImageView;
        [self.contentView addSubview:midLittleImageView];
        
        UILabel *bodyLabel = [[UILabel alloc] init];
        bodyLabel.font = DWDFontContent;
        bodyLabel.preferredMaxLayoutWidth = DWDScreenW - pxToW(78);
        bodyLabel.numberOfLines = 0;
        _bodyLabel = bodyLabel;
        [self.contentView addSubview:bodyLabel];
        
        UILabel *btnLabel = [[UILabel alloc] init];
        btnLabel.text = @"全文";
        btnLabel.textColor = DWDRGBColor(90, 136, 231);
        btnLabel.font = DWDFontContent;
        [btnLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(allBodyBtnFTap:)]];
        _allBodyBtnLabel = btnLabel;
        [self.contentView addSubview:btnLabel];
        
        _pictures = [NSMutableArray array];
        for (int i = 0; i < 9; i ++) {
            UIImageView *imageview = [[UIImageView alloc] init];
            [self.contentView addSubview:imageview];
            [_pictures addObject:imageview];
        }
        
        DWDMenuButton *combtn = [DWDMenuButton buttonWithType:UIButtonTypeCustom];
        combtn.bounds = CGRectMake(0, 0, pxToW(44), pxToH(44));
        
        [combtn setBackgroundImage:[UIImage imageNamed:@"ic_comment_album_details_normal"] forState:UIControlStateNormal];
        [combtn addTarget:self action:@selector(meneControllerAppear:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:combtn];
        _commentBtn = combtn;
        
        
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = DWDRGBColor(241, 241, 241);
        
        UIImageView *redFlower = [[UIImageView alloc] init];
        _flowerView = redFlower;
        redFlower.image = [UIImage imageNamed:@"ic_good_red"];
        [view addSubview:redFlower];
        
        YYLabel *topFlowerLabel = [YYLabel new];
        [topFlowerLabel setTextColor:DWDRGBColor(90, 136, 231)];
        topFlowerLabel.font = DWDFontContent;
        _topFlowerLabel = topFlowerLabel;
        [view addSubview:topFlowerLabel];
        
        UIButton *extendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [extendBtn setTitle:@"展开" forState:UIControlStateNormal];
        [extendBtn setTitleColor:DWDRGBColor(90, 136, 231) forState:UIControlStateNormal];
        [extendBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [extendBtn addTarget:self action:@selector(extendBtnClick:) forControlEvents:UIControlEventTouchDown];
        [extendBtn.titleLabel setFont:DWDFontContent];
        _extentdBtn = extendBtn;
        [view addSubview:extendBtn];
        [self.contentView addSubview:view];
        _commentView = view;
        
        _comments = [NSMutableArray array];
        for (int i = 0; i < 10; i ++) { // 10个评论数据
            YYLabel *label = [YYLabel new];
            label.numberOfLines = 0;
            label.tag = i;
            label.font = DWDFontContent;
            label.highlightTapAction = ^(UIView *containerView , NSAttributedString *text , NSRange range , CGRect rect){
                
                DWDLogFunc;
            };
            
            [_commentView addSubview:label];
            [_comments addObject:label];
        }
        
    }
    return self;
}

- (void)extendBtnClick:(UIButton *)btn{
    DWDLogFunc;
    // 点击展开
    if ([btn.titleLabel.text isEqualToString:@"展开"]) {
        [btn setTitle:@"收起" forState:UIControlStateNormal];
        for (int i = 10; i < self.growUpRecordFrame.growupModel.comments.count; i ++) {
            YYLabel *label = [YYLabel new];
            label.tag = i;
            label.font = DWDFontContent;
            label.numberOfLines = 0;
            [self.commentView addSubview:label];
            label.highlightTapAction = ^(UIView *containerView , NSAttributedString *text , NSRange range , CGRect rect){
                DWDLog(@"点击展开后的评论的nickname");
            };
            
            [self.comments addObject:label];
        }
        
        // 重新计算Frames,把新加进来的评论也算进去
        self.growUpRecordFrame.reCountFrames(self.comments);
        
        // 刷新表格
        if ([self.extendBtnDelegate respondsToSelector:@selector(extendBtnClickWithIndex:)]) {
            [self.extendBtnDelegate extendBtnClickWithIndex:self.cellIndexPath];
        }
    }else{
        [btn setTitle:@"展开" forState:UIControlStateNormal];
        int count = (int)self.commentView.subviews.count - 10 - 3;
        for (int i = 0; i < count; i++) {
            DWDLog(@"%zd=======", self.commentView.subviews.count);
            // 从数组中移除指针
            [self.comments removeObjectAtIndex:self.comments.count - 1 - i];
            
            // 从view中移除控件
            YYLabel *label = self.commentView.subviews[self.commentView.subviews.count - 1 - i];
            [label removeFromSuperview];
        }
        
        // 重新计算Frames
        self.growUpRecordFrame.reCountFrames(self.comments);
        // 刷新表格
        if ([self.extendBtnDelegate respondsToSelector:@selector(extendBtnClickWithIndex:)]) {
            [self.extendBtnDelegate extendBtnClickWithIndex:self.cellIndexPath];
        }
    }
    
}

+ (instancetype)cellWithTableView:(UITableView *)tableview{
    static NSString *ID = @"cell";
    DWDClassGrowUpCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[DWDClassGrowUpCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)setGrowUpRecordFrame:(DWDGrowUpRecordFrame *)growUpRecordFrame{
    _growUpRecordFrame = growUpRecordFrame;
    
    DWDGrowUpRecordModel *growModel = growUpRecordFrame.growupModel;
    
    _iconView.frame = growUpRecordFrame.iconViewF;
    [_iconView setImageWithPhotoKey:growModel.author.photokey placeholderImage:[UIImage imageNamed:@"AvatarMe"]];
    
    _nameLabel.frame = growUpRecordFrame.nameLabelF;
    _nameLabel.text = growModel.author.name;
    
    _dateLabel.frame = growUpRecordFrame.dateLabelF;
    _dateLabel.text = growModel.author.addtime;
    
    _midLittleImageView.frame = growUpRecordFrame.midLittleImageF;
    
    _bodyLabel.frame = growUpRecordFrame.bodyLabelF;
    _bodyLabel.text = growModel.record.content;
    
//    _allBodyBtnLabel.frame = growUpRecordFrame.allBodyBtnF;
    _allBodyBtnLabel.frame = CGRectZero;
    
    // 配图
    for (int i = 0; i < self.pictures.count; i++) {
        UIImageView *picture = self.pictures[i];
        if (i < growModel.photos.count) {
            picture.hidden = NO;
            picture.frame = [growUpRecordFrame.picturesFrames[i] CGRectValue];
            DWDPhotoInfoModel *photoinfo = growModel.photos[i];
            
            [picture sd_setImageWithURL:[NSURL URLWithString:photoinfo.photokey] placeholderImage:[UIImage imageNamed:@"AssetsPickerLocked"]];
        }else{
            picture.hidden = YES;
        }
    }
    
    
    _commentBtn.frame = growUpRecordFrame.commentBtnF;
    
    _topFlowerLabel.frame = growUpRecordFrame.zanPeopleF;
    _flowerView.frame = growUpRecordFrame.flowerViewF;
    _commentView.frame = growUpRecordFrame.commentContainerF;
    
    if (growUpRecordFrame.growupModel.comments.count > 0) {
        _flowerView.hidden = NO;
        _topFlowerLabel.hidden = NO;
        _commentView.hidden = NO;
    }else{
        _flowerView.hidden = YES;
        _topFlowerLabel.hidden = YES;
        _commentView.hidden = YES;
    }
    
    if (self.comments.count >= 10 && growUpRecordFrame.growupModel.comments.count > 10) {
        _extentdBtn.hidden = NO;
        _extentdBtn.frame = growUpRecordFrame.extendBtnF;
    }else{
        _extentdBtn.hidden = YES;
    }
    
    NSMutableString *topNickStr = [[NSMutableString alloc] init];
    for (int i = 0; i < self.comments.count; i++) {
        if (i < growUpRecordFrame.growupModel.comments.count) {
            DWDGrowUpComments *comment = growUpRecordFrame.growupModel.comments[i];
            
            NSMutableAttributedString *commentAttrStr = [self creatAttributeStringWithName:comment.nickname commentTxt:comment.commentTxt];
            // 赋值
            YYLabel *label = self.comments[i];
            label.hidden = NO;
            label.frame = [growUpRecordFrame.commentsFrames[i] CGRectValue];
            label.attributedText = commentAttrStr;
            
            // 拼接赞
            NSString *topNickName;
            if (i == self.comments.count - 1) {
                topNickName = [NSString stringWithFormat:@"%@",comment.nickname];
            }else{
                topNickName = [NSString stringWithFormat:@"%@,",comment.nickname];
            }
            
            [topNickStr appendString:topNickName];
            
        }else{
            YYLabel *label = self.comments[i];
            label.hidden = YES;
        }
    }
    
    // 赞的人有哪些 需要服务器返回!!!!
    if (_addNewZanPeopleName.length > 0) {
        [topNickStr appendString:_addNewZanPeopleName];
    }
    _topFlowerLabel.text = topNickStr;

}

- (NSMutableAttributedString *)creatAttributeStringWithName:(NSString *)nickName commentTxt:(NSString *)text {
    // 创建评论属性文字,拼接
    NSString *str1 = [NSString stringWithFormat:@"%@:%@",nickName,text];
    NSMutableAttributedString *commentAttrStr = [[NSMutableAttributedString alloc] initWithString:str1];
    NSRange range = NSMakeRange(0, nickName.length);
    
    commentAttrStr.yy_font = DWDFontContent;
    [commentAttrStr yy_setColor:DWDRGBColor(90, 136, 231) range:range];
    
    YYTextBorder *border = [YYTextBorder borderWithFillColor:[UIColor grayColor] cornerRadius:3];
    YYTextHighlight *highlight = [YYTextHighlight new];
    [highlight setColor:[UIColor whiteColor]];
    [highlight setBackgroundBorder:border];
    
    [commentAttrStr yy_setTextHighlight:highlight range:range];
    
    return commentAttrStr;
}


- (void)nickNameTap:(UITapGestureRecognizer *)tap{
    DWDLogFunc;
}

@end
