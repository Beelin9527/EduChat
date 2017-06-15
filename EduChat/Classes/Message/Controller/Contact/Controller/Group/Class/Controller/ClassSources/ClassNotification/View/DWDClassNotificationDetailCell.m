//
//  DWDClassNotificationDetailCell.m
//  EduChat
//
//  Created by KKK on 16/5/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassNotificationDetailCell.h"
#import "DWDClassNotificationDetailLayout.h"
#import "DWDClassNotificationDetailModel.h"
#import "DWDGrowUpTouchImageView.h"
#import "DWDPickUpCenterBackgroundContainerView.h"

#import <YYText.h>

@interface DWDClassNotificationSegmentControl ()

@property (nonatomic, weak) UIButton *completeButton;
@property (nonatomic, weak) UIButton *unCompleteButton;
@end
@implementation DWDClassNotificationSegmentControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    
    UIButton *cButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cButton addTarget:self action:@selector(completeButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cButton];
    _completeButton = cButton;
    
    UIView *verLineView = [[UIView alloc] init];
    verLineView.backgroundColor = UIColorFromRGB(0xdddddd);
    verLineView.frame = CGRectMake(frame.size.width * 0.5f - 0.5, frame.size.height * 0.5f - 11, 1, 22);
    [self addSubview:verLineView];
    UIView *horLineView = [[UIView alloc] init];
    horLineView.backgroundColor = UIColorFromRGB(0xdddddd);
    horLineView.frame = CGRectMake(0, frame.size.height - 1, frame.size.width, 1);
    [self addSubview:horLineView];
    
    UIButton *ucButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [ucButton addTarget:self action:@selector(unCompleteButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:ucButton];
    _unCompleteButton = ucButton;
    [self completeButtonDidClick];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    _completeButton.center = CGPointMake(DWDScreenW * 0.25f, self.center.y);
    _completeButton.frame = CGRectMake(0, 0, self.bounds.size.width * 0.5f, kReplyCellSegmentHeight);
    _unCompleteButton.frame = CGRectMake(self.bounds.size.width * 0.5f, 0, self.bounds.size.width * 0.5f, kReplyCellSegmentHeight);
}

#pragma mark - Public Method
- (void)setButtonTitleWithComplete:(NSString *)completeTitle unComplete:(NSString *)unCompleteTitle {
    NSAttributedString *completeNormal = [[NSAttributedString alloc] initWithString:completeTitle attributes:@{
                                   NSFontAttributeName : kCellSegmentFont,
                        NSForegroundColorAttributeName : kCellUnSelectedTitleColor
                                   }];
    NSAttributedString *completeSelected = [[NSAttributedString alloc] initWithString:completeTitle attributes:@{
                                   NSFontAttributeName : kCellSegmentFont,
                        NSForegroundColorAttributeName : kCellSelectedTitleColor
                                   }];
    NSAttributedString *unCompleteNormal = [[NSAttributedString alloc] initWithString:unCompleteTitle attributes:@{
                                     NSFontAttributeName : kCellSegmentFont,
                          NSForegroundColorAttributeName : kCellUnSelectedTitleColor
                                     }];
    NSAttributedString *unCompleteSelected = [[NSAttributedString alloc] initWithString:unCompleteTitle attributes:@{
                                    NSFontAttributeName : kCellSegmentFont,
                         NSForegroundColorAttributeName : kCellSelectedTitleColor
                                    }];
    [_completeButton setAttributedTitle:completeNormal forState:UIControlStateNormal];
    [_completeButton setAttributedTitle:completeSelected forState:UIControlStateSelected];
    [_unCompleteButton setAttributedTitle:unCompleteNormal forState:UIControlStateNormal];
    [_unCompleteButton setAttributedTitle:unCompleteSelected forState:UIControlStateSelected];
    
    [_completeButton sizeToFit];
    [_unCompleteButton sizeToFit];
    
    [self layoutSubviews];
}

