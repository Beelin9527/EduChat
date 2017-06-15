//
//  DWDGrowUpCell.m
//  EduChat
//
//  Created by KKK on 16/4/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDGrowUpCell.h"
#import "DWDGrowUpCellLayout.h"

#import "DWDGrowUpTouchImageView.h"
#import "DWDMenuButton.h"

#import "UIView+kkk_personalAdd.h"
#import "NSString+extend.h"

#import "NSDictionary+dwd_extend.h"

#import <UIImageView+WebCache.h>
#import <SDWebImageManager.h>

@implementation DWDUserStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    if (frame.size.width == 0 && frame.size.height == 0) {
        frame.size.width = DWDScreenW;
        frame.size.height = kCellHeadImageWidth + kCellPadding; //固定部分最大高度 图片高度 + 上方间距
    }
    self = [super initWithFrame:frame];
    
    //布局头像
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kCellPadding, kCellPadding, kCellHeadImageWidth, kCellHeadImageWidth)];
    [self addSubview:_headImageView];
    
    //布局名字
//    _nameLabel = [YYLabel new];
    CGFloat maxWidth = DWDScreenW - kCellPadding * 4 - [@"2000-00-00" boundingRectWithfont:[UIFont systemFontOfSize:kCellDateTimeFont]].width - kCellHeadImageWidth;
    _nameLabel = [[YYLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headImageView.frame) + kCellPadding, 0, maxWidth, 20)];
    _nameLabel.preferredMaxLayoutWidth = maxWidth;
    YYTextSimpleEmoticonParser *parser = [YYTextSimpleEmoticonParser new];
    parser.emoticonMapper = [NSDictionary dwd_emotionMapperDictionary];
    _nameLabel.textParser = parser;
    _nameLabel.textColor = kCellNameColor;
    _nameLabel.font = [UIFont systemFontOfSize:kCellNameFont];
//    _nameLabel.preferredMaxLayoutWidth = 100;
    [self addSubview:_nameLabel];
    //布局时间
    _dateTimeLabel = [UILabel new];
    _dateTimeLabel.textAlignment = NSTextAlignmentRight;
    _dateTimeLabel.font = [UIFont systemFontOfSize:kCellDateTimeFont];
    _dateTimeLabel.textColor = kCellDateTimeColor;
    [self addSubview:_dateTimeLabel];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGPoint center = (CGPoint){_nameLabel.center.x, 0};
    center.y = _headImageView.center.y;;
    
    _nameLabel.center = center;
    
    CGPoint center1 = (CGPoint){_dateTimeLabel.center.x, _headImageView.center.y};
    
    _dateTimeLabel.center = center1;
    
    CGRect frame = _dateTimeLabel.frame;
    frame.origin.x = DWDScreenW - kCellPadding - frame.size.width;
    _dateTimeLabel.frame = frame;
}

@end

@implementation DWDGrowUpContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (frame.size.width == 0) {
        frame.size.width = DWDScreenW;
    }
    self = [super initWithFrame:frame];

    //布局起始图片
//    _contentStartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_description_recording_normal"]];
//    _contentStartImageView.frame = CGRectMake(kCellStartContentImageLeftPadding, self.y, kCellHeadImageWidth, kCellHeadImageWidth);
//    [self addSubview:_contentStartImageView];
    //添加文本view
    _contentTextLabel = [YYLabel new];
    _contentTextLabel.displaysAsynchronously = YES;
    _contentTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    YYTextSimpleEmoticonParser *parser = [YYTextSimpleEmoticonParser new];
    parser.emoticonMapper = [NSDictionary dwd_emotionMapperDictionary];
    _contentTextLabel.textParser = parser;
    [self addSubview:_contentTextLabel];
    //添加展开按钮
    _contentExpandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_contentExpandButton.titleLabel setFont:[UIFont systemFontOfSize:kCellNameFont]];
    [_contentExpandButton addTarget:self action:@selector(contentExpandButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_contentExpandButton setTitleColor:kCellButtonColor forState:UIControlStateNormal];
    [self addSubview:_contentExpandButton];
    
    //添加图片容器view
    UIView *picContainerView = [UIView new];
    _picContainerView = picContainerView;
    [self addSubview:picContainerView];
    
    return self;
}

