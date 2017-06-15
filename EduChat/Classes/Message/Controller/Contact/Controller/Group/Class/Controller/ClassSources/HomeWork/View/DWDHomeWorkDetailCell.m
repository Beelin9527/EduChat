//
//  DWDHomeWorkDetailCell.m
//  EduChat
//
//  Created by apple on 12/30/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDHomeWorkDetailCell.h"

#import <SDWebImage/UIImageView+WebCache.h>
#define DWDHomeWorkDetailCellPadding 10
#define DWDHomeWorkDetailCellPaddingMax 15
#define DWDAttachmentImgEdgeLength 80
@interface DWDHomeWorkDetailCell () {
    CGRect titleFrame, subjectFrame, dateFrame, separatorFrame, contentTitleFrame,
    contentFrame, attachmentContainerFrame, deadlineTitleFrame, deadlineFrame, fromTitleFrame, fromFrame;
}

@property (strong, nonatomic) UIView *attachmentContainer;
@property (strong, nonatomic) NSArray *attachmentImgViews;
@property (nonatomic) NSUInteger attachmentImgColums;
@property (nonatomic) NSUInteger attachmentImgPadding;
@property (strong, nonatomic) UIImageView *backImgView;

@property (strong, nonatomic) UIView *separatorView;

@property (strong, nonatomic) NSMutableArray *attachmentImgs;

@property (nonatomic) BOOL isLayouting;
@end

@implementation DWDHomeWorkDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (DWDScreenW > 320) {
            self.attachmentImgColums = 4;
        } else {
            self.attachmentImgColums = 3;
        }
        self.attachmentImgPadding = (DWDScreenW - 4 * DWDHomeWorkDetailCellPadding -
                                    self.attachmentImgColums * DWDAttachmentImgEdgeLength) /
                                    (self.attachmentImgColums - 1);
        self.backgroundColor = DWDColorBackgroud;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildSubviews];
    }
    return self;
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsMake(0, DWDScreenW, 0, 0);
}

- (void)setAttachmentPaths:(NSArray *)attachmentPaths {
    _attachmentPaths = attachmentPaths;
    for (int i = 0; i < attachmentPaths.count; i++) {
        UIImageView *imgView = self.attachmentImgViews[i];
        [imgView sd_setImageWithURL:[NSURL URLWithString:attachmentPaths[i]]];
    }
    
}

- (void)layoutSubviews {
    self.isLayouting = YES;
    [super layoutSubviews];
    [self buildFrames];
    [self setFrames];
    self.isLayouting = NO;
}

- (CGFloat)getHeight {
    
    CGFloat result;
    
    result = 6 * DWDHomeWorkDetailCellPadding + 5 * DWDHomeWorkDetailCellPaddingMax + titleFrame.size.height + dateFrame.size.height + separatorFrame.size.height + contentTitleFrame.size.height + contentFrame.size.height + attachmentContainerFrame.size.height + deadlineFrame.size.height + fromFrame.size.height;
    
    if (attachmentContainerFrame.size.height == 0) {
        result -= DWDHomeWorkDetailCellPadding;
    }
    return result;
}

