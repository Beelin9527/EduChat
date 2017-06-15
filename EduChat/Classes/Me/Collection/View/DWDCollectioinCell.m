//
//  DWDCollectioinCell.m
//  EduChat
//
//  Created by Gatlin on 16/8/27.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDCollectioinCell.h"

#import "DWDCollectModel.h"


#import "NSDate+dwd_dateCategory.h"
#import "NSNumber+Extension.h"
@implementation DWDCollectioinCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (id)indexOfClass:(Class)class {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DWDCollectioinCell" owner:nil options:nil];
    NSInteger index = 0;
    for (int i = 0; i < array.count; i ++) {
        UITableViewCell *cell = array[i];
        if ([cell isKindOfClass:class]) {
            index = i;
            break;
        }
    }
    return array[index];
}
- (instancetype)initWithTableView:(UITableView *)tableView collectModel:(DWDCollectModel *)collectModel
{
    DWDCollectioinCell *collectioinCell = nil;
    if ([collectModel.contentCode isEqualToNumber:@4]) {
        switch ([collectModel.New.contentType intValue]) {
            case 1:
            {
                DWDColArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDColArticleCell"];
                cell.collectModel = collectModel;
                cell.articleModel = collectModel.New;
                if (!cell) {
                   cell = [self indexOfClass:[DWDColArticleCell class ]];
                    cell.collectModel = collectModel;
                      cell.articleModel = collectModel.New;
                }
                collectioinCell = (DWDCollectioinCell *)cell;
            }
                break;
            case 2:
            {
                DWDColPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDColPhotoCell"];
                 cell.collectModel = collectModel;
                  cell.articleModel = collectModel.New;
                if (!cell) {
                    cell = [self indexOfClass:[DWDColPhotoCell class ]];
                    cell.collectModel = collectModel;
                      cell.articleModel = collectModel.New;
                }
                  collectioinCell = (DWDCollectioinCell *)cell;
                
            }
                break;
            case 3:
            {
                DWDColVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDColVideoCell"];
                cell.collectModel = collectModel;
                  cell.articleModel = collectModel.New;
                if (!cell) {
                    cell = [self indexOfClass:[DWDColVideoCell class ]];
                    cell.collectModel = collectModel;
                      cell.articleModel = collectModel.New;
                }
                collectioinCell =  (DWDCollectioinCell *)cell;
            }
                 break;
            case 4:
            {
                DWDColVoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDColVoiceCell"];
                 cell.collectModel = collectModel;
                  cell.articleModel = collectModel.New;
                if (!cell) {
                    cell = [self indexOfClass:[DWDColVoiceCell class ]];
                    cell.collectModel = collectModel;
                      cell.articleModel = collectModel.New;
                }
                   collectioinCell = (DWDCollectioinCell *)cell;
            }
               
                break;
                
            default:
                break;
                
        }
    }else if ([collectModel.contentCode isEqualToNumber:@7]) {
        DWDColExpertCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDColExpertCell"];
        cell.collectModel = collectModel;
        if (!cell) {
            cell = [self indexOfClass:[DWDColExpertCell class ]];
            cell.collectModel = collectModel;
        }
        collectioinCell = (DWDCollectioinCell *)cell;
    }else if ([collectModel.contentCode isEqualToNumber:@8]) {
        switch ([collectModel.article.contentType intValue]) {
            case 1:
            {
                DWDColArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDColArticleCell"];
                cell.collectModel = collectModel;
                cell.articleModel = collectModel.article;
                if (!cell) {
                    cell = [self indexOfClass:[DWDColArticleCell class ]];
                    cell.collectModel = collectModel;
                    cell.articleModel = collectModel.article;
                }
                collectioinCell = (DWDCollectioinCell *)cell;
            }
                break;
            case 2:
            {
                DWDColPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDColPhotoCell"];
                cell.collectModel = collectModel;
                cell.articleModel = collectModel.article;
                if (!cell) {
                    cell = [self indexOfClass:[DWDColPhotoCell class ]];
                    cell.collectModel = collectModel;
                    cell.articleModel = collectModel.article;
                }
                collectioinCell = (DWDCollectioinCell *)cell;
                
            }
                break;
            case 3:
            {
                DWDColVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDColVideoCell"];
                cell.collectModel = collectModel;
                cell.articleModel = collectModel.article;
                if (!cell) {
                    cell = [self indexOfClass:[DWDColVideoCell class ]];
                    cell.collectModel = collectModel;
                    cell.articleModel = collectModel.article;
                }
                collectioinCell =  (DWDCollectioinCell *)cell;
            }
                break;
            case 4:
            {
                DWDColVoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDColVoiceCell"];
                cell.collectModel = collectModel;
                cell.articleModel = collectModel.article;
                if (!cell) {
                    cell = [self indexOfClass:[DWDColVoiceCell class ]];
                    cell.collectModel = collectModel;
                    cell.articleModel = collectModel.article;
                }
                collectioinCell = (DWDCollectioinCell *)cell;
            }
                
                break;
                
            default:
                break;
                
        }
    }
    return collectioinCell;
}
@end


