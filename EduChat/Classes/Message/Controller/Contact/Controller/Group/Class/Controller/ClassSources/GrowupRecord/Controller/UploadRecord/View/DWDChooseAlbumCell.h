//
//  DWDChooseAlbumCell.h
//  EduChat
//
//  Created by Superman on 16/1/6.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDChooseAlbumModel;
@interface DWDChooseAlbumCell : UICollectionViewCell

@property (nonatomic , strong) DWDChooseAlbumModel *albums;
@property (nonatomic , weak) UIImageView *iconView;
@property (nonatomic , weak) UILabel *albumNameLabel;
@end
