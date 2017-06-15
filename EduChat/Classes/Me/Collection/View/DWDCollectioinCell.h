//
//  DWDCollectioinCell.h
//  EduChat
//
//  Created by Gatlin on 16/8/27.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger) {
    DWDCollectPicture = 1,
    DWDCollectVideo,
    DWDCollectVoice,
    DWDCollectChat = 5,
    DWDCollectChatList ,
    DWDCollectUenonExpert ,
    DWDCollectUenonArticle = 8,
    
    //新闻
    DWDCollectNewArticle = 41,
    DWDCollectNewPhoto = 42,
    DWDCollectNewVoice = 43,
    DWDCollectNewVideo = 44,
    
}DWDCollectType;

@class DWDCollectModel,DWDArticleModel;
@interface DWDCollectioinCell : UITableViewCell
- (instancetype)initWithTableView:(UITableView *)tableView collectModel:(DWDCollectModel *)collectModel;


@end

@interface DWDColArticleCell : UITableViewCell
@property (nonatomic, strong) DWDCollectModel *collectModel;
@property (nonatomic, strong) DWDArticleModel *articleModel;
@end

@interface DWDColPhotoCell : UITableViewCell
@property (nonatomic, strong) DWDCollectModel *collectModel;
@property (nonatomic, strong) DWDArticleModel *articleModel;
@end

@interface DWDColVoiceCell : UITableViewCell
@property (nonatomic, strong) DWDCollectModel *collectModel;
@property (nonatomic, strong) DWDArticleModel *articleModel;
@end

@interface DWDColVideoCell : UITableViewCell
@property (nonatomic, strong) DWDCollectModel *collectModel;
@property (nonatomic, strong) DWDArticleModel *articleModel;
@end

@interface DWDColExpertCell : UITableViewCell
@property (nonatomic, strong) DWDCollectModel *collectModel;
@end