- (void)buildFrames {
    
    CGSize titleSize = [self.titleLabel.text
                        boundingRectWithSize:CGSizeMake((DWDScreenW - 4 * DWDHomeWorkDetailCellPadding) * 2 / 3, 9999)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{NSFontAttributeName:self.titleLabel.font}
                        context:nil].size;
    titleFrame = CGRectMake(2 * DWDHomeWorkDetailCellPadding, 3 * DWDHomeWorkDetailCellPadding, titleSize.width, titleSize.height);
    
    CGSize subjectSize = [self.subjectLabel.text
                          boundingRectWithSize:CGSizeMake((DWDScreenW - 4 * DWDHomeWorkDetailCellPadding) / 3, 9999)
                          options:NSStringDrawingUsesLineFragmentOrigin
                          attributes:@{NSFontAttributeName:self.subjectLabel.font}
                          context:nil].size;
    subjectFrame = CGRectMake(titleFrame.origin.x + titleFrame.size.width + DWDHomeWorkDetailCellPadding, titleFrame.origin.y, subjectSize.width, subjectSize.height);
    
    CGSize dateSize = [self.dateLabel.text
                       boundingRectWithSize:CGSizeMake(DWDScreenW - 4 * DWDHomeWorkDetailCellPadding, 9999)
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:self.dateLabel.font}
                       context:nil].size;
    dateFrame = CGRectMake(titleFrame.origin.x, titleFrame.origin.y + titleFrame.size.height + DWDHomeWorkDetailCellPaddingMax, dateSize.width, dateSize.height);
    
    separatorFrame = CGRectMake(DWDScreenW / 5, dateFrame.origin.y + dateFrame.size.height + DWDHomeWorkDetailCellPaddingMax, DWDScreenW * 3 / 5, .5);
    
    CGSize contentTitleSize = [self.contentTitleLabel.text
                               boundingRectWithSize:CGSizeMake(DWDScreenW - 4 * DWDHomeWorkDetailCellPadding, 9999)
                               options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{NSFontAttributeName:self.contentTitleLabel.font}
                               context:nil].size;
    contentTitleFrame = CGRectMake(dateFrame.origin.x, separatorFrame.origin.y + separatorFrame.size.height + DWDHomeWorkDetailCellPadding, contentTitleSize.width, contentTitleSize.height);
    
    CGSize contentSize = [TTTAttributedLabel
                          sizeThatFitsAttributedString:self.contentLabel.attributedText
                          withConstraints:CGSizeMake(DWDScreenW - 4 * DWDHomeWorkDetailCellPadding, 99999)
                          limitedToNumberOfLines:0];
    contentFrame = CGRectMake(contentTitleFrame.origin.x, contentTitleFrame.origin.y + contentTitleFrame.size.height + DWDHomeWorkDetailCellPaddingMax, contentSize.width, contentSize.height);
    
    NSUInteger count = self.attachmentPaths.count;
    if (count > 0) {
        
        NSUInteger rows = count / self.attachmentImgColums;
        if (count % self.attachmentImgColums > 0) rows++;
        
        
        CGFloat attachmentContainerHeight = rows * DWDAttachmentImgEdgeLength + (rows - 1) * self.attachmentImgPadding;
        attachmentContainerFrame = CGRectMake(contentFrame.origin.x, contentFrame.origin.y + contentFrame.size.height + DWDHomeWorkDetailCellPadding, DWDScreenW - 4 * DWDHomeWorkDetailCellPadding, attachmentContainerHeight);
        
        for (int i = 0; i < count; i++) {
            UIImageView *imgView = self.attachmentImgViews[i];
            imgView.frame = CGRectMake(i % self.attachmentImgColums * (self.attachmentImgPadding + DWDAttachmentImgEdgeLength),
                                       i / self.attachmentImgColums * (self.attachmentImgPadding + DWDAttachmentImgEdgeLength),
                                       DWDAttachmentImgEdgeLength,
                                       DWDAttachmentImgEdgeLength);
        }
    }
    
    else {
        attachmentContainerFrame = CGRectMake(contentFrame.origin.x, contentFrame.origin.y + contentFrame.size.height, 0, 0);
    }
    
    
    
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
    self.titleLabel.frame = titleFrame;
    self.subjectLabel.frame = subjectFrame;
    self.dateLabel.frame = dateFrame;
    self.separatorView.frame = separatorFrame;
    self.contentTitleLabel.frame = contentTitleFrame;
    self.contentLabel.frame = contentFrame;
    self.attachmentContainer.frame = attachmentContainerFrame;
    self.deadlineTitleLabel.frame = deadlineTitleFrame;
    self.deadlineLabel.frame = deadlineFrame;
    self.deadlineTitleLabel.center = CGPointMake(self.deadlineTitleLabel.center.x, self.deadlineLabel.center.y);
    self.fromTitleLabel.frame = fromTitleFrame;
    self.fromLabel.frame = fromFrame;
    self.fromTitleLabel.center = CGPointMake(self.fromTitleLabel.center.x, self.fromLabel.center.y);
    
    self.backImgView.frame = CGRectMake(DWDHomeWorkDetailCellPadding, 0, DWDScreenW - 2 * DWDHomeWorkDetailCellPadding, [self getHeight]);
}

- (void)buildSubviews {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _backImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_notice_notification_details"]];
    _separatorView = [[UIView alloc] init];
    self.separatorView.backgroundColor = DWDColorSeparator;
    
    _titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = DWDFontBody;
    self.titleLabel.textColor = DWDColorBody;
    
    _subjectLabel = [[UILabel alloc] init];
    self.subjectLabel.font =DWDFontBody;
    self.subjectLabel.textColor = DWDColorBody;
    
    _dateLabel = [[UILabel alloc] init];
    self.dateLabel.font = DWDFontContent;
    self.dateLabel.textColor = DWDColorContent;
    
    _contentTitleLabel = [[UILabel alloc] init];
    self.contentTitleLabel.font = DWDFontContent;
    self.contentTitleLabel.textColor = DWDColorContent;
    
    _contentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    self.contentLabel.font = DWDFontBody;
    self.contentLabel.textColor = DWDColorBody;
    self.contentLabel.numberOfLines = 0;
    
    NSMutableArray *imgViews = [NSMutableArray arrayWithCapacity:9];
    _attachmentContainer = [[UIView alloc] init];
    for (int i = 0; i < 9; i++) {
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.backgroundColor = DWDColorBackgroud;
        [imgViews addObject:imgView];
        [self.attachmentContainer addSubview:imgView];
    }
    _attachmentImgViews = [NSArray arrayWithArray:imgViews];
    
    _deadlineTitleLabel = [[UILabel alloc] init];
    self.deadlineTitleLabel.font = DWDFontContent;
    self.deadlineTitleLabel.textColor = DWDColorContent;
    
    _deadlineLabel = [[UILabel alloc] init];
    self.deadlineLabel.font = DWDFontBody;
    self.deadlineLabel.textColor = DWDColorBody;
    
    _fromTitleLabel = [[UILabel alloc] init];
    self.fromTitleLabel.font = DWDFontContent;
    self.fromTitleLabel.textColor = DWDColorContent;
    
    _fromLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    self.fromLabel.font = DWDFontBody;
    self.fromLabel.textColor = DWDColorBody;
    
    [self.contentView addSubview:self.backImgView];
    [self.contentView addSubview:self.separatorView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subjectLabel];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.contentTitleLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.attachmentContainer];
    [self.contentView addSubview:self.deadlineTitleLabel];
    [self.contentView addSubview:self.deadlineLabel];
    [self.contentView addSubview:self.fromTitleLabel];
    [self.contentView addSubview:self.fromLabel];
}

@end
