//
//  DWDClassGrowUpCell.m
//  EduChat
//
//  Created by Superman on 15/12/8.
//  Copyright © 2015年 dwd. All rights reserved.

#import "DWDClassGrowUpCell.h"

#import "DWDMenuButton.h"
#import "DWDGrowUpBodyLabel.h"
#import "DWDAllBodyButton.h"

#import "DWDGrowUpRecordFrame.h"
#import "DWDGrowUpRecordModel.h"
#import "DWDPhotoInfoModel.h"

#import "DWDMenuController.h"
#import "PreviewImageView.h"

#import "DWDChatMsgReplaceFace.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry.h>
#import <YYText.h>
#import <YYModel.h>


@interface DWDClassGrowUpCell() <DWDMenuButtonDelegate>
@property (nonatomic , weak) UIImageView *iconView;
@property (nonatomic , weak) UILabel *nameLabel;
@property (nonatomic , weak) UILabel *dateLabel;
@property (nonatomic , weak) UIImageView *midLittleImageView;
@property (nonatomic , weak) DWDGrowUpBodyLabel *bodyLabel;
@property (nonatomic , weak) UILabel *allBodyBtnLabel;
@property (nonatomic, copy) NSMutableDictionary *mapper;
//展开全文按钮
@property (nonatomic, weak) DWDAllBodyButton *allBodyButton;


@property (nonatomic , weak) UIButton *commentBtn;

@property (nonatomic , weak) UIView *commentView;
@property (nonatomic , weak) UIImageView *flowerView;
@property (nonatomic , weak) YYLabel *topFlowerLabel;
@property (nonatomic , weak) UIButton *extentdBtn;

@property (nonatomic , strong) NSMutableArray *pictures;
@property (nonatomic , strong) NSMutableArray *comments;

@property (nonatomic , strong) UIMenuController *menuVc;

@end

@implementation DWDClassGrowUpCell

//图片预览
- (void)pictureTapGestureRecognizer:(UITapGestureRecognizer *)tap {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIImageView *picture = (UIImageView *)tap.view;
    CGRect startRect = [picture convertRect:picture.bounds toView:keyWindow];
    DWDMarkLog(@"startRect%@", NSStringFromCGRect(startRect));
    [PreviewImageView showPreviewImage:picture.image startImageFrame:startRect inView:keyWindow viewFrame:keyWindow.bounds];
    
    
}

- (void)zanClick:(UIMenuController *)menuVc{
    DWDLog(@"仅用于解决警告");
}

- (void)commentClick:(UIMenuController *)menuVc{
    DWDLog(@"仅用于解决警告");
}

