//
//  DWDInformationCell.m
//  EduChat
//
//  Created by Gatlin on 16/8/10.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInformationCell.h"

#import "NSDate+dwd_dateCategory.h"
#import "NSNumber+Extension.h"

#import "DWDArticleFrameModel.h"
#import "DWDArticleModel.h"

#define infoPadding 15

@interface DWDPhotoCell ()
@property (nonatomic, strong) UIImageView *photoImv; //发布图片
@end


@interface DWDVideoCell ()
@property (nonatomic, strong) UIView *videoView; //视频
@property (nonatomic, strong) UIImageView *videoImv;
@property (nonatomic, strong) UIImageView *playImv;
@property (nonatomic, strong) UILabel *videoTime;
@end


@implementation DWDInformationCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
        
        self.nickname = [[UILabel alloc] init];
        self.nickname.font = DWDScreenW > 320.0f ? [UIFont systemFontOfSize:12] : [UIFont systemFontOfSize:11];
        self.nickname.textColor = DWDColorSecondary;
        [self.contentView addSubview:self.nickname];
        
        self.title = [[UILabel alloc] init];
        self.title.font = DWDScreenW > 320.0f ? [UIFont systemFontOfSize:18] : [UIFont systemFontOfSize:17];
        self.title.numberOfLines = 0;
        self.title.textColor = DWDColorBody;
        [self.contentView addSubview:self.title];
        
        self.readIcon = [[UIImageView alloc] init];
        self.readIcon.image = [UIImage imageNamed:@"ic_read"];
        [self.contentView addSubview:self.readIcon];
        
        self.readcnt = [[UILabel alloc] init];
        self.readcnt.textColor = DWDColorSecondary;
        self.readcnt.font = DWDScreenW > 320.0f ? [UIFont systemFontOfSize:12] : [UIFont systemFontOfSize:11];
        [self.contentView addSubview:self.readcnt];
        
        self.praiseIcon = [[UIImageView alloc] init];
        self.praiseIcon.image = [UIImage imageNamed:@"ic_praise_information"];
        [self.contentView addSubview:self.praiseIcon];
        
        self.praisecnt = [[UILabel alloc] init];
        self.praisecnt.textColor = DWDColorSecondary;
        self.praisecnt.font = DWDScreenW > 320.0f ? [UIFont systemFontOfSize:12] : [UIFont systemFontOfSize:11];
        [self.contentView addSubview:self.praisecnt];
        
        self.time = [[UILabel alloc] init];
        self.time.font = DWDScreenW > 320.0f ? [UIFont systemFontOfSize:12] : [UIFont systemFontOfSize:11];
        self.time.textColor = DWDColorSecondary;
        [self.contentView addSubview:self.time];
        
//        self.unreadCnt = [[UILabel alloc] init];
//        self.unreadCnt.frame = CGRectMake(0, 0, 65, 18);
//        self.unreadCnt.font = DWDFontMin;
//        self.unreadCnt.textColor = DWDColorSecondary;
//        self.unreadCnt.textAlignment = NSTextAlignmentCenter;
//        self.unreadCnt.layer.cornerRadius = 9.0;
//        self.unreadCnt.layer.borderWidth = 0.5;
//        self.unreadCnt.layer.borderColor = DWDColorSecondary.CGColor;
//        [self.contentView addSubview:self.unreadCnt];
    }
    return self;
}

//设置固定控件Frame 发布对象头像、发布对象昵称、发布时间
-(void)setupCommonControlFrame
{
//    self.avatar.frame = CGRectMake(infoPadding, 14, 20, 20);
//    self.nickname.frame = CGRectMake(CGRectGetMaxX(self.avatar.frame) + 6, CGRectGetMidY(self.avatar.frame) - 6, DWDScreenW - 150, 12);
//    self.time.frame = CGRectMake(DWDScreenW - 100, self.nickname.origin.y, 85, 12);
}