- (void)contentExpandButtonClick {
    
    if (self.cell.delegate && [self.cell.delegate respondsToSelector:@selector(growCellDidClickContentExpandButton:)]) {
        [self.cell.delegate growCellDidClickContentExpandButton:self.cell];
    }
    
}

@end

@interface DWDGrowUpCommentView ()

@property (nonatomic, weak) UIImageView *bgImgView;

@end

@implementation DWDGrowUpCommentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_good_red"]];
            _flowerImageView = imageView;
            [self addSubview:imageView];
            imageView.frame = CGRectMake(kCellPadding, kCellFlowerTopPadding, kCellFlowerWidth, kCellFlowerHeight);
            YYLabel *label = [YYLabel new];
            _praiseLabel = label;
            [self addSubview:label];
           
            UIView *commentsContainerView = [UIView new];
            _commentsContainerView = commentsContainerView;
            [self addSubview:commentsContainerView];
            
            UIView *lineView = [UIView new];
            lineView.frame = CGRectMake(0, 0, DWDScreenW - kCellPadding * 2, 1);
            lineView.backgroundColor = DWDRGBColor(221, 221, 221);
            _lineView = lineView;
            [self addSubview:lineView];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button.titleLabel setFont:[UIFont systemFontOfSize:kCellDateTimeFont]];
            [button setTitleColor:kCellButtonColor forState:UIControlStateNormal];
            [button addTarget:self action:@selector(commentExpandButtonClick) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            _commentExpandButton = button;
            
            UIImage *image = [UIImage imageNamed:@"bg_comment_content_growth_record"];
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.5, image.size.width * 0.5, image.size.height * 0.5, image.size.width * 0.5)
                                          resizingMode:UIImageResizingModeStretch];
            UIImageView *bgImageView = [[UIImageView alloc] initWithImage:image];
            [self insertSubview:bgImageView atIndex:0];
            _bgImgView = bgImageView;
        }
    }
    return self;
}

- (void)commentExpandButtonClick {
    
    if (self.cell.delegate && [self.cell.delegate respondsToSelector:@selector(growCellDidClickCommentExpandButton:)]) {
        [self.cell.delegate growCellDidClickCommentExpandButton:self.cell];
    }
    
}


- (void)layoutSubviews {
    [super layoutSubviews];
    _bgImgView.frame = self.bounds;
}

@end

@interface DWDGrowUpCell () <DWDMenuButtonDelegate>

@property (nonatomic, assign) CGFloat commentLabelLastY;

@property (nonatomic, weak) UIView *lineView;

@end

@implementation DWDGrowUpCell

#pragma mark - Life Cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    _statusView = [DWDUserStatusView new];
    _statusView.cell = self;
    
    _growUpContentView = [DWDGrowUpContentView new];
    _growUpContentView.cell = self;
    
    _menuButton = [self createMentuButton];
    
    _commentView = [DWDGrowUpCommentView new];
    _commentView.cell = self;
    
    [self.contentView addSubview:_statusView];
    [self.contentView addSubview:_growUpContentView];
    [self.contentView addSubview:_menuButton];
    [self.contentView addSubview:_commentView];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = kCellCommentBackgroundColor;
    _lineView = lineView;
    
    [self.contentView addSubview:lineView];
    
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _lineView.frame = CGRectMake(0, CGRectGetMaxY(self.contentView.frame) - 1, DWDScreenW, 1);
}

#pragma mark - Private Method
- (DWDMenuButton *)createMentuButton {
    if (_menuButton)
        return _menuButton;
    
    DWDMenuButton *menuButton = [DWDMenuButton buttonWithType:UIButtonTypeCustom];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"ic_comment_album_details_normal"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    menuButton.delegate = self;
    return menuButton;
}

- (void)menuButtonDidClick:(DWDMenuButton *)menuButton {
    [UIMenuController sharedMenuController].arrowDirection = UIMenuControllerArrowRight;
    [menuButton menuButtonDidClick];
}

#pragma mark - DWDMenuButtonDelegate

- (void)menuButtonDidClickZanButton:(DWDMenuButton *)menuBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(growCellDidClickPraise:)]) {
        [self.delegate growCellDidClickPraise:self];
    }
    [UIMenuController sharedMenuController].arrowDirection = UIMenuControllerArrowDefault;
}

- (void)menuButtonDidclickCommitButton:(DWDMenuButton *)menuBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(growCellDidClickComment:)]) {
        [self.delegate growCellDidClickComment:self];
    }
    [UIMenuController sharedMenuController].arrowDirection = UIMenuControllerArrowDefault;
}