- (void)meneControllerAppear:(UIButton *)btn{
    
    UIMenuController *menuVc = [UIMenuController sharedMenuController];
    _menuVc = menuVc;
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

//点击展开内容全文
- (void)allBodyButtonClick:(DWDAllBodyButton *)button {
    
    
    self.growUpRecordFrame.growupModel.expandButtonOn = !self.growUpRecordFrame.growupModel.expandButtonOn;
    if (self.growUpRecordFrame.growupModel.expandButtonOn) {
        [self.growUpRecordFrame setGrowupModel:self.growUpRecordFrame.growupModel];
        [_bodyLabel expandLabel];
        [button setTitle:@"收起" forState:UIControlStateNormal];
    } else {
        [self.growUpRecordFrame setGrowupModel:self.growUpRecordFrame.growupModel];
        [_bodyLabel contractLabel];
        [button setTitle:@"全文" forState:UIControlStateNormal];
    }
    
    if ([self.extendBtnDelegate respondsToSelector:@selector(extendBtnClickWithIndex:)]) {
        [self.extendBtnDelegate extendBtnClickWithIndex:self.cellIndexPath];
    }
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
        
//        DWDGrowUpBodyLabel *bodyLabel = [[UILabel alloc] init];
//        bodyLabel.font = DWDFontContent;
//        bodyLabel.preferredMaxLayoutWidth = DWDScreenW - pxToW(78);
//        bodyLabel.numberOfLines = 0;
        DWDGrowUpBodyLabel *bodyLabel = [[DWDGrowUpBodyLabel alloc] init];
        _bodyLabel = bodyLabel;
        [self.contentView addSubview:bodyLabel];
        
        UILabel *btnLabel = [[UILabel alloc] init];
        btnLabel.text = @"全文";
        btnLabel.textColor = DWDRGBColor(90, 136, 231);
        btnLabel.font = DWDFontContent;
        [btnLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(allBodyBtnFTap:)]];
        _allBodyBtnLabel = btnLabel;
        [self.contentView addSubview:btnLabel];
        
        
        //allBodyButton添加
        DWDAllBodyButton *allBodyButton = [DWDAllBodyButton buttonWithType:UIButtonTypeCustom];
        [allBodyButton setTitle:@"全文" forState:UIControlStateNormal];
        [allBodyButton setTitleColor:DWDRGBColor(90, 136, 231) forState:UIControlStateNormal];
        [allBodyButton.titleLabel setFont:DWDFontContent];
        [allBodyButton addTarget:self action:@selector(allBodyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:allBodyButton];
        _allBodyButton = allBodyButton;
        
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
        combtn.delegate = self;
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
    _growUpRecordFrame.growupModel.record.logId = growUpRecordFrame.growupModel.record.logId;
    _growUpRecordFrame.growupModel.record.albumId = growUpRecordFrame.growupModel.record.albumId;
    
    DWDGrowUpRecordModel *growModel = growUpRecordFrame.growupModel;
    
    _iconView.frame = growUpRecordFrame.iconViewF;
  
    [_iconView sd_setImageWithURL:[NSURL URLWithString:growModel.author.photokey] placeholderImage:DWDDefault_MeBoyImage];
    
    _nameLabel.frame = growUpRecordFrame.nameLabelF;
    _nameLabel.text = growModel.author.name;
    
    _dateLabel.frame = growUpRecordFrame.dateLabelF;
    _dateLabel.text = growModel.author.addtime;
    _dateLabel.textColor = DWDColorSecondary;
    _dateLabel.textAlignment = NSTextAlignmentRight;
    
    _midLittleImageView.frame = growUpRecordFrame.midLittleImageF;
    
    //全文内容label
    _bodyLabel.frame = growUpRecordFrame.bodyLabelF;
    _bodyLabel.text = growModel.record.content;
    [self.bodyLabel sizeToFit];
//    _allBodyBtnLabel.frame = growUpRecordFrame.allBodyBtnF;
    
    //布局全文展开按钮
    _allBodyButton.frame = growUpRecordFrame.allBodyBtnF;
    if (growModel.isExpandBody) {
        _allBodyButton.hidden = NO;
    } else {
        _allBodyButton.hidden = YES;
    }
    
    // 配图
    for (int i = 0; i < self.pictures.count; i++) {
        UIImageView *picture = self.pictures[i];
        if (i < growModel.photos.count) {
            picture.hidden = NO;
            picture.frame = [growUpRecordFrame.picturesFrames[i] CGRectValue];
            DWDPhotoInfoModel *photoinfo = growModel.photos[i];
            
            [picture sd_setImageWithURL:[NSURL URLWithString:photoinfo.photokey] placeholderImage:[UIImage imageNamed:@"AssetsPickerLocked"]];

            UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureTapGestureRecognizer:)];
            picture.userInteractionEnabled = YES;
            [picture addGestureRecognizer:tapGR];
            self.pictures[i] = picture;
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
            
            YYLabel *label = [YYLabel new];
//            YYTextSimpleEmoticonParser *parser = [YYTextSimpleEmoticonParser new];
//            parser.emoticonMapper = self.mapper;
//            label.textParser = parser;
//            label = self.comments[i];
            

            //解析表情
//            NSMutableDictionary *mapper = [NSMutableDictionary new];
//            NSString *facePlistPath = [[NSBundle mainBundle] pathForResource:@"face" ofType:@"plist"];
//            NSArray *face = [NSArray arrayWithContentsOfFile:facePlistPath];
//            NSMutableArray *faceName = [NSMutableArray new];
//            for (NSDictionary *faceDic in face) {
//                [faceName addObject:faceDic[@"faceName"]];
//            }
//            for (int i = 0; i < 19; i ++) {
//                UIImage *image = [UIImage imageNamed:faceName[i]];
//                DWDMarkLog(@"%@", image);
//                mapper[faceName[i]] = image;
//            }
            
            
            WEAKSELF;
            label.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                if ([weakSelf.extendBtnDelegate respondsToSelector:@selector(tableViewCell:ClickUserNamePushToUserInfo:)]) {
                    [weakSelf.extendBtnDelegate tableViewCell:weakSelf ClickUserNamePushToUserInfo:comment.custId];
                }
            };
            
            label.hidden = NO;
            label.frame = [growUpRecordFrame.commentsFrames[i] CGRectValue];
            label.attributedText = commentAttrStr;
            
        } else{
            YYLabel *label = self.comments[i];
            label.hidden = YES;
        }
            
    }
        // 拼接赞
        //growUpRecordFrame.growupModel.praises
        NSString *topNickName;
    for (int i = 0; i < growUpRecordFrame.growupModel.praises.count; i ++) {
        NSDictionary *praise = growUpRecordFrame.growupModel.praises[0];
        topNickName = praise[@"nickname"];
        if (i == 0) {
            topNickName = [NSString stringWithFormat:@"%@",topNickName];
        }else{
            topNickName = [NSString stringWithFormat:@",%@",topNickName];
        }
        [topNickStr appendString:topNickName];
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

#pragma mark - DWDMenuButtonDelegate

- (void)menuButtonDidclickCommitButton:(DWDMenuButton *)menuBtn {
    DWDLogFunc;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DWDMenuButtoncommentClickNotification" object:nil userInfo:[NSDictionary dictionaryWithObject:self.growUpRecordFrame.growupModel forKey:@"growupModel"]];

}

- (void)menuButtonDidClickZanButton:(DWDMenuButton *)menuBtn {
    DWDMarkLog(@"zanClick");
    DWDLogFunc;

//    [[NSNotificationCenter defaultCenter] postNotificationName:@"DWDMenuButtonzanClickNotification" object:nil userInfo:[NSDictionary dictionaryWithObject:self.growUpRecordFrame.growupModel forKey:@"growupModel"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DWDMenuButtonzanClickNotification" object:nil userInfo:[NSDictionary dictionaryWithObject:self.growUpRecordFrame.growupModel forKey:@"growupModel"]];
    
}

#pragma mark - setter / getter

- (NSMutableDictionary *)mapper {
    if (!_mapper) {
        NSMutableDictionary *mapper = [NSMutableDictionary new];
        mapper[@"[anger]"] = [UIImage imageNamed:@"[anger]"];
        mapper[@"[awkward]"] = [UIImage imageNamed:@"[awkward]"];
        mapper[@"[cold]"] = [UIImage imageNamed:@"[cold]"];
        mapper[@"[like]"] = [UIImage imageNamed:@"[like]"];
        mapper[@"[cool]"] = [UIImage imageNamed:@"[cool]"];
        mapper[@"[crazy]"] = [UIImage imageNamed:@"[crazy]"];
        mapper[@"[curled]"] = [UIImage imageNamed:@"[curled]"];
        mapper[@"[naughty]"] = [UIImage imageNamed:@"[naughty]"];
        mapper[@"[proud]"] = [UIImage imageNamed:@"[proud]"];
        mapper[@"[sad]"] = [UIImage imageNamed:@"[sad]"];
        mapper[@"[shutup]"] = [UIImage imageNamed:@"[shutup]"];
        mapper[@"[shy]"] = [UIImage imageNamed:@"[shy]"];
        mapper[@"[sleep]"] = [UIImage imageNamed:@"[sleep]"];
        mapper[@"[smile]"] = [UIImage imageNamed:@"[smile]"];
        mapper[@"[spit]"] = [UIImage imageNamed:@"[spit]"];
        mapper[@"[stunned]"] = [UIImage imageNamed:@"[stunned]"];
        mapper[@"[surprised]"] = [UIImage imageNamed:@"[surprised]"];
        mapper[@"[tears]"] = [UIImage imageNamed:@"[tears]"];
        mapper[@"[toothy]"] = [UIImage imageNamed:@"[toothy]"];
        mapper[@"[weep]"] = [UIImage imageNamed:@"[weep]"];
        
        _mapper = mapper;
    }
    return _mapper;
}

@end
