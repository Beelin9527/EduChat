//
//  DWDHomeWorkDetailsCell.m
//  EduChat
//
//  Created by apple on 16/4/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDHomeWorkDetailsCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry.h>

#import "DWDGrowUpPicsView.h"
#import "DWDGrowUpTouchImageView.h"
#import "DWDPhotoInfoModel.h"
#import "DWDPhotoMetaModel.h"
#import "DWDGrowUpCellLayout.h"

#define DWDHomeWorkDetailCellPadding 10
#define DWDHomeWorkDetailCellPaddingMax 15
#define DWDAttachmentImgEdgeLength 80

@interface DWDHomeWorkDetailsCell ()
{
    CGRect titleFrame, subjectFrame, dateFrame, separatorFrame, contentTitleFrame, picsViewFrame, picsContainViewFrame,
    contentFrame, attachmentContainerFrame, deadlineTitleFrame, deadlineFrame, fromTitleFrame, fromFrame, iconImgVFrame, finishBtnFrame;
}

@property (strong, nonatomic) UIView *attachmentContainer;
@property (strong, nonatomic) NSArray *attachmentImgViews;
@property (nonatomic) NSUInteger attachmentImgColums;
@property (nonatomic) NSUInteger attachmentImgPadding;
@property (strong, nonatomic) UIImageView *backImgView;

@property (strong, nonatomic) UIView *separatorView;
@property (strong, nonatomic) DWDGrowUpPicsView *picsView;
@property (strong, nonatomic) UIView *picsContainView;

@property (strong, nonatomic) NSMutableArray *attachmentImgs;
@property (strong, nonatomic) NSMutableArray *picsArr;

@property (nonatomic) BOOL isLayouting;
@end

@implementation DWDHomeWorkDetailsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildSubviews];
    }
    return self;
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsMake(0, DWDScreenW, 0, 0);
}

- (NSMutableArray *)picsArr
{
    if (!_picsArr) {
        _picsArr = [NSMutableArray array];
    }
    return _picsArr;
}

- (void)setPicsArray:(NSArray *)picsArray
{
    _picsArray = picsArray;
    [_picsContainView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat height = 0;
    UIImage *phImage = [UIImage growUpRecordPlaceholderImageWithSize:(CGSize){kCellThreePicsWidth, kCellThreePicsWidth}];
    if (picsArray.count == 1) {
        height = kCellSinglePicWidth;
        DWDPhotoMetaModel *photo = picsArray[0];
        DWDGrowUpTouchImageView *picView = [DWDGrowUpTouchImageView new];
//        UIImage *phImage = [UIImage imageNamed:@"placeholder"];
//        phImage = [phImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
        [picView sd_setImageWithURL:[NSURL URLWithString:[photo thumbPhotoKey]] placeholderImage:phImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                picView.userInteractionEnabled = YES;
            }
        }];
        __weak typeof(UIImageView) *weakPicView = picView;
        WEAKSELF;
        picView.tapBlock = ^(UITapGestureRecognizer *tap) {
            if (_delegate && [_delegate respondsToSelector:@selector(growCell:didClickImageView:withIndex:)]) {
                [_delegate growCell:weakSelf didClickImageView:weakPicView withIndex:0];
            }
        };
        [_picsContainView addSubview:picView];
        picView.frame = CGRectMake(kCellPadding, DWDHomeWorkDetailCellPaddingMax, kCellSinglePicWidth, kCellSinglePicWidth);
    }
    else if ((picsArray.count == 2) || (picsArray.count == 4)) {
        if (picsArray.count == 2) {
            height = kCellDoublePicsWidth;
        } else {
            height = kCellDoublePicsWidth * 2 + kCellPadding;
        }
        for (int i =0; i < picsArray.count; i ++) {
            DWDPhotoMetaModel *photo = picsArray[i];
            DWDGrowUpTouchImageView *picView = [DWDGrowUpTouchImageView new];
//            UIImage *phImage = [UIImage imageNamed:@"placeholder"];
//            phImage = [phImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
            DWDLog(@"%@",[photo thumbPhotoKey]);
            [picView sd_setImageWithURL:[NSURL URLWithString:[photo thumbPhotoKey]] placeholderImage:phImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    picView.userInteractionEnabled = YES;
                }
            }];
            __weak typeof(UIImageView) *weakPicView = picView;
            WEAKSELF;
            picView.tapBlock = ^(UITapGestureRecognizer *tap) {
                if (_delegate && [_delegate respondsToSelector:@selector(growCell:didClickImageView:withIndex:)]) {
                    [_delegate growCell:weakSelf didClickImageView:weakPicView withIndex:i];
                }
            };
            [_picsContainView addSubview:picView];
            
            CGFloat x = kCellPadding + (kCellDoublePicsWidth + kCellPadding) * (i % 2);
            CGFloat y = DWDHomeWorkDetailCellPaddingMax + (kCellDoublePicsWidth + kCellPadding) * (i / 2);
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
            if (i > 8) {
                break;
            }
            DWDPhotoMetaModel *photo = picsArray[i];
            DWDGrowUpTouchImageView *picView = [DWDGrowUpTouchImageView new];