#pragma mark - About Layout
/**
 *  layout statusView growUpContentView menuButton commentView
 *
 */
- (void)setLayout:(DWDGrowUpCellLayout *)layout {
    CGRect frame = self.frame;
    frame.size.height = layout.totalHeight;
    self.frame = frame;
    
    CGRect frame1 = self.contentView.frame;
    frame1.size.height = layout.totalHeight;
    self.contentView.frame = frame1;
    
    /*
     layout statusView
     **/
    _statusView.frame = CGRectMake(0, 0, DWDScreenW, layout.headImageHeight + kCellPadding);
    [_statusView.headImageView sd_setImageWithURL:[NSURL URLWithString:layout.model.author.photoKey] placeholderImage:[UIImage imageNamed:@"ME_User_HP_Boy"]];
    [_statusView.nameLabel setText:layout.model.author.name];
    [_statusView.dateTimeLabel setText:[NSString stringFormatYYYYMMddHHmmssDateToYYYYMMddString:layout.model.author.addTime]];
    [_statusView.dateTimeLabel sizeToFit];
    
    /*
     layout contentView
     **/
    CGFloat contentHeight = 0;
    if (layout.isHaveExpandContentButton) {
        contentHeight = layout.contentTextHeight + pxToW(5) + kCellPadding + layout.contentButtonHeight;
//        _growUpContentView.contentStartImageView.hidden = NO;
    } else if(layout.model.record.content.length != 0) {
        contentHeight = layout.contentTextHeight + pxToW(5);
//        _growUpContentView.contentStartImageView.hidden = NO;
    } else {
        contentHeight = 0;
//        _growUpContentView.contentStartImageView.hidden = YES;
    }
    if (layout.model.photos.count) {
        contentHeight += layout.picsViewHeight + kCellPadding;
    }

    _growUpContentView.frame = CGRectMake(0, CGRectGetMaxY(_statusView.frame) + kCellStartContentImageTopPadding, DWDScreenW, contentHeight);
    
    YYTextSimpleEmoticonParser *parser = [YYTextSimpleEmoticonParser new];
    parser.emoticonMapper = [NSDictionary dwd_emotionMapperDictionary];
    _growUpContentView.contentTextLabel.textParser = parser;
    _growUpContentView.contentTextLabel.textLayout = layout.contentTextLayout;
    
    _growUpContentView.contentTextLabel.frame = CGRectMake(kCellPadding, kCellPadding, layout.contentTextLayout.textBoundingSize.width, layout.contentTextLayout.textBoundingSize.height);
    
    if (layout.haveExpandContentButton) {
        _growUpContentView.contentExpandButton.hidden = NO;
        UIButton *button = _growUpContentView.contentExpandButton;
        if (layout.isExpandingContent) {
            //展开状态
            _growUpContentView.contentTextLabel.numberOfLines = 0;
            [button setTitle:@"收起" forState:UIControlStateNormal];
        } else {
            //收起状态
            _growUpContentView.contentTextLabel.numberOfLines = 3;
            [button setTitle:@"全文" forState:UIControlStateNormal];
        }
        [button sizeToFit];
        button.origin = CGPointMake(DWDScreenW - kCellFlowerWidth - layout.commentButtonWidth, CGRectGetMaxY(_growUpContentView.contentTextLabel.frame) + kCellPadding);
        
        //添加图片view 到 按钮下
        _growUpContentView.picContainerView.frame = CGRectMake(0, CGRectGetMaxY(button.frame) + kCellPadding, DWDScreenW, layout.picsViewHeight);
    } else {
        _growUpContentView.contentExpandButton.hidden = YES;
        //添加图片view 到 内容下
        if (layout.model.record.content.length > 0) {
            _growUpContentView.picContainerView.frame = CGRectMake(0, CGRectGetMaxY(_growUpContentView.contentTextLabel.frame), DWDScreenW, layout.picsViewHeight);
        } else {
            _growUpContentView.picContainerView.frame = CGRectMake(0, kCellPadding - kCellStartContentImageTopPadding, DWDScreenW, layout.picsViewHeight);
        }
    }
    
    //布局图片容器view
    if (layout.model.photos.count) {
        _growUpContentView.picContainerView.hidden = NO;
        [self layoutPicsViewWithPicsArray:layout.model.photos];
    } else {
        _growUpContentView.picContainerView.hidden = YES;
    }
    
    /*
     layout menuButton
     **/
    _menuButton.frame = CGRectMake(DWDScreenW - kCellMenuButtonTopPadding - kCellStartContentImageWidth, CGRectGetMaxY(_growUpContentView.frame) + kCellMenuButtonTopPadding, kCellStartContentImageWidth, kCellStartContentImageWidth);
    
    /*
     layout commentView
     **/
    CGFloat commentViewHeight = 0;
    /*
     逻辑判断
     first
     1.有赞
     2.没赞
     end
     
     second
     1.有评论
     2.没评论
     end
     **/
    /*
     有评论有赞的时候才有线
     **/
    if (layout.model.praises.count) {
        //有赞
        commentViewHeight = layout.praisesHeight + _commentView.flowerImageView.y + kCellCommentLabelMargin;
        _commentView.flowerImageView.hidden = NO;
        _commentView.praiseLabel.hidden = NO;
        
        _commentView.praiseLabel.textLayout = layout.praisesTextLayout;
        _commentView.praiseLabel.frame = CGRectMake(kCellPadding * 2 + kCellFlowerWidth, _commentView.flowerImageView.y - pxToW(2), DWDScreenW - kCellPadding * 4 - kCellFlowerWidth, layout.praisesHeight);
        WEAKSELF;
        _commentView.praiseLabel.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            YYTextHighlight *highlight = [text attribute:YYTextHighlightAttributeName atIndex:range.location effectiveRange:NULL];
            NSDictionary *userInfo = highlight.userInfo;
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(growCell:didClickUserToViewDetail:)]) {
                [weakSelf.delegate growCell:weakSelf didClickUserToViewDetail:userInfo[@"custId"]];
            }
        };
    } else {
        commentViewHeight = _commentView.flowerImageView.y;
        _commentView.flowerImageView.hidden = YES;
        _commentView.praiseLabel.hidden = YES;
    }
    
    if (layout.model.comments.count) {
        
        _commentView.commentsContainerView.hidden = NO;
        //only add comments height
        commentViewHeight += layout.commentsHeight;
        
        if (layout.isHaveExpandCommentsButton) {
            //extra add button height
            _commentView.commentExpandButton.hidden = NO;
            if (layout.isExpandingComments) {
                //展开状态
                [_commentView.commentExpandButton setTitle:@"收起" forState:UIControlStateNormal];
            } else {
                //收起状态
                [_commentView.commentExpandButton setTitle:@"展开" forState:UIControlStateNormal];
            }
            [_commentView.commentExpandButton sizeToFit];
            commentViewHeight += kCellPadding + layout.commentButtonHeight - kCellCommentLabelMargin;
        } else {
            _commentView.commentExpandButton.hidden = YES;
        }
        //layout commentsContainerView
        if (layout.model.praises.count) {
            _commentView.commentsContainerView.frame = CGRectMake(0, layout.praisesHeight + _commentView.flowerImageView.y, DWDScreenW - kCellPadding * 2, layout.commentsHeight + kCellPadding);
        } else {
            _commentView.commentsContainerView.frame = CGRectMake(0, layout.praisesHeight + kCellMenuButtonTopPadding, DWDScreenW - kCellPadding * 2, layout.commentsHeight + kCellPadding);
            
        }
        
        //layout comments
        NSArray *commentsAr = [NSArray array];
        
        if (layout.model.comments.count > 9) {
            if (!layout.isExpandingComments) {
                commentsAr = [layout.model.comments subarrayWithRange:NSMakeRange(0, 9)];
            } else {
                commentsAr = layout.model.comments;
            }
        } else {
            commentsAr = layout.model.comments;
        }
        
        [self layoutCommentsWithCommentsArray:commentsAr
                          commentsLayoutArray:layout.commentsTextLayoutArray];
        CGRect comexButtonFrame = _commentView.commentExpandButton.frame;
        comexButtonFrame.origin = CGPointMake(DWDScreenW - kCellPadding * 3 - layout.commentButtonWidth, _commentView.commentsContainerView.frame.origin.y + layout.commentsHeight + kCellCommentLabelMargin);
        _commentView.commentExpandButton.frame = comexButtonFrame;
    } else {
        for (UIView *subView in _commentView.commentsContainerView.subviews) {
            
            if ([subView isKindOfClass:[YYLabel class]]) {
                [subView removeFromSuperview];
            }
            
        }
        if (!layout.model.praises.count) {
            _commentView.commentsContainerView.hidden = YES;
        }
    }
