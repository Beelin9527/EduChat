//
//  DWDIntNoticeDetailCell.m
//  EduChat
//
//  Created by Beelin on 17/1/5.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import "DWDIntNoticeDetailCell.h"

#import "DWDIntNoticeDetailModel.h"

#import "UIButton+WebCache.h"
@interface DWDIntNoticeDetailCell ()
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *originLab;
@property (nonatomic, strong) UILabel *contentLab;
@property (nonatomic, strong) UIView *imagesBoxView;
@property (nonatomic, strong) UIView *ontButtonBoxView;
@property (nonatomic, strong) UIView *twoButtonBoxView;
@property (nonatomic, strong) UIButton *OKBtn;
@property (nonatomic, strong) UIButton *YESBtn;
@property (nonatomic, strong) UIButton *NOBtn;
@property (nonatomic, strong) NSMutableArray <DWDPhotoMetaModel*>*photos;
@end


@implementation DWDIntNoticeDetailCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *cellId = @"DWDIntNoticeDetailCell";
    DWDIntNoticeDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell =  [[DWDIntNoticeDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupControls];
        [self layoutControls];
    }
    return self;
}

#pragma mark - Setup UI
- (void)setupControls{
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.originLab];
    [self.contentView addSubview:self.contentLab];
    
}
-(void)layoutControls{
    self.titleLab.frame = CGRectMake(15, 22, DWDScreenW - 30, 19);
    self.originLab.frame = CGRectMake(15, self.titleLab.maxY + 12, DWDScreenW - 20, 13);
}

#pragma mark - Setter
- (void)setModel:(DWDIntNoticeDetailModel *)model{
    _model = model;
    if (!_model) return;
    
    self.titleLab.text = _model.title;
    self.originLab.text = [NSString stringWithFormat:@"%@  %@  %@",_model.orgNm, _model.cNm,_model.createTime];
    
    self.contentLab.text = _model.content;
    CGSize contentSize = [self.contentLab.text boundingRectWithfont:self.contentLab.font sizeMakeWidth:DWDScreenW - 20];
    self.contentLab.frame = CGRectMake(15, self.originLab.maxY + 27, contentSize.width, contentSize.height);
    
    [self layoutImagesWithImages:_model.photos];
    
    //remove
    if ([self.contentView.subviews containsObject:self.ontButtonBoxView]) {
        [self.ontButtonBoxView removeFromSuperview];
    }
    if ([self.contentView.subviews containsObject:self.twoButtonBoxView]) {
        [self.twoButtonBoxView removeFromSuperview];
    }
    
    CGFloat cellHeight = 0;
    if ([_model.type isEqualToNumber:@1]) {
        self.ontButtonBoxView.frame = CGRectMake(0, self.contentLab.maxY + 12 + self.imagesBoxView.h + 15, DWDScreenW, 40);
        [self.contentView addSubview:self.ontButtonBoxView];
        cellHeight = self.ontButtonBoxView.maxY + 15;
        
        if ([_model.item isEqualToNumber:@0]) {
            self.OKBtn.enabled = YES;
        }else{
            self.OKBtn.enabled = NO;
        }
    }else{
        self.twoButtonBoxView.frame = CGRectMake(0, self.contentLab.maxY + 12 + self.imagesBoxView.h + 15, DWDScreenW, 40);
        [self.contentView addSubview:self.twoButtonBoxView];
        cellHeight = self.twoButtonBoxView.maxY + 15;
        
        if ([_model.item isEqualToNumber:@0]) {
            self.OKBtn.enabled = YES;
        }else{
            self.OKBtn.enabled = NO;
        }
    }
    
    
    //calculate cell height
    _model.cellContentHeight = cellHeight;
}
#pragma mark - Getter
- (UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = DWDColorBody;
        _titleLab.font = [UIFont systemFontOfSize:19];
        _titleLab.numberOfLines = 1;
    }
    return _titleLab;
}

- (UILabel *)originLab{
    if (!_originLab) {
        _originLab = [[UILabel alloc] init];
        _originLab.textColor = DWDColorSecondary;
        _originLab.font = [UIFont systemFontOfSize:13];
        _originLab.numberOfLines = 1;
    }
    return _originLab;
}

- (UILabel *)contentLab{
    if (!_contentLab) {
        _contentLab = [[UILabel alloc] init];
        _contentLab.textColor = DWDColorBody;
        _contentLab.font = [UIFont systemFontOfSize:16];
        _contentLab.numberOfLines = 0;
    }
    return _contentLab;
}

- (UIView *)imagesBoxView{
    if (!_imagesBoxView) {
        _imagesBoxView = [[UIView alloc] init];
        _imagesBoxView.backgroundColor = [UIColor whiteColor];
    }
    return _imagesBoxView;
}