//            UIImage *phImage = [UIImage imageNamed:@"placeholder"];
//            phImage = [phImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeTile];
            [picView sd_setImageWithURL:[NSURL URLWithString:[photo thumbPhotoKey]] placeholderImage:phImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    picView.userInteractionEnabled = YES;
                }
            }];
            __weak typeof(UIImageView) *weakPicView = picView;
            WEAKSELF;
            picView.tapBlock = ^(UITapGestureRecognizer *tap) {
                if (_delegate && [_delegate respondsToSelector:@selector(growCell:didClickImageView:withIndex:)]) {
                    [_delegate growCell:weakSelf didClickImageView:weakPicView withIndex:i];
                }
            };
            [_picsContainView addSubview:picView];
            
            CGFloat x = kCellPadding + (margin + kCellThreePicsWidth) * (i % 3);
            CGFloat y = DWDHomeWorkDetailCellPaddingMax + (margin + kCellThreePicsWidth) * (i / 3);
            CGFloat width = kCellThreePicsWidth;
            picView.frame = CGRectMake(x, y, width, width);
        }
    }
    _picsContainView.h = height + DWDHomeWorkDetailCellPaddingMax * 2;
}

- (CGFloat)getHeight {
    
    CGFloat result;
    
    result = 15.0f + iconImgVFrame.size.height + DWDHomeWorkDetailCellPadding * 2 + contentFrame.size.height + finishBtnFrame.size.height;
    
    if (_picsArray.count > 0) {
//        result += 15.0f;
        result += _picsContainView.h;
    }else {
        result += 15;
    }
    
    if (finishBtnFrame.size.height > 0) {
        result += 15;
    }
    
    return result;
}

- (void)buildFrames {
    
    iconImgVFrame = CGRectMake(DWDHomeWorkDetailCellPadding, DWDHomeWorkDetailCellPadding, 40.0, 40.0);
    
    CGSize titleSize = [self.titleLabel.text

                        boundingRectWithSize:CGSizeMake(DWDScreenW - 3 * DWDHomeWorkDetailCellPadding - 40.0, 20)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{NSFontAttributeName:self.titleLabel.font}
                        context:nil].size;
    titleFrame = CGRectMake(iconImgVFrame.origin.x + iconImgVFrame.size.width + DWDHomeWorkDetailCellPadding, 2 + DWDHomeWorkDetailCellPadding, titleSize.width, titleSize.height);
    
    CGSize subjectSize = [self.subjectLabel.text
                          boundingRectWithSize:CGSizeMake((DWDScreenW - 4 * DWDHomeWorkDetailCellPadding) / 3, 9999)
                          options:NSStringDrawingUsesLineFragmentOrigin
                          attributes:@{NSFontAttributeName:self.subjectLabel.font}
                          context:nil].size;
    subjectFrame = CGRectMake(titleFrame.origin.x + titleFrame.size.width + DWDHomeWorkDetailCellPadding, titleFrame.origin.y, subjectSize.width, subjectSize.height);
    
    separatorFrame = CGRectMake(DWDHomeWorkDetailCellPadding, 60.0, DWDScreenW - 2 * DWDHomeWorkDetailCellPadding, .5);
    
    CGSize dateSize = [self.dateLabel.text
                       boundingRectWithSize:CGSizeMake(DWDScreenW - 4 * DWDHomeWorkDetailCellPadding, 9999)
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:self.dateLabel.font}
                       context:nil].size;
    dateFrame = CGRectMake(titleFrame.origin.x, separatorFrame.origin.y - 24.0, dateSize.width, dateSize.height);

    
    CGSize contentTitleSize = [self.contentTitleLabel.text
                               boundingRectWithSize:CGSizeMake(DWDScreenW - 4 * DWDHomeWorkDetailCellPadding, 9999)
                               options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{NSFontAttributeName:self.contentTitleLabel.font}
                               context:nil].size;
    contentTitleFrame = CGRectMake(dateFrame.origin.x, separatorFrame.origin.y + separatorFrame.size.height + DWDHomeWorkDetailCellPadding, contentTitleSize.width, contentTitleSize.height);
    
    CGSize contentSize = [TTTAttributedLabel
                          sizeThatFitsAttributedString:self.contentLabel.attributedText
                          withConstraints:CGSizeMake(DWDScreenW - 2 * DWDHomeWorkDetailCellPadding, 99999)
                          limitedToNumberOfLines:0];
    contentFrame = CGRectMake(iconImgVFrame.origin.x, separatorFrame.origin.y + DWDHomeWorkDetailCellPaddingMax, contentSize.width, contentSize.height);
    
    _picsContainView.frame = CGRectMake(0, contentFrame.origin.y + contentFrame.size.height, DWDScreenW, 0);
    
    CGSize deadlineTitleSize = [self.deadlineTitleLabel.text
                                boundingRectWithSize:CGSizeMake(DWDScreenW / 4, 9999)
                                options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName:self.deadlineTitleLabel.font}
                                context:nil].size;
    
    CGSize deadlineSize = [self.deadlineLabel.text
                           boundingRectWithSize:CGSizeMake(DWDScreenW / 2, 9999)
                           options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName:self.deadlineLabel.font}
                           context:nil].size;
    
    deadlineFrame = CGRectMake(DWDScreenW - 2 * DWDHomeWorkDetailCellPadding - deadlineSize.width, attachmentContainerFrame.origin.y + attachmentContainerFrame.size.height + DWDHomeWorkDetailCellPaddingMax, deadlineSize.width, deadlineSize.height);
    deadlineTitleFrame = CGRectMake(deadlineFrame.origin.x - deadlineTitleSize.width, deadlineFrame.origin.y, deadlineTitleSize.width, deadlineTitleSize.height);
    
    CGSize fromTitleSize = [self.fromTitleLabel.text
                            boundingRectWithSize:CGSizeMake(DWDScreenW / 5, 9999)
                            options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:@{NSFontAttributeName:self.fromTitleLabel.font}
                            context:nil].size;
    CGSize fromSize = [TTTAttributedLabel
                       sizeThatFitsAttributedString:self.fromLabel.attributedText
                       withConstraints:CGSizeMake(DWDScreenW / 2, 9999)
                       limitedToNumberOfLines:1];
    
    fromFrame = CGRectMake(DWDScreenW - 2 * DWDHomeWorkDetailCellPadding - fromSize.width, deadlineFrame.origin.y + deadlineFrame.size.height + DWDHomeWorkDetailCellPadding, fromSize.width, fromSize.height);
    fromTitleFrame = CGRectMake(fromFrame.origin.x - fromTitleSize.width, fromFrame.origin.y, fromTitleSize.width, fromTitleSize.height);
    

}