#pragma mark - Private Method
- (void)completeButtonDidClick {
//    if (_completeButton.isSelected) {
//        return;
//    }
    _completeButton.selected = YES;
    _unCompleteButton.selected = NO;
    
    if (_delegate && [_delegate respondsToSelector:@selector(segmentControlDidClickCompleteButton)]) {
        [_delegate segmentControlDidClickCompleteButton];
    }
}

- (void)unCompleteButtonDidClick {
    if (_unCompleteButton.isSelected) {
        return;
    }
    _unCompleteButton.selected = YES;
    _completeButton.selected = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(segmentControlDidClickUnCompleteButton)]) {
        [_delegate segmentControlDidClickUnCompleteButton];
    }
}

@end


//内容cell
/**
 3部分
 1
    -   固定图片
    -   标题
    -   作者
    -   时间
 2
    -   文本
    -   图片
 3 
    -   按钮
 */
@interface DWDClassNotificationDetailCell ()
@property (nonatomic, weak) UIImageView *notiImageView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *authorLabel;
@property (nonatomic, weak) UILabel *dateTimeLabel;

@property (nonatomic, weak) YYLabel *contentLabel;
@property (nonatomic, weak) UIView *picsContainerView;

@property (nonatomic, weak) UIButton *readButton;
@property (nonatomic, weak) UIButton *yesButton;
@property (nonatomic, weak) UIButton *noButton;

@property (nonatomic, strong) NSNumber *type;
@end
@implementation DWDClassNotificationDetailCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    UIImageView *notiImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"msg_notice_details_ic"]];
    notiImageView.frame = CGRectMake(kContentCellPadding, kContentCellPadding, kContentCellImageWH, kContentCellImageWH);
    [self.contentView addSubview:notiImageView];
    _notiImageView = notiImageView;
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = kCellTitleFont;
    titleLabel.textColor = kCellTitleColor;
    [self.contentView addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    UILabel *authorLabel = [UILabel new];
    authorLabel.font = kCellNameFont;
    authorLabel.textColor = kCellNameColor;
    [self.contentView addSubview:authorLabel];
    _authorLabel = authorLabel;
    
    UILabel *dateTimeLabel = [UILabel new];
    dateTimeLabel.font = kCellNameFont;
    dateTimeLabel.textColor = kCellNameColor;
    [self.contentView addSubview:dateTimeLabel];
    _dateTimeLabel = dateTimeLabel;
    
    YYLabel *contentLabel = [YYLabel new];
    [self.contentView addSubview:contentLabel];
    _contentLabel = contentLabel;
    
    UIView *picContentView = [UIView new];
    [self.contentView addSubview:picContentView];
    _picsContainerView = picContentView;
    
    UIButton *knowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [knowButton addTarget:self action:@selector(cellDidClickKnowButton) forControlEvents:UIControlEventTouchUpInside];
    [knowButton setTitle:@"我知道了" forState:UIControlStateNormal];
    [knowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [knowButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x5a88e7)] forState:UIControlStateNormal];
    [knowButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xdddddd)] forState:UIControlStateDisabled];
    knowButton.layer.cornerRadius = kContentCellSingleButtonHeight * 0.5f;
    knowButton.layer.masksToBounds = YES;
    [self.contentView addSubview:knowButton];
    _readButton = knowButton;
    
    UIButton *yesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [yesButton addTarget:self action:@selector(_cellDidClickYESButton) forControlEvents:UIControlEventTouchDown];
    [yesButton setTitle:@"YES" forState:UIControlStateNormal];
    [yesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [yesButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x5a88e7)] forState:UIControlStateNormal];
    [yesButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xdddddd)] forState:UIControlStateDisabled];
    yesButton.layer.cornerRadius = kContentCellSingleButtonHeight * 0.5f;
    yesButton.layer.masksToBounds = YES;
    [self.contentView addSubview:yesButton];
    _yesButton = yesButton;
    
    UIButton *noButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [noButton addTarget:self action:@selector(cellDidClickNOButton) forControlEvents:UIControlEventTouchUpInside];
    [noButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x5a88e7)] forState:UIControlStateNormal];
    [noButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xdddddd)] forState:UIControlStateDisabled];
    [noButton setTitle:@"NO" forState:UIControlStateNormal];
    [noButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    noButton.layer.cornerRadius = kContentCellSingleButtonHeight * 0.5f;
    noButton.layer.masksToBounds = YES;
    [self.contentView addSubview:noButton];
    _noButton = noButton;
    
    return self;
}