//    commentViewHeight += kCellCommentLabelMargin;
    if (!layout.model.praises.count && !layout.model.comments.count) {
        _commentView.hidden = YES;
    } else {
        _commentView.hidden = NO;
        _commentView.frame = CGRectMake(kCellPadding, CGRectGetMaxY(_menuButton.frame) + kCellMenuButtonTopPadding, DWDScreenW - kCellPadding * 2, commentViewHeight);
        [_commentView.bgImgView setNeedsLayout];
    }
    
    if (layout.model.praises.count && layout.model.comments.count) {
        _commentView.lineView.hidden = NO;
        _commentView.lineView.y = CGRectGetMaxY(_commentView.praiseLabel.frame);
    } else {
        _commentView.lineView.hidden = YES;
    }
}

- (void)layoutPicsViewWithPicsArray:(NSArray *)picsArray {
    //图片个数
    [_growUpContentView.picContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat height = 0;
    UIImage *phImage = [UIImage growUpRecordPlaceholderImageWithSize:(CGSize){kCellThreePicsWidth, kCellThreePicsWidth}];
    if (picsArray.count == 1) {
        height = kCellSinglePicWidth;
        DWDGrowUpModelPhoto *photo = picsArray[0];
        DWDGrowUpTouchImageView *picView = [DWDGrowUpTouchImageView new];
//        UIImage *phImage = [UIImage imageNamed:@"placeholder"];
//        phImage = [phImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
        [picView sd_setImageWithURL:[NSURL URLWithString:[photo.photo thumbPhotoKey]]
                   placeholderImage:phImage
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                picView.userInteractionEnabled = YES;
            }
        }];
        __weak typeof(UIImageView) *weakPicView = picView;
        WEAKSELF;
        picView.tapBlock = ^(UITapGestureRecognizer *tap) {
            if (_delegate && [_delegate respondsToSelector:@selector(growCell:didClickImageView:withIndex:)]) {
                [_delegate growCell:weakSelf
                  didClickImageView:weakPicView
                          withIndex:0];
            }
        };
        [_growUpContentView.picContainerView addSubview:picView];
        picView.frame = CGRectMake(kCellPadding, kCellPadding, kCellSinglePicWidth, kCellSinglePicWidth);
    }
    else if ((picsArray.count == 2) || (picsArray.count == 4)) {
        if (picsArray.count == 2) {
            height = kCellDoublePicsWidth;
        } else {
            height = kCellDoublePicsWidth * 2 + kCellPadding;
        }
        for (int i =0; i < picsArray.count; i ++) {
            DWDGrowUpModelPhoto *photo = picsArray[i];
            DWDGrowUpTouchImageView *picView = [DWDGrowUpTouchImageView new];
//            UIImage *phImage = [UIImage imageNamed:@"placeholder"];
//            phImage = [phImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
            [picView sd_setImageWithURL:[NSURL URLWithString:[photo.photo thumbPhotoKey]]
                       placeholderImage:phImage
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    picView.userInteractionEnabled = YES;
                }
            }];
            __weak typeof(UIImageView) *weakPicView = picView;
            WEAKSELF;
            picView.tapBlock = ^(UITapGestureRecognizer *tap) {
                if (_delegate && [_delegate respondsToSelector:@selector(growCell:didClickImageView:withIndex:)]) {
                    [_delegate growCell:weakSelf
                      didClickImageView:weakPicView
                              withIndex:i];
                }
            };
            [_growUpContentView.picContainerView addSubview:picView];
            
            CGFloat x = kCellPadding + (kCellDoublePicsWidth + kCellPadding) * (i % 2);
            CGFloat y = kCellPadding + (kCellDoublePicsWidth + kCellPadding) * (i / 2);
            CGFloat width = kCellDoublePicsWidth;
            picView.frame = CGRectMake(x, y, width, width);
        }
    }
    else {
        if (picsArray.count == 3) {
            height = kCellThreePicsWidth;
        } else if(picsArray.count <= 6) {
            height = kCellThreePicsWidth * 2 + kCellCommentLabelMargin;
        } else {
            height = kCellThreePicsWidth * 3 + kCellCommentLabelMargin * 2;
        }
        CGFloat margin = kCellCommentLabelMargin;
        for (int i =0; i < picsArray.count; i ++) {
            DWDGrowUpModelPhoto *photo = picsArray[i];
            DWDGrowUpTouchImageView *picView = [DWDGrowUpTouchImageView new];
//            UIImage *phImage = [UIImage imageNamed:@"placeholder"];
//            phImage = [phImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeTile];
            [picView sd_setImageWithURL:[NSURL URLWithString:[photo.photo thumbPhotoKey]]
                       placeholderImage:phImage
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    picView.userInteractionEnabled = YES;
                }
            }];
            __weak typeof(UIImageView) *weakPicView = picView;
            WEAKSELF;
            picView.tapBlock = ^(UITapGestureRecognizer *tap) {
                if (_delegate && [_delegate respondsToSelector:@selector(growCell:didClickImageView:withIndex:)]) {
                    [_delegate growCell:weakSelf
                      didClickImageView:weakPicView
                              withIndex:i];
                }
            };
            [_growUpContentView.picContainerView addSubview:picView];

            CGFloat x = kCellPadding + (margin + kCellThreePicsWidth) * (i % 3);
            CGFloat y = kCellPadding + (margin + kCellThreePicsWidth) * (i / 3);
            CGFloat width = kCellThreePicsWidth;
            picView.frame = CGRectMake(x, y, width, width);
        }
    }
}