- (UIButton *)OKBtn{
    if (!_OKBtn) {
        _OKBtn = [self createButton];
        [_OKBtn setTitle:@"好的，收到" forState:UIControlStateNormal];
        [_OKBtn addTarget:self action:@selector(OKAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _OKBtn;
}

- (UIButton *)YESBtn{
    if (!_YESBtn) {
        _YESBtn = [self createButton];
        _YESBtn.tag = 0;
        [_YESBtn setTitle:@"YES" forState:UIControlStateNormal];
        [_YESBtn addTarget:self action:@selector(YesOrNoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _YESBtn;
}

- (UIButton *)NOBtn{
    if (!_NOBtn) {
        _NOBtn = [self createButton];
        _NOBtn.tag = 1;
        [_NOBtn setTitle:@"NO" forState:UIControlStateNormal];
        [_NOBtn addTarget:self action:@selector(YesOrNoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _NOBtn;
}
- (UIView *)ontButtonBoxView{
    if (!_ontButtonBoxView) {
        _ontButtonBoxView = [[UIView alloc] init];
        _ontButtonBoxView.size = CGSizeMake(DWDScreenW, 40);
        _ontButtonBoxView.backgroundColor = [UIColor whiteColor];
        [_ontButtonBoxView addSubview:({
            self.OKBtn.frame = CGRectMake(_ontButtonBoxView.w / 2.0 - 75, 0, 150, 40);
            self.OKBtn;
        })];
    }
    return _ontButtonBoxView;
}

- (UIView *)twoButtonBoxView{
    if (!_twoButtonBoxView) {
        _twoButtonBoxView = [[UIView alloc] init];
        _twoButtonBoxView.size = CGSizeMake(DWDScreenW, 40);
        _twoButtonBoxView.backgroundColor = [UIColor whiteColor];
        
        CGFloat btnW = (_ontButtonBoxView.w - 75) / 2.0;
        CGFloat btnH = 40;
        [_twoButtonBoxView addSubview:({
            self.YESBtn.frame = CGRectMake((55 / 2.0) + (btnW + 20) * 0, 0, btnW, btnH);
            self.YESBtn;
        })];
        [_twoButtonBoxView addSubview:({
            self.NOBtn.frame = CGRectMake((55 / 2.0) + (btnW + 20) * 1, 0, btnW, btnH);
            self.NOBtn;
        })];
    }
    return _twoButtonBoxView;
}

- (NSMutableArray<DWDPhotoMetaModel *> *)photos{
    if (!_photos) {
        _photos = [NSMutableArray array];
    }
    return _photos;
}


#pragma mark - Privare Method
- (void)layoutImagesWithImages:(NSArray *)images{
    if (images.count == 0) return;
    if (self.photos.count > 0) {
        [self.photos removeAllObjects];
    }
    
    CGFloat imvW = (DWDScreenW - 45) / 3.0;
    CGFloat imvH = imvW;
    CGFloat padding = 7.5;
    CGFloat imvX = 0;
    CGFloat imvY = 0;
    for (int i = 0; i < images.count; i ++) {
        DWDIntPhotoInfoModel *pModel = images[i];
        [self.photos addObject:pModel.photo];
         [self.photos addObject:pModel.photo];
        imvX = (i % 3) * (imvW + padding);
        imvY = (i / 3) * (imvH + padding) ;
        
        UIButton *imvBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        imvBtn.tag = i;
        imvBtn.backgroundColor = [UIColor orangeColor];
        [imvBtn sd_setImageWithURL:[NSURL URLWithString:pModel.photo.thumbPhotoKey] forState:UIControlStateNormal placeholderImage:DWDDefault_infoPhotoImage];
        [imvBtn addTarget:self action:@selector(lookPhoto:) forControlEvents:UIControlEventTouchDown];
        imvBtn.frame = CGRectMake(imvX, imvY, imvW, imvH);
        
        [self.imagesBoxView addSubview:imvBtn];
    }
    
    NSInteger row = images.count % 3 == 0 ? images.count / 3 : images.count / 3 + 1;
    CGFloat height = (imvH + padding) * row;
    self.imagesBoxView.frame = CGRectMake(15, self.contentLab.maxY + 12, DWDScreenW - 45, height);
    [self.contentView addSubview:self.imagesBoxView];
}

- (UIButton *)createButton{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:DWDColorSecondary] forState:UIControlStateDisabled];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 20;
    return btn;
}

#pragma mark - Event Response
- (void)lookPhoto:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(intNoticeDetailCell:clickButton:photos:)]) {
        [self.delegate intNoticeDetailCell:self clickButton:sender photos:self.photos];
    }
}

- (void)OKAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(intNoticeDetailCell:didClickOKButtonWithItem:)]) {
        [self.delegate intNoticeDetailCell:self didClickOKButtonWithItem:@1];
    }
}

- (void)YesOrNoAction:(UIButton *)sender{
    NSInteger tag = sender.tag == 0 ? 2 : 3;
    if (self.delegate && [self.delegate respondsToSelector:@selector(intNoticeDetailCell:didClickYesOrNoButtonWithItem:)]) {
        [self.delegate intNoticeDetailCell:self didClickYesOrNoButtonWithItem:@(tag)];
    }}
- (void)action:(UIButton *)sender{
    switch (sender.tag) {
        case 0:
            
            break;
            
        default:
            break;
    }
}
@end