#pragma mark - Public Method
- (void)setLayout:(DWDClassNotificationDetailLayout *)layout {
//    @property (nonatomic, weak) UILabel *titleLabel;
//    @property (nonatomic, weak) UILabel *authorLabel;
//    @property (nonatomic, weak) UILabel *dateTimeLabel;
//    
//    @property (nonatomic, weak) YYLabel *contentLabel;
//    @property (nonatomic, weak) UIView *picsContainerView;
//    
//    @property (nonatomic, weak) UIButton *readButton;
//    @property (nonatomic, weak) UIButton *yesButton;
//    @property (nonatomic, weak) UIButton *noButton;
    _titleLabel.text = layout.model.notice.title;
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake(kContentCellPadding * 2 + kContentCellImageWH, kContentCellTitleTopPadding, _titleLabel.bounds.size.width, _titleLabel.bounds.size.height);
    
#ifdef DEBUG
    _authorLabel.text = layout.model.author.name.length ? layout.model.author.name : @"后端还没加上名";
#else
    _authorLabel.text = layout.model.author.name.length ? layout.model.author.name : @"作者";
#endif
    [_authorLabel sizeToFit];
    CGFloat authorWidth = _authorLabel.bounds.size.height;
    _authorLabel.frame = CGRectMake(_titleLabel.frame.origin.x, 60 - kContentCellTitleTopPadding - authorWidth, _authorLabel.bounds.size.width, _authorLabel.bounds.size.height);
//    _authorLabel.frame = CGRectMake(_titleLabel.frame.origin.x, CGRectGetMaxY(_titleLabel.frame) + pxToW(16), _authorLabel.bounds.size.width, _authorLabel.bounds.size.height);
    
    _dateTimeLabel.text =[self formatDateTime:layout.model.author.addTime];
    [_dateTimeLabel sizeToFit];
    _dateTimeLabel.frame = CGRectMake(CGRectGetMaxX(_authorLabel.frame) + kContentCellPadding, _authorLabel.frame.origin.y, _dateTimeLabel.bounds.size.width, _dateTimeLabel.bounds.size.height);
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = UIColorFromRGB(0xdddddd);
    lineView.frame = CGRectMake(kContentCellPadding, kContentCellImageWH + kContentCellPadding * 2, DWDScreenW - kContentCellPadding, 1);
    [self.contentView addSubview:lineView];
    _contentLabel.textLayout = layout.contentLayout;
    _contentLabel.frame = CGRectMake(kContentCellPadding, CGRectGetMaxY(lineView.frame) + kContentCellContentTopPadding, layout.contentLayout.textBoundingSize.width, layout.contentLayout.textBoundingSize.height);
    
    _picsContainerView.frame = CGRectMake(0, CGRectGetMaxY(_contentLabel.frame) + kContentCellContentTopPadding, DWDScreenW - kContentCellPadding * 2, layout.imagesHeight);
    if (layout.model.notice.photos.count) {
        [self layoutPicsViewWithPicsArray:layout.model.notice.photos];
        _picsContainerView.hidden = NO;
    } else {
        [_picsContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _picsContainerView.hidden = YES;
    }
    
    _readButton.frame = CGRectMake((DWDScreenW - kContentCellSingleButtonWidth) * 0.5f, CGRectGetMaxY(layout.model.notice.photos.count ? _picsContainerView.frame : _contentLabel.frame) + kContentCellContentTopPadding, kContentCellSingleButtonWidth, kContentCellSingleButtonHeight);
    _yesButton.frame = CGRectMake(37.5, CGRectGetMaxY(layout.model.notice.photos.count ? _picsContainerView.frame : _contentLabel.frame) + kContentCellContentTopPadding, kContentCellDoubleButtonWidth, kContentCellSingleButtonHeight);
    _noButton.frame = CGRectMake(DWDScreenW - kContentCellDoubleButtonWidth - 37.5, CGRectGetMaxY(layout.model.notice.photos.count ? _picsContainerView.frame : _contentLabel.frame) + kContentCellContentTopPadding, kContentCellDoubleButtonWidth, kContentCellSingleButtonHeight);
    
    //type分别是多少值
    _type = layout.model.notice.type;
    if ([layout.model.notice.type integerValue] == 1) {
        //我知道了 类型
        _readButton.hidden = NO;
        _yesButton.hidden = YES;
        _noButton.hidden = YES;
    } else {
        //是否 类型
        BOOL state = NO;
        for (DWDClassNotificationReplyMember *member in layout.model.replys.joins) {
            if ([member.custId isEqualToNumber:[DWDCustInfo shared].custId]) {
                [_readButton setTitle:@"YES" forState:UIControlStateDisabled];
                state = YES;
                break;
            }
        }
        for (DWDClassNotificationReplyMember *member in layout.model.replys.unjoins) {
            if ([member.custId isEqualToNumber:[DWDCustInfo shared].custId]) {
                [_readButton setTitle:@"NO" forState:UIControlStateDisabled];
                state = YES;
                break;
            }
        }
        if (state) {
            _readButton.hidden = NO;
            _yesButton.hidden = YES;
            _noButton.hidden = YES;
        } else {
        _readButton.hidden = YES;
        _yesButton.hidden = NO;
        _noButton.hidden = NO;
        }
    }
    
    if ([_readed isEqualToNumber:@0]) {
        //未读
        [self allButtonAvailable];
    } else {
        //已读
        [self allButtonDisavailable];
    }
}

#pragma mark - Private Method
- (void)postRequestWithType:(NSInteger)type {
        if (self.delegate && [self.delegate respondsToSelector:@selector(detailCell:didClickButtonWithType:)]) {
            [self.delegate detailCell:self didClickButtonWithType:type];
        }

    
}

- (void)cellDidClickKnowButton {
    [self postRequestWithType:2];
}

- (void)_cellDidClickYESButton {
    [self postRequestWithType:1];
}

- (void)cellDidClickNOButton {
    [self postRequestWithType:0];
}

- (NSString *)formatDateTime:(NSString *)dateStr {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    NSDate *date = [dateFormatter dateFromString:dateStr];
    dateFormatter.dateFormat = @"MM/dd HH:mm";
    return [dateFormatter stringFromDate:date] ? [dateFormatter stringFromDate:date] : dateStr;
    
}

- (void)layoutPicsViewWithPicsArray:(NSArray *)picsArray {
    //图片个数
    [_picsContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat height = 0;
    if (picsArray.count == 1) {
        height = kContentCellSinglePicWidth;
//        DWDGrowUpModelPhoto *photo = picsArray[0];
        DWDClassNotificationPhotos *photo = picsArray[0];
        DWDGrowUpTouchImageView *picView = [DWDGrowUpTouchImageView new];
        UIImage *phImage = [UIImage growUpRecordPlaceholderImageWithSize:(CGSize){kContentCellSinglePicWidth, kContentCellSinglePicWidth}];
        
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
            if (_delegate && [_delegate respondsToSelector:@selector(detailCell:didCLickImgView:atIndex:)]) {
                [_delegate detailCell:weakSelf didCLickImgView:weakPicView atIndex:0];
            }
        };
        [_picsContainerView addSubview:picView];
        picView.frame = CGRectMake(kContentCellPadding, 0, kContentCellSinglePicWidth, kContentCellSinglePicWidth);
    }
    else if ((picsArray.count == 2) || (picsArray.count == 4)) {
        if (picsArray.count == 2) {
            height = kContentCellDoublePicsWidth;
        } else {
            height = kContentCellDoublePicsWidth * 2 + kContentCellPadding;
        }
        for (int i =0; i < picsArray.count; i ++) {
            DWDClassNotificationPhotos *photo = picsArray[i];
            DWDGrowUpTouchImageView *picView = [DWDGrowUpTouchImageView new];
            UIImage *phImage = [UIImage growUpRecordPlaceholderImageWithSize:(CGSize){kContentCellDoublePicsWidth, kContentCellDoublePicsWidth}];
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

                if (_delegate && [_delegate respondsToSelector:@selector(detailCell:didCLickImgView:atIndex:)]) {
                    [_delegate detailCell:weakSelf didCLickImgView:weakPicView atIndex:i];
                }
            };
            [_picsContainerView addSubview:picView];
            
            CGFloat x = kContentCellPadding + (kContentCellDoublePicsWidth + kContentCellPadding) * (i % 2);
            CGFloat y = (kContentCellDoublePicsWidth + kContentCellPadding) * (i / 2);
            CGFloat width = kContentCellDoublePicsWidth;
            picView.frame = CGRectMake(x, y, width, width);
        }
    }
    else {
        if (picsArray.count == 3) {
            height = kContentCellThreePicsWidth;
        } else if(picsArray.count <= 6) {
            height = kContentCellThreePicsWidth * 2 + kContentCellThreePicsMargin;
        } else {
            height = kContentCellThreePicsWidth * 3 + kContentCellThreePicsMargin * 2;
        }
        CGFloat margin = kContentCellThreePicsMargin;
        for (int i =0; i < picsArray.count; i ++) {
            DWDClassNotificationPhotos *photo = picsArray[i];
            DWDGrowUpTouchImageView *picView = [DWDGrowUpTouchImageView new];
            UIImage *phImage = [UIImage growUpRecordPlaceholderImageWithSize:(CGSize){kContentCellThreePicsWidth, kContentCellThreePicsWidth}];
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
                if (_delegate && [_delegate respondsToSelector:@selector(detailCell:didCLickImgView:atIndex:)]) {
                    [_delegate detailCell:weakSelf didCLickImgView:weakPicView atIndex:i];
                }
            };
            [_picsContainerView addSubview:picView];
            
            CGFloat x = kContentCellPadding + (margin + kContentCellThreePicsWidth) * (i % 3);
            CGFloat y = (margin + kContentCellThreePicsWidth) * (i / 3);
            CGFloat width = kContentCellThreePicsWidth;
            picView.frame = CGRectMake(x, y, width, width);
        }
    }
}