//计算评论尺寸 创建评论label
- (void)layoutCommentsWithCommentsArray:(NSArray *)commentsArray commentsLayoutArray:(NSArray *)layoutArray {
    [_commentView.commentsContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    WEAKSELF;
    for (int i = 0; i < commentsArray.count; i ++) {
        YYTextLayout *layout = layoutArray[i];
        YYLabel *commentLabel = [[YYLabel alloc] init];
        commentLabel.font = [UIFont systemFontOfSize:kCellDateTimeFont];
        commentLabel.displaysAsynchronously = YES;
        YYTextSimpleEmoticonParser *parser = [[YYTextSimpleEmoticonParser alloc] init];
        parser.emoticonMapper = [NSDictionary dwd_emotionMapperDictionary];
        commentLabel.textLayout = layout;
        commentLabel.textParser = parser;
        CGFloat x = kCellPadding;
        CGFloat height = layout.textBoundingSize.height + 2;
        CGFloat y;
        if (i == 0) {
            y = 0;
            _commentLabelLastY = y + height;
        } else {
            y = _commentLabelLastY;
            _commentLabelLastY = y + height;
        }
        commentLabel.frame = CGRectMake(x, y, DWDScreenW - kCellCommentLabelLeftPadding - kCellPadding * 2, height);
        
        commentLabel.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            YYTextHighlight *highlight = [text attribute:YYTextHighlightAttributeName atIndex:range.location effectiveRange:NULL];
            NSDictionary *userInfo = highlight.userInfo;
            if (weakSelf.delegate &&[weakSelf.delegate respondsToSelector:@selector(growCell:didClickUserToViewDetail:)]) {
                [weakSelf.delegate growCell:weakSelf didClickUserToViewDetail:userInfo[@"custId"]];
            }
        };
        
        DWDGrowUpModelComment *comment = commentsArray[i];
        
        __weak YYLabel *weakLabel = commentLabel;
        commentLabel.textTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            
            NSRange range0 = [text.string rangeOfString:@"："];
            if (range.location <= range0.location) {
                return;
            }
            containerView.backgroundColor = kCellCommentSelectedColor;
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(growCell:didClickLabel:replyWithCustId:nickname:)] && ![comment.custId isEqualToNumber:[DWDCustInfo shared].custId]) {
                /**
                 测试用
                 
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(growCell:didClickLabel:replyWithCustId:nickname:)]) {
                 */
                [weakSelf.delegate growCell:weakSelf didClickLabel:weakLabel replyWithCustId:comment.custId nickname:comment.nickname];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                containerView.backgroundColor = [UIColor clearColor];
            });
        };
        
        commentLabel.textLongPressAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            if ([comment.custId isEqualToNumber:[DWDCustInfo shared].custId]) {
#warning longPressToDo - <next build version>
                DWDMarkLog(@"longPress");
            }
        };
        [_commentView.commentsContainerView addSubview:commentLabel];
    }
}


@end