//赋值公共控件值
- (void)assigninCommonControlWithModel:(DWDArticleFrameModel *)fmodel
{
    self.nickname.text = fmodel.articleModel.auth.nickname;
    
    self.title.text = fmodel.articleModel.title;
    self.time.text = [NSString stringWithTimelineDate:[NSDate dateWithString:fmodel.articleModel.time format:@"YYYYMMddHHmmss"]]; //YYYY-MM-dd HH:mm:ss]
    self.time.text = [NSString stringWithFormat:@"· %@",self.time.text];

    self.title.textColor = ([fmodel.articleModel.visitStat.readSta intValue] == 1) ? DWDColorSecondary : DWDColorBody;
    
    if (fmodel.articleModel.unreadCnt) {
        self.unreadCnt.text = [NSString stringWithFormat:@"未读%@",fmodel.articleModel.unreadCnt];
    }else {
        self.unreadCnt.text = nil;
    }
    
    self.readcnt.text = [fmodel.articleModel.visitStat.readCnt calculateReadCount];
    self.praisecnt.text = [fmodel.articleModel.visitStat.praiseCnt stringValue];
}

@end



@implementation DWDArticleCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}

- (instancetype)initArticleCellWithTableView:(UITableView *)tableView
{
    static NSString *articleCellId = @"articleCellId";
    DWDArticleCell *articleCell = [tableView dequeueReusableCellWithIdentifier:articleCellId];
    if (!articleCell) {
        articleCell = [[DWDArticleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:articleCellId];
    }
    return articleCell;
}


//控件布局
-(void)setupControlFrame
{
    self.title.frame = self.fmodel.titleFrame;
    self.nickname.frame = self.fmodel.nicknameFrame;
    self.time.frame = self.fmodel.timeFrame;
    self.readIcon.frame = self.fmodel.readIconFrame;
    self.readcnt.frame = self.fmodel.readcntFrame;
//    CGSize titleLaberSize = [self.title.text boundingRectWithfont:self.title.font sizeMakeWidth:DWDScreenW - infoPadding*2];
//    self.title.frame = CGRectMake(infoPadding, CGRectGetMaxY(self.nickname.frame) + 16, titleLaberSize.width, titleLaberSize.height);
//    
//    self.readIcon.frame = CGRectMake(infoPadding, CGRectGetMaxY(self.title.frame) + 16, 22, 22);
//    self.readcnt.frame = CGRectMake(CGRectGetMaxX(self.readIcon.frame) + 6, CGRectGetMidY(self.readIcon.frame) - 6, 80, 12);
//    
//    self.praiseIcon.frame = CGRectMake(CGRectGetMaxX(self.readIcon.frame) + 50, self.readIcon.origin.y, 22, 22);
//    self.praisecnt.frame = CGRectMake(CGRectGetMaxX(self.praiseIcon.frame) + 6, CGRectGetMidY(self.praiseIcon.frame) - 6, 80, 12);
//    
//    if (self.unreadCnt.text.length > 0) {
//        CGSize size = [self.unreadCnt.text boundingRectWithfont:self.unreadCnt.font];
//        self.unreadCnt.w = size.width + 20;
//        self.unreadCnt.cenY = self.readIcon.cenY;
//        self.unreadCnt.x = DWDScreenW - self.unreadCnt.w - DWDPaddingMax;
//    }else {
//        self.unreadCnt.frame = CGRectZero;
//    }
}

//赋值
- (void)assigninWithModel:(DWDArticleFrameModel *)model
{
    [super assigninCommonControlWithModel:model];
}

- (void)setFmodel:(DWDArticleFrameModel *)fmodel{
    [super setFmodel:fmodel];
     [self assigninWithModel:fmodel];
     [self setupControlFrame];
}

@end



@implementation DWDPhotoCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.photoImv = [[UIImageView alloc] init];
        self.photoImv.contentMode = UIViewContentModeScaleAspectFill;
        self.photoImv.layer.masksToBounds = YES;
        [self.contentView addSubview:self.photoImv];
        
        //图片类型 、标题不超过3行
        self.title.numberOfLines = 3;
    }
    return self;
}