- (void)setFrames {
    
    self.iconImgV.frame            = iconImgVFrame;
    self.titleLabel.frame          = titleFrame;
    self.subjectLabel.frame        = subjectFrame;
    self.dateLabel.frame           = dateFrame;
    self.separatorView.frame       = separatorFrame;
    self.contentTitleLabel.frame   = contentTitleFrame;
    self.contentLabel.frame        = contentFrame;
    self.attachmentContainer.frame = attachmentContainerFrame;
    self.deadlineTitleLabel.frame  = deadlineTitleFrame;
    self.deadlineLabel.frame       = deadlineFrame;
    self.deadlineTitleLabel.center = CGPointMake(self.deadlineTitleLabel.center.x, self.deadlineLabel.center.y);
    self.fromTitleLabel.frame      = fromTitleFrame;
    self.fromLabel.frame           = fromFrame;
    self.fromTitleLabel.center     = CGPointMake(self.fromTitleLabel.center.x, self.fromLabel.center.y);
    self.backImgView.frame         = CGRectMake(DWDHomeWorkDetailCellPadding, 0, DWDScreenW - 2 * DWDHomeWorkDetailCellPadding, [self getHeight]);
}

- (void)buildSubviews {
    
    self.selectionStyle                = UITableViewCellSelectionStyleNone;
    //图标
    _iconImgV                          = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"msg_homework_details"]];
    _iconImgV.contentMode              = UIViewContentModeScaleAspectFit;

    _picsContainView                   = [[UIView alloc] init];

    _backImgView                       = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_notice_notification_details"]];
    _separatorView                     = [[UIView alloc] init];
    self.separatorView.backgroundColor = DWDColorSeparator;

    _titleLabel                        = [[UILabel alloc] init];
    self.titleLabel.font               = DWDFontBody;
    self.titleLabel.textColor          = DWDColorBody;
    self.titleLabel.numberOfLines      = 1;

    _subjectLabel                      = [[UILabel alloc] init];
    self.subjectLabel.font             = DWDFontBody;
    self.subjectLabel.textColor        = DWDColorBody;

    _dateLabel                         = [[UILabel alloc] init];
    self.dateLabel.font                = DWDFontMin;
    self.dateLabel.textColor           = DWDColorSecondary;

    _contentTitleLabel                 = [[UILabel alloc] init];
    self.contentTitleLabel.font        = DWDFontContent;
    self.contentTitleLabel.textColor   = DWDColorContent;

    _contentLabel                      = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    self.contentLabel.font             = DWDFontBody;
    self.contentLabel.textColor        = DWDColorBody;
    self.contentLabel.numberOfLines    = 0;

    NSMutableArray *imgViews           = [NSMutableArray arrayWithCapacity:9];
    _attachmentContainer               = [[UIView alloc] init];
    for (int i = 0; i < 9; i++) {
        UIImageView *imgView    = [[UIImageView alloc] init];
        imgView.backgroundColor = DWDColorBackgroud;
        [imgViews addObject:imgView];
        [self.attachmentContainer addSubview:imgView];
    }
    _attachmentImgViews                = [NSArray arrayWithArray:imgViews];

    _deadlineTitleLabel                = [[UILabel alloc] init];
    self.deadlineTitleLabel.font       = DWDFontContent;
    self.deadlineTitleLabel.textColor  = DWDColorContent;

    _deadlineLabel                     = [[UILabel alloc] init];
    self.deadlineLabel.font            = DWDFontBody;
    self.deadlineLabel.textColor       = DWDColorBody;

    _fromTitleLabel                    = [[UILabel alloc] init];
    self.fromTitleLabel.font           = DWDFontContent;
    self.fromTitleLabel.textColor      = DWDColorContent;

    _fromLabel                         = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    self.fromLabel.font                = DWDFontBody;
    self.fromLabel.textColor           = DWDColorBody;

    _finishBtn                         = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.finishBtn setTitle:@"已完成" forState:UIControlStateNormal];
    [self.finishBtn setBackgroundColor:DWDColorMain];
    self.finishBtn.titleLabel.font     = DWDFontBody;
    self.finishBtn.layer.masksToBounds = YES;


    [self.contentView addSubview:self.iconImgV];
    [self.contentView addSubview:self.separatorView];
    [self.contentView addSubview:self.titleLabel];