- (void)allButtonAvailable {
    _readButton.enabled = YES;
    _yesButton.enabled = YES;
    _noButton.enabled = YES;
}

- (void)allButtonDisavailable {
    _readButton.enabled = NO;
    _yesButton.enabled = NO;
    _noButton.enabled = NO;
}

@end



/**
 2部分
 1
    -   segmentControl
 2
    -   成员
 */
@interface DWDClassNotificationReplyCell () <DWDClassNotificationSegmentControlDelegate>
@property (nonatomic, weak) UIView *completeView;
@property (nonatomic, weak) UIView *unCompleteView;
@property (nonatomic, weak) DWDClassNotificationDetailLayout *layout;
@property (nonatomic, weak) DWDPickUpCenterBackgroundContainerView *bgImgView;
@end
@implementation DWDClassNotificationReplyCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    UIView *completeView = [UIView new];
    [self.contentView addSubview:completeView];
    _completeView = completeView;
    
    UIView *unCompleteView = [UIView new];
    [self.contentView addSubview:unCompleteView];
    _unCompleteView = unCompleteView;
    return self;
}

- (void)setLayout:(DWDClassNotificationDetailLayout *)layout {
    _layout = layout;
    /**
     显示哪个界面根据layout的isCompleteSelected属性
     当按钮点击时改变layout的此属性
     */
//    CGFloat viewWidth = (DWDScreenW - kReplyCellLeftPadding * 2 - kReplyCellOtherPadding * 4) / 5.0f;
    CGFloat viewWidth = 50;
    CGFloat viewHeight = viewWidth + 40 ;//+ kContentCellContentTopPadding;
    
    CGFloat margin = (DWDScreenW - 250) / 6.0f;
    CGFloat startMargin = margin;
    
    [_completeView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_unCompleteView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (layout.isCompleteSelected) {
        _completeView.frame = CGRectMake(0, 0, DWDScreenW, layout.completeHeight);
        _completeView.hidden = NO;
        _unCompleteView.hidden = YES;
        //无数据设置空白页
        if (layout.isCompleteBlank) {
            [self.bgImgView setNeedsDisplay];
            return;
        }
        [self.bgImgView removeFromSuperview];
        //有数据设置数据
        if ([layout.model.notice.type integerValue] == 1) {
            //我知道了 类型

            //布置完成view
            for (int i = 0; i < layout.model.replys.readeds.count; i ++) {
                UIView *view = [self viewForMember:layout.model.replys.readeds[i] tag:i];
                NSInteger row = i / 5;
                NSInteger col = i - row * 5;
                [_completeView addSubview:view];
//                view.frame = CGRectMake(kReplyCellLeftPadding + col * (viewWidth + kReplyCellOtherPadding), kContentCellContentTopPadding + row * (viewHeight + kContentCellContentTopPadding), viewWidth, viewHeight);
                view.frame = CGRectMake(startMargin + col * (viewWidth + margin), kContentCellContentTopPadding + row * viewHeight, viewWidth, viewHeight);
            }
        } else {

            //YES NO类型
            //布置完成view
            for (int i = 0; i < layout.model.replys.joins.count; i ++) {
                UIView *view = [self viewForMember:layout.model.replys.joins[i] tag:i];
                NSInteger row = i / 5;
                NSInteger col = i - row * 5;
                [_completeView addSubview:view];
//                view.frame = CGRectMake(kReplyCellLeftPadding + col * (viewWidth + kReplyCellOtherPadding), kContentCellContentTopPadding + row * (viewHeight + kContentCellContentTopPadding), viewWidth, viewHeight);
                view.frame = CGRectMake(startMargin + col * (viewWidth + margin), kContentCellContentTopPadding + row * viewHeight, viewWidth, viewHeight);
            }
        }
    } else {
        
        _unCompleteView.frame = CGRectMake(0, 0, DWDScreenW, layout.uncompleteHeight);
        _unCompleteView.hidden = NO;
        _completeView.hidden = YES;
        //无数据设置空白页
        if (layout.isUnCompleteBlank) {
            [self.bgImgView setNeedsDisplay];
            return;
        }
        [self.bgImgView removeFromSuperview];
        //有数据设置数据
        if ([layout.model.notice.type integerValue] == 1) {
            //我知道了 类型

            //布置未完成view
            for (int i = 0; i < layout.model.replys.unreads.count; i ++) {
                UIView *view = [self viewForMember:layout.model.replys.unreads[i] tag:i];
                NSInteger row = i / 5;
                NSInteger col = i - row * 5;
                [_unCompleteView addSubview:view];
//                view.frame = CGRectMake(kReplyCellLeftPadding + col * (viewWidth + kReplyCellOtherPadding), kContentCellContentTopPadding + row * (viewHeight + kContentCellContentTopPadding), viewWidth, viewHeight);
                view.frame = CGRectMake(startMargin + col * (viewWidth + margin), kContentCellContentTopPadding + row * viewHeight, viewWidth, viewHeight);
            }
        } else {
            //yes no 类型
            
            //布置未完成view
            for (int i = 0; i < layout.model.replys.unjoins.count; i ++) {
                UIView *view = [self viewForMember:layout.model.replys.unjoins[i] tag:i];
                NSInteger row = i / 5;
                NSInteger col = i - row * 5;
                [_unCompleteView addSubview:view];
//                view.frame = CGRectMake(kReplyCellLeftPadding + col * (viewWidth + kReplyCellOtherPadding), kContentCellContentTopPadding + row * (viewHeight + kContentCellContentTopPadding), viewWidth, viewHeight);
                view.frame = CGRectMake(startMargin + col * (viewWidth + margin), kContentCellContentTopPadding + row * viewHeight, viewWidth, viewHeight);
            }
        }
    }
}

- (UIView *)viewForMember:(DWDClassNotificationReplyMember *)member tag:(NSInteger)tag {
    UIView *memberView = [[UIView alloc] init];
    //布局子控件
//    CGFloat picWidth = (DWDScreenW - kReplyCellLeftPadding * 2 - kReplyCellOtherPadding * 4) / 5.0f;
    CGFloat picWidth = 50;
    CGFloat margin = 5;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, picWidth, picWidth)];
    [imgView sd_setImageWithURL:[NSURL URLWithString:member.photohead.photoKey] placeholderImage:[UIImage imageNamed:@"ME_User_HP_Boy"]];
    UILabel *label = [UILabel new];
    label.font = kCellSegmentFont;
    label.textColor = kCellUnSelectedTitleColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = member.name;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    [label sizeToFit];