- (instancetype)initPhotoCellWithTableView:(UITableView *)tableView
{
    static NSString *photoCellId = @"photoCellId";
    DWDPhotoCell *photoCell = [tableView dequeueReusableCellWithIdentifier:photoCellId];
    if (!photoCell) {
        photoCell = [[DWDPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:photoCellId];
    }
    return photoCell;
}

//控件布局
-(void)setupControlFrame
{
    self.photoImv.frame = self.fmodel.photo1Frame;
    self.title.frame = self.fmodel.titleFrame;
    self.nickname.frame = self.fmodel.nicknameFrame;
    self.time.frame = self.fmodel.timeFrame;
    self.readIcon.frame = self.fmodel.readIconFrame;
    self.readcnt.frame = self.fmodel.readcntFrame;

//    self.photoImv.frame = CGRectMake(DWDScreenW - 100 - infoPadding, 44, 100, 80);
//    
//    CGFloat titleLabelHeight = [self.title.text boundingRectWithfont:self.title.font].height;
//    CGSize titleLabelSize = [self.title.text boundingRectWithfont:self.title.font sizeMakeWidth:DWDScreenW - infoPadding*3 - self.photoImv.w];
//    
//    self.title.frame = CGRectMake(infoPadding, CGRectGetMaxY(self.nickname.frame) + infoPadding, titleLabelSize.width, titleLabelSize.height > titleLabelHeight *3 ? titleLabelHeight *3 : titleLabelSize.height);
//    
//    if (self.unreadCnt.text.length > 0) {
//       self.readIcon.frame = CGRectMake(infoPadding, CGRectGetMaxY(self.title.frame) + infoPadding, 22, 22);
//    }else{
//        if (self.title.h >= titleLabelHeight *3) {
//            self.readIcon.frame = CGRectMake(infoPadding, CGRectGetMaxY(self.title.frame) + infoPadding, 22, 22);
//        }else{
//            self.readIcon.frame = CGRectMake(infoPadding, CGRectGetMaxY(self.photoImv.frame) - infoPadding, 22, 22);
//        }
//    }
//   
//    self.readcnt.frame = CGRectMake(CGRectGetMaxX(self.readIcon.frame) + 6, CGRectGetMidY(self.readIcon.frame) - 6, 100, 12);
//    
//    self.praiseIcon.frame = CGRectMake(CGRectGetMaxX(self.readIcon.frame) + 50, self.readIcon.origin.y, 22, 22);
//    self.praisecnt.frame = CGRectMake(CGRectGetMaxX(self.praiseIcon.frame) + 6, CGRectGetMidY(self.praiseIcon.frame) - 6, 100, 12);
//    
//    if (self.unreadCnt.text.length > 0) {
//        CGSize size = [self.unreadCnt.text boundingRectWithfont:self.unreadCnt.font];
//        self.unreadCnt.w = size.width + 20;
//        self.unreadCnt.y =  CGRectGetMaxY(self.photoImv.frame) + infoPadding;
//        self.unreadCnt.x = DWDScreenW - self.unreadCnt.w - DWDPaddingMax;
//    }else {
//        self.unreadCnt.frame = CGRectZero;
//    }
    
}


//赋值
- (void)assigninWithModel:(DWDArticleFrameModel *)model
{
    [super assigninCommonControlWithModel:model];
    [self.photoImv sd_setImageWithURL:[NSURL URLWithString:model.articleModel.photoUrl] placeholderImage:DWDDefault_infoPhotoImage];
}

- (void)setFmodel:(DWDArticleFrameModel *)fmodel{
    [super setFmodel:fmodel];
    [self assigninWithModel:fmodel];
    [self setupControlFrame];
}
//- (void)setArticleModel:(DWDArticleModel *)articleModel
//{
//    [super setArticleModel:articleModel];
//    
//    [self assigninWithModel:articleModel];
//    [self setupControlFrame];
//    
//    if (self.unreadCnt.text.length > 0) {
//        articleModel.height = CGRectGetMaxY(self.unreadCnt.frame) + infoPadding;
//    }else{
//        articleModel.height = CGRectGetMaxY(self.readIcon.frame) + infoPadding;
//    }
//    
//}

@end




@implementation DWDVideoCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *videoImv = [[UIImageView alloc] init];
        _videoImv = videoImv;
        [self.contentView addSubview:videoImv];
        
        _playImv = [[UIImageView alloc] init];
        _playImv.image = [UIImage imageNamed:@"ic_play_video"];
        [self.contentView addSubview:_playImv];
        
        UILabel *videoTime = [[UILabel alloc] init];
        _videoTime = videoTime;
        videoTime.textColor = [UIColor whiteColor];
        videoTime.textAlignment = NSTextAlignmentCenter;
        videoTime.font = DWDFontMin;
        [self.contentView addSubview:videoTime];
        
        //self.title.numberOfLines = 1;
    }
    return self;
}

