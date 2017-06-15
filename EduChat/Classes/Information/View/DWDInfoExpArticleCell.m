//
//  DWDInfoExpArticleCell.m
//  EduChat
//
//  Created by Catskiy on 16/8/24.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInfoExpArticleCell.h"
#import "DWDArticleModel.h"
#import "NSDate+dwd_dateCategory.h"

@interface DWDInfoExpArticleCell ()

@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UILabel *detailLbl;
@property (nonatomic, strong) UILabel *readCntLbl;
@property (nonatomic, strong) UILabel *praiseCntLbl;
@property (nonatomic, strong) UILabel *timeLbl;
@property (nonatomic, strong) UIImageView *readImgV;
@property (nonatomic, strong) UIImageView *praiseImgV;

@property (nonatomic, strong) UIView *thumbView;
@property (nonatomic, strong) UIImageView *thumbImgV;
@property (nonatomic, strong) UIImageView *voiceImgV;
@property (nonatomic, strong) UIImageView *iconImgV;

@property (nonatomic, assign) CGFloat readCntW;

@end

@implementation DWDInfoExpArticleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setSubviews];
    }
    return self;
}

- (void)setSubviews
{
    [self.contentView addSubview:self.titleLbl];
    [self.contentView addSubview:self.detailLbl];
    [self.contentView addSubview:self.readCntLbl];
    [self.contentView addSubview:self.praiseCntLbl];
    [self.contentView addSubview:self.timeLbl];
    [self.contentView addSubview:self.readImgV];
    [self.contentView addSubview:self.praiseImgV];
    [self.contentView addSubview:self.thumbView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat iconW = 15;
    CGFloat iconH = 11;
    _readImgV.frame = CGRectMake(14, self.h - iconH - 15, iconW, iconH);
    _readCntLbl.frame = CGRectMake(CGRectGetMaxX(_readImgV.frame) + 6, _readImgV.y, self.readCntW + 5, iconH);
    _praiseImgV.frame = CGRectMake(_readCntLbl.x + _readCntLbl.w + 15, _readImgV.y, 12.5, iconH);
    _praiseCntLbl.frame = CGRectMake(CGRectGetMaxX(_praiseImgV.frame) + 6, _praiseImgV.y, _readCntLbl.w, iconH);
    _timeLbl.frame = CGRectMake(DWDScreenW - DWDPaddingMax - 100, _readImgV.y, 100, _readImgV.h);

    
    if ([_article.contentType intValue] == 1) { // 文字
        
        _thumbView.hidden = YES;
        _titleLbl.numberOfLines = 1;
        _detailLbl.numberOfLines = 2;
        
         CGFloat titleH = [_titleLbl.text boundingRectWithfont:_titleLbl.font].height;
        _titleLbl.frame = CGRectMake(DWDPaddingMax, 18, DWDScreenW - 2 * DWDPaddingMax, titleH);
        
        
        CGFloat detaiLblH = [_detailLbl.text boundingRectWithfont:_detailLbl.font sizeMakeWidth:self.titleLbl.w].height;
        _detailLbl.frame = CGRectMake(_titleLbl.x, CGRectGetMaxY(_titleLbl.frame) + 12, _titleLbl.w, detaiLblH);
//        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:_detailLbl.text attributes:@{NSFontAttributeName:_detailLbl.font}];
//        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
//        [paraStyle setLineSpacing:6];
//        [attStr addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, _detailLbl.text.length)];
//        _detailLbl.attributedText = attStr;
        
    }else {
        
        _thumbView.hidden = NO;
        _titleLbl.numberOfLines = 2;
        
        CGFloat thumbViewW = 112 *DWDScreenW/375.0;
        CGFloat thumbViewH = 71 *DWDScreenW/375.0;
        _thumbView.frame = CGRectMake(DWDScreenW - thumbViewW - DWDPaddingMax, 13, thumbViewW, thumbViewH);
        
        CGFloat titleW = DWDScreenW - thumbViewW -  3 * DWDPaddingMax;
        CGFloat titleH = [_titleLbl.text boundingRectWithfont:_titleLbl.font sizeMakeWidth:titleW].height;
        _titleLbl.frame = CGRectMake(DWDPaddingMax, 18, titleW, titleH > 45.4 ? 45.4 : titleH);
        
        CGFloat detailH = 0;
        if (titleH < 23) {
            _detailLbl.numberOfLines = 2;
            detailH = 35;
        }else {
            _detailLbl.numberOfLines = 1;
            detailH = 14;
        }
        
        _detailLbl.frame = CGRectMake(_titleLbl.x, CGRectGetMaxY(_titleLbl.frame) + 12, _titleLbl.w, detailH);
        
        if ([_article.contentType intValue] == 3) { // 视频
            
            _voiceImgV.hidden = YES;
            _thumbImgV.hidden = NO;
            _iconImgV.image = [UIImage imageNamed:@"ic_play_small_video"];
            
        }else if ([_article.contentType intValue] == 4) {   // 音频
            
            _voiceImgV.hidden = NO;
            _thumbImgV.hidden = YES;
            _iconImgV.image = [UIImage imageNamed:@"ic_pauce_record"];
            
        }else {
            
            _thumbImgV.hidden = NO;
        }
    }
}

- (void)setArticle:(DWDArticleModel *)article
{
    _article = article;
    
    _titleLbl.textColor = ([article.visitStat.readSta intValue] == 1) ? DWDColorSecondary : DWDColorBody;
    _titleLbl.text = _article.title;
    _detailLbl.text = _article.summary;
    _readCntLbl.text = [_article.visitStat.readCnt stringValue];
    _readCntW = [_readCntLbl.text boundingRectWithfont:DWDFontMin].width;
    _praiseCntLbl.text = [_article.visitStat.praiseCnt stringValue];
    _timeLbl.text = [NSString stringWithTimelineDate:[NSDate dateWithString:article.time format:@"YYYYMMddHHmmss"]];
    [_thumbImgV sd_setImageWithURL:[NSURL URLWithString:_article.photoUrl] placeholderImage:nil];
}

- (UILabel *)titleLbl
{
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.textColor = DWDColorBody;
        _titleLbl.font = [UIFont systemFontOfSize:17];
    }
    return _titleLbl;
}