@interface DWDColArticleCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *title;
@end
@implementation DWDColArticleCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    _avatar.layer.masksToBounds = YES;
    _avatar.layer.cornerRadius = _avatar.h/2;
}
- (void)setCollectModel:(DWDCollectModel *)collectModel
{
    _collectModel = collectModel;
    
    collectModel.height = 85.0f;
}

- (void)setArticleModel:(DWDArticleModel *)articleModel
{
    _articleModel = articleModel;
    
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:articleModel.auth.photoKey] placeholderImage:DWDDefault_MeBoyImage];
    self.nickname.text = articleModel.auth.nickname;
    
    self.title.text = articleModel.title;
    self.time.text = [NSString stringWithTimelineDate:[NSDate dateWithString:self.collectModel.collectime format:@"YYYYMMddHHmmss"]]; //YYYY-MM-dd HH:mm:ss]
    
    
}
@end

@interface DWDColPhotoCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *photoImv;
@end
@implementation DWDColPhotoCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    _avatar.layer.masksToBounds = YES;
    _avatar.layer.cornerRadius = _avatar.h/2;
}
- (void)setCollectModel:(DWDCollectModel *)collectModel
{
    _collectModel = collectModel;
    
    collectModel.height = 145.0f;
}

- (void)setArticleModel:(DWDArticleModel *)articleModel
{
    _articleModel = articleModel;
    
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:articleModel.auth.photoKey] placeholderImage:DWDDefault_MeBoyImage];
    self.nickname.text = articleModel.auth.nickname;
    
    self.title.text = articleModel.title;
    self.time.text = [NSString stringWithTimelineDate:[NSDate dateWithString:self.collectModel.collectime format:@"YYYYMMddHHmmss"]]; //YYYY-MM-dd HH:mm:ss]
    
    [self.photoImv sd_setImageWithURL:[NSURL URLWithString:articleModel.photoUrl] placeholderImage:DWDDefault_infoVideoImage];
 
}

@end

@interface DWDColVoiceCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *fileTime;

@end
@implementation DWDColVoiceCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    _avatar.layer.masksToBounds = YES;
    _avatar.layer.cornerRadius = _avatar.h/2;
}
- (void)setCollectModel:(DWDCollectModel *)collectModel
{
    _collectModel = collectModel;

    collectModel.height = 150.0f;
}
- (void)setArticleModel:(DWDArticleModel *)articleModel
{
    _articleModel = articleModel;
    
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:articleModel.auth.photoKey] placeholderImage:DWDDefault_MeBoyImage];
    self.nickname.text = articleModel.auth.nickname;
    
    self.title.text = articleModel.title;
    self.time.text = [NSString stringWithTimelineDate:[NSDate dateWithString:self.collectModel.collectime format:@"YYYYMMddHHmmss"]]; //YYYY-MM-dd HH:mm:ss]
    
    self.fileName.text = articleModel.voice.fileName;
    self.fileTime.text = [articleModel.voice.duration calculateduartion];
    
}
@end

@interface DWDColVideoCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UILabel *fileTime;

@end
@implementation DWDColVideoCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    _avatar.layer.masksToBounds = YES;
    _avatar.layer.cornerRadius = _avatar.h/2;
}
- (void)setCollectModel:(DWDCollectModel *)collectModel
{
    _collectModel = collectModel;
    
    collectModel.height = 290.0f;
}
- (void)setArticleModel:(DWDArticleModel *)articleModel
{
    _articleModel = articleModel;
    
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:articleModel.auth.photoKey] placeholderImage:DWDDefault_MeBoyImage];
    self.nickname.text = articleModel.auth.nickname;
    
    self.title.text = articleModel.title;
    self.time.text = [NSString stringWithTimelineDate:[NSDate dateWithString:self.collectModel.collectime format:@"YYYYMMddHHmmss"]]; //YYYY-MM-dd HH:mm:ss]
    
     [self.imv sd_setImageWithURL:[NSURL URLWithString:articleModel.photoUrl] placeholderImage:DWDDefault_infoVideoImage];
    self.fileTime.text = [articleModel.video.duration calculateduartion];
}

@end
/*
用户id	custId	long
用户姓名	name	String
订阅数	subCnt	int
专家头像	photoKey	String

标签id	tagId	long
个人标签	name	String
 */
@interface DWDColExpertCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *introl;
@end
@implementation DWDColExpertCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    _avatar.layer.masksToBounds = YES;
    _avatar.layer.cornerRadius = _avatar.h/2;
}
- (void)setCollectModel:(DWDCollectModel *)collectModel
{
    _collectModel = collectModel;
    
    
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:collectModel.expert.photoKey] placeholderImage:DWDDefault_MeBoyImage];
    self.nickname.text = collectModel.expert.name;

    NSArray *arr = collectModel.expert.tags;
    DWDInfoExpTagModel *tags = arr[0];
    self.title.text = tags.name ;
    
    self.time.text = [NSString stringWithTimelineDate:[NSDate dateWithString:collectModel.collectime format:@"YYYYMMddHHmmss"]]; //YYYY-MM-dd HH:mm:ss]
    
       self.introl.text = collectModel.expert.sign;
    collectModel.height = 115.0f;

}


@end