- (instancetype)initVideoCellWithTableView:(UITableView *)tableView
{
    static NSString *videoCellId = @"videoCellId";
    DWDVideoCell *videoCell = [tableView dequeueReusableCellWithIdentifier:videoCellId];
    if (!videoCell) {
        videoCell = [[DWDVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoCellId];
    }
    return videoCell;
}


//控件布局
-(void)setupControlFrame
{
    self.videoImv.frame = self.fmodel.photo1Frame;
    self.playImv.frame = self.fmodel.videoIconFrame;
    self.videoTime.frame = self.fmodel.videoTimeFrame;
    
    self.title.frame = self.fmodel.titleFrame;
    self.nickname.frame = self.fmodel.nicknameFrame;
    self.time.frame = self.fmodel.timeFrame;
    self.readIcon.frame = self.fmodel.readIconFrame;
    self.readcnt.frame = self.fmodel.readcntFrame;
//    self.title.frame = CGRectMake(infoPadding, CGRectGetMaxY(self.nickname.frame) + infoPadding, DWDScreenW - infoPadding*2, 25);
//    self.videoView.frame = CGRectMake(infoPadding, CGRectGetMaxY(self.title.frame) + infoPadding, DWDScreenW - infoPadding*2, 200);
//    
//    self.readIcon.frame = CGRectMake(infoPadding, CGRectGetMaxY(self.videoView.frame) + 16, 22, 22);
//    self.readcnt.frame = CGRectMake(CGRectGetMaxX(self.readIcon.frame) + 6, CGRectGetMidY(self.readIcon.frame) - 6, 100, 12);
//    
//    self.praiseIcon.frame = CGRectMake(CGRectGetMaxX(self.readIcon.frame) + 50, self.readIcon.origin.y, 22, 22);
//    self.praisecnt.frame = CGRectMake(CGRectGetMaxX(self.praiseIcon.frame) + 6, CGRectGetMidY(self.praiseIcon.frame) - 6, 100, 12);
//    
//    if (self.unreadCnt.text.length > 0) {
//        CGSize size = [self.unreadCnt.text boundingRectWithfont:self.unreadCnt.font];
//        self.unreadCnt.w = size.width + 20;
//        self.unreadCnt.cenY = self.readIcon.cenY;
//        self.unreadCnt.x = DWDScreenW - self.unreadCnt.w - DWDPaddingMax;
//    }else {
//        self.unreadCnt.frame = CGRectZero;
//    }
}

//赋值
- (void)assigninWithModel:(DWDArticleFrameModel *)model
{
    [super assigninCommonControlWithModel:model];
    
    self.videoTime.text = [model.articleModel.video.duration calculateduartion];
    [self.videoImv sd_setImageWithURL:[NSURL URLWithString:model.articleModel.photoUrl] placeholderImage:DWDDefault_infoVideoImage];
}

- (void)setFmodel:(DWDArticleFrameModel *)fmodel{
    [super setFmodel:fmodel];
    [self assigninWithModel:fmodel];
    [self setupControlFrame];
}
//赋值
//- (void)assigninWithModel:(DWDArticleModel *)articleModel
//{
//    [super assigninCommonControlWithModel:articleModel];
//    
//    self.videoTime.text = [articleModel.video.duration calculateduartion];
//    [self.videoImv sd_setImageWithURL:[NSURL URLWithString:articleModel.photoUrl] placeholderImage:DWDDefault_infoVideoImage];
//}
//
//- (void)setArticleModel:(DWDArticleModel *)articleModel
//{
//    [super setArticleModel:articleModel];
//    
//    [self assigninWithModel:articleModel];
//    [self setupControlFrame];
//    
//    articleModel.height = CGRectGetMaxY(self.readIcon.frame) + infoPadding;
//}
@end