//    label.frame = CGRectMake(0, picWidth + kContentCellPadding - 1, picWidth, 13);
    label.frame = CGRectMake(0, picWidth + margin, picWidth, 13);
    [memberView addSubview:imgView];
    [memberView addSubview:label];
    memberView.tag = tag;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMemberView:)];
    [memberView addGestureRecognizer:tap];
    return memberView;
}

- (void)tapMemberView:(UITapGestureRecognizer *)tap {
    NSInteger index = tap.view.tag;
    DWDClassNotificationReplyMember *member;
    if (_layout.isCompleteSelected) {
        //已读状态选中
        if ([_layout.model.notice.type integerValue] == 1) {
            //我知道了类型
             member = _layout.model.replys.readeds[index];
        } else {
            //YES NO 类型
            member = _layout.model.replys.joins[index];
        }
    } else {
        //未读状态选中
        if ([_layout.model.notice.type integerValue] == 1) {
            //我知道了类型
             member = _layout.model.replys.unreads[index];
        } else {
            //YES NO 类型
            member = _layout.model.replys.unjoins[index];
        }
    }
    //拿到member
    if (!member) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(replyCell:didClickMember:)]) {
        [_delegate replyCell:self didClickMember:member.custId];
    }
}

- (DWDPickUpCenterBackgroundContainerView *)bgImgView {
    if (!_bgImgView) {
        DWDPickUpCenterBackgroundContainerView *bgImgView = [DWDPickUpCenterBackgroundContainerView new];
        [bgImgView.backgroundImageView setImage:[UIImage imageNamed:@"MSG_TF_no_Student"]];
        bgImgView.infoLabel.text = @"暂无";
        //        [bgImgView.infoLabel setText:@""];
        //totalHeight pxToH(477)
        //viewHeight pxToH(377)
        bgImgView.frame = CGRectMake(DWDScreenW * 0.5 - pxToW(316) * 0.5, pxToH(50), pxToW(316), pxToH(377));
        [self.contentView addSubview:bgImgView];
        _bgImgView = bgImgView;
    }
    return _bgImgView;
}


@end