//    [self.contentView addSubview:self.subjectLabel];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.fromLabel];
    [self.contentView addSubview:self.picsContainView];
    [self.contentView addSubview:self.finishBtn];
}

- (void)setHomeWorkModel:(DWDHomeWorkDetailModel *)homeWorkModel
{
    _homeWorkModel         = homeWorkModel;
    self.titleLabel.text   = [NSString getNULLString:homeWorkModel.title];
    self.dateLabel.text    = [NSString stringWithFormat:@"%@  %@",[NSString getNULLString:homeWorkModel.name],[NSString getNULLString:homeWorkModel.addTime]];
    self.contentLabel.text = [NSString getNULLString:homeWorkModel.content];
    int subject            = [homeWorkModel.subject intValue];
    
    switch (subject) {
        case 1:
            self.iconImgV.image    = [UIImage imageNamed:@"msg_homework_details_chinese"];
            self.subjectLabel.text = @"语文";
            
            break;
            
        case 2:
            self.iconImgV.image    = [UIImage imageNamed:@"msg_homework_details_math"];
            self.subjectLabel.text = @"数学";
            
            break;
            
        case 3:
            self.iconImgV.image    = [UIImage imageNamed:@"msg_homework_details_english"];
            self.subjectLabel.text = @"英语";
            
            break;
            
        case 4:
            self.iconImgV.image    = [UIImage imageNamed:@"msg_homework_details_art"];
            self.subjectLabel.text = @"美术";
            
            break;
            
        case 5:
            self.iconImgV.image    = [UIImage imageNamed:@"msg_homework_details_music"];
            self.subjectLabel.text = @"音乐";
            
            break;
            
        case 6:
            self.iconImgV.image    = [UIImage imageNamed:@"msg_homework_details_other"];
            self.subjectLabel.text = @"其他";
            
            break;
            
        default:
            break;
    }

    
    [self buildFrames];
    [self setFrames];
    self.picsArray = homeWorkModel.picsArray;
    
    if (![[DWDCustInfo shared].custIdentity isEqualToNumber:@4]) {
        finishBtnFrame = CGRectMake(75/2, 30.0f + iconImgVFrame.size.height + DWDHomeWorkDetailCellPadding * 2 + contentFrame.size.height, DWDScreenW - 75, 40);
        if (_picsArray.count > 0) {
            finishBtnFrame.origin.y += (_picsContainView.h - 15.0f);
        }
        self.finishBtn.frame = finishBtnFrame;
        self.finishBtn.layer.cornerRadius = self.finishBtn.h/2;
        if (homeWorkModel.isFinished) {
            self.finishBtn.enabled = NO;
            self.finishBtn.backgroundColor = DWDColorSeparator;
        }
    }
    
}

@end