- (UILabel *)detailLbl
{
    if (!_detailLbl) {
        _detailLbl = [[UILabel alloc] init];
        _detailLbl.textColor = DWDColorSecondary;
        _detailLbl.font = DWDFontContent;
    }
    return _detailLbl;
}

- (UILabel *)readCntLbl
{
    if (!_readCntLbl) {
        _readCntLbl = [[UILabel alloc] init];
        _readCntLbl.textColor = DWDColorSecondary;
        _readCntLbl.font = DWDFontMin;
    }
    return _readCntLbl;
}

- (UILabel *)praiseCntLbl
{
    if (!_praiseCntLbl) {
        _praiseCntLbl = [[UILabel alloc] init];
        _praiseCntLbl.textColor = DWDColorSecondary;
        _praiseCntLbl.font = DWDFontMin;
    }
    return _praiseCntLbl;
}

- (UILabel *)timeLbl
{
    if (!_timeLbl) {
        _timeLbl = [[UILabel alloc] init];
        _timeLbl.textAlignment = NSTextAlignmentRight;
        _timeLbl.textColor = DWDColorSecondary;
        _timeLbl.font = DWDFontMin;
    }
    return _timeLbl;
}

- (UIImageView *)readImgV
{
    if (!_readImgV) {
        _readImgV = [[UIImageView alloc] init];
        _readImgV.contentMode = UIViewContentModeScaleAspectFit;
        _readImgV.image = [UIImage imageNamed:@"ic_read"];
    }
    return _readImgV;
}

- (UIImageView *)praiseImgV
{
    if (!_praiseImgV) {
        _praiseImgV = [[UIImageView alloc] init];
        _praiseImgV.contentMode = UIViewContentModeScaleAspectFit;
        _praiseImgV.image = [UIImage imageNamed:@"ic_praise_information"];
    }
    return _praiseImgV;
}

- (UIView *)thumbView
{
    if (!_thumbView) {
        _thumbView = [[UIView alloc] init];
        _thumbView.backgroundColor = UIColorFromRGB(0xf4f4f4);
        
        CGFloat thumbViewW = 112 *DWDScreenW/375.0;
        CGFloat thumbViewH = 71 *DWDScreenW/375.0;
        
        // 音频图标
        _voiceImgV = [[UIImageView alloc] init];
        _voiceImgV.frame = CGRectMake(thumbViewW - 14 - 8, thumbViewH - 16 - 5, 14, 16);
        _voiceImgV.contentMode = UIViewContentModeScaleAspectFit;
        _voiceImgV.image = [UIImage imageNamed:@"ic_audio"];
        [_thumbView addSubview:_voiceImgV];
        
        // 图片
        _thumbImgV = [[UIImageView alloc] init];
        _thumbImgV.frame = CGRectMake(0, 0, thumbViewW, thumbViewH);
        _thumbImgV.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImgV.layer.masksToBounds = YES;
        [_thumbView addSubview:_thumbImgV];
        
        // 播放图标
        _iconImgV = [[UIImageView alloc] init];
        _iconImgV.frame = CGRectMake((thumbViewW - 36) * 0.5, (thumbViewH - 36) * 0.5, 36, 36);
        _iconImgV.contentMode = UIViewContentModeScaleAspectFit;
        [_thumbView addSubview:_iconImgV];
    }
    return _thumbView;
}


@